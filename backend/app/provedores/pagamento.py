"""Pagamentos (seção 4.11). O direito de acesso vive no servidor: o app pergunta o plano;
o backend valida os recibos das lojas e os webhooks do Stripe.

Situação: o provedor falso é o único exercitado. Stripe (REST + verificação de assinatura
do webhook), App Store Server API e Google Play Developer API estão escritos pela
documentação de cada serviço e precisam de credenciais reais para teste (docs/como-rodar.md).
"""

from __future__ import annotations

import hashlib
import hmac
import json
import time
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from typing import Protocol

import httpx
import jwt

from app.config import Configuracoes, configuracoes


class PagamentoIndisponivel(Exception):
    pass


class PagamentoInvalido(Exception):
    pass


@dataclass
class EventoAssinatura:
    """Mudança de assinatura vinda de um provedor."""

    tipo: str  # ativada | atualizada | cancelada
    id_externo: str
    plano: str | None = None
    usuario_id: str | None = None
    organizacao_id: str | None = None
    valida_ate: datetime | None = None


class ProvedorPagamento(Protocol):
    nome: str

    def criar_checkout(
        self, usuario_id: str, email: str, plano: str, organizacao_id: str | None, url_retorno: str
    ) -> str: ...

    def ler_webhook(self, corpo: bytes, assinatura: str) -> EventoAssinatura | None: ...


# ------------------------------------------------------------------- Stripe


class Stripe:
    nome = "stripe"
    API = "https://api.stripe.com/v1"
    TOLERANCIA_SEGUNDOS = 300

    def __init__(self, cfg: Configuracoes, cliente: httpx.Client | None = None):
        if not cfg.stripe_secret_key:
            raise PagamentoIndisponivel("STRIPE_SECRET_KEY não configurada.")
        self.cfg = cfg
        self.cliente = cliente or httpx.Client(timeout=15)

    def criar_checkout(self, usuario_id, email, plano, organizacao_id, url_retorno) -> str:
        preco = {
            "familia": self.cfg.stripe_preco_familia,
            "escola": self.cfg.stripe_preco_escola,
        }.get(plano)
        if not preco:
            raise PagamentoIndisponivel(f"Preço do plano {plano} não configurado.")
        dados = {
            "mode": "subscription",
            "line_items[0][price]": preco,
            "line_items[0][quantity]": "1",
            "customer_email": email,
            "client_reference_id": usuario_id,
            "success_url": f"{url_retorno}?assinatura=ok",
            "cancel_url": f"{url_retorno}?assinatura=cancelada",
            "metadata[plano]": plano,
            "subscription_data[metadata][plano]": plano,
            "subscription_data[metadata][usuario_id]": usuario_id,
        }
        if organizacao_id:
            dados["metadata[organizacao_id]"] = organizacao_id
            dados["subscription_data[metadata][organizacao_id]"] = organizacao_id
        try:
            r = self.cliente.post(
                f"{self.API}/checkout/sessions", data=dados, auth=(self.cfg.stripe_secret_key, "")
            )
            r.raise_for_status()
            return r.json()["url"]
        except (httpx.HTTPError, KeyError) as e:
            raise PagamentoIndisponivel(f"Stripe indisponível: {e}") from e

    def verificar_assinatura(
        self, corpo: bytes, cabecalho: str, agora: float | None = None
    ) -> None:
        """Cabeçalho Stripe-Signature: t=<timestamp>,v1=<hmac sha256 de 't.corpo'>."""
        partes = dict(p.split("=", 1) for p in cabecalho.split(",") if "=" in p)
        if "t" not in partes or "v1" not in partes:
            raise PagamentoInvalido("Assinatura ausente.")
        esperado = hmac.new(
            self.cfg.stripe_webhook_secret.encode(),
            f"{partes['t']}.".encode() + corpo,
            hashlib.sha256,
        ).hexdigest()
        assinaturas = [v for k, v in (p.split("=", 1) for p in cabecalho.split(",")) if k == "v1"]
        if not any(hmac.compare_digest(esperado, a) for a in assinaturas):
            raise PagamentoInvalido("Assinatura do webhook não confere.")
        if abs((agora or time.time()) - int(partes["t"])) > self.TOLERANCIA_SEGUNDOS:
            raise PagamentoInvalido("Webhook fora da janela de tempo.")

    def ler_webhook(self, corpo: bytes, assinatura: str) -> EventoAssinatura | None:
        self.verificar_assinatura(corpo, assinatura)
        evento = json.loads(corpo)
        obj = evento["data"]["object"]
        meta = obj.get("metadata") or {}
        if evento["type"] == "checkout.session.completed" and obj.get("subscription"):
            return EventoAssinatura(
                "ativada",
                obj["subscription"],
                meta.get("plano"),
                obj.get("client_reference_id"),
                meta.get("organizacao_id"),
            )
        if evento["type"] in ("customer.subscription.updated", "customer.subscription.deleted"):
            fim = obj.get("current_period_end") or (obj.get("items", {}).get("data") or [{}])[
                0
            ].get("current_period_end")
            ativa = obj.get("status") in ("active", "trialing") and evento["type"].endswith(
                "updated"
            )
            return EventoAssinatura(
                "atualizada" if ativa else "cancelada",
                obj["id"],
                meta.get("plano"),
                meta.get("usuario_id"),
                meta.get("organizacao_id"),
                datetime.fromtimestamp(fim, UTC) if fim else None,
            )
        return None


# -------------------------------------------------------------- lojas móveis


def validar_app_store(
    cfg: Configuracoes, transacao_id: str, cliente: httpx.Client | None = None
) -> tuple[str, datetime | None]:
    """App Store Server API: status da assinatura pela transação original.

    Exige APPLE_BUNDLE_ID e a chave da App Store Connect em APPLE_SHARED_SECRET no formato
    "<issuer_id>|<key_id>|<chave privada PEM>".
    """
    try:
        emissor, chave_id, pem = cfg.apple_shared_secret.split("|", 2)
    except ValueError as e:
        raise PagamentoIndisponivel("Credenciais da App Store não configuradas.") from e
    agora = int(time.time())
    token = jwt.encode(
        {
            "iss": emissor,
            "iat": agora,
            "exp": agora + 600,
            "aud": "appstoreconnect-v1",
            "bid": cfg.apple_bundle_id,
        },
        pem,
        algorithm="ES256",
        headers={"kid": chave_id},
    )
    cliente = cliente or httpx.Client(timeout=15)
    r = cliente.get(
        f"https://api.storekit.itunes.apple.com/inApps/v1/subscriptions/{transacao_id}",
        headers={"Authorization": f"Bearer {token}"},
    )
    if r.status_code == 404:
        raise PagamentoInvalido("Transação não encontrada na App Store.")
    r.raise_for_status()
    for grupo in r.json().get("data", []):
        for t in grupo.get("lastTransactions", []):
            if t.get("status") == 1:  # ativa
                carga = jwt.decode(t["signedTransactionInfo"], options={"verify_signature": False})
                fim = carga.get("expiresDate")
                return transacao_id, datetime.fromtimestamp(fim / 1000, UTC) if fim else None
    raise PagamentoInvalido("Assinatura da App Store não está ativa.")


def validar_google_play(
    cfg: Configuracoes, produto: str, token_compra: str, cliente: httpx.Client | None = None
) -> tuple[str, datetime | None]:
    """Google Play Developer API (purchases.subscriptionsv2) com conta de serviço."""
    if not cfg.google_play_conta_servico_json or not cfg.google_play_pacote:
        raise PagamentoIndisponivel("Credenciais do Google Play não configuradas.")
    conta = json.loads(cfg.google_play_conta_servico_json)
    agora = int(time.time())
    afirmacao = jwt.encode(
        {
            "iss": conta["client_email"],
            "scope": "https://www.googleapis.com/auth/androidpublisher",
            "aud": "https://oauth2.googleapis.com/token",
            "iat": agora,
            "exp": agora + 600,
        },
        conta["private_key"],
        algorithm="RS256",
    )
    cliente = cliente or httpx.Client(timeout=15)
    acesso = cliente.post(
        "https://oauth2.googleapis.com/token",
        data={
            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
            "assertion": afirmacao,
        },
    ).json()["access_token"]
    r = cliente.get(
        "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/"
        f"{cfg.google_play_pacote}/purchases/subscriptionsv2/tokens/{token_compra}",
        headers={"Authorization": f"Bearer {acesso}"},
    )
    r.raise_for_status()
    dados = r.json()
    if dados.get("subscriptionState") not in (
        "SUBSCRIPTION_STATE_ACTIVE",
        "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
    ):
        raise PagamentoInvalido("Assinatura do Google Play não está ativa.")
    fim = (dados.get("lineItems") or [{}])[0].get("expiryTime")
    return token_compra, datetime.fromisoformat(fim.replace("Z", "+00:00")) if fim else None


# ---------------------------------------------------------------------- falso


class PagamentoFalso:
    """Ambiente local: o checkout ativa o plano na hora (sem cobrança)."""

    nome = "falso"

    def criar_checkout(self, usuario_id, email, plano, organizacao_id, url_retorno) -> str:
        return f"{url_retorno}?assinatura=ok&falso=1"

    def ler_webhook(self, corpo: bytes, assinatura: str) -> EventoAssinatura | None:
        return None

    @staticmethod
    def validade() -> datetime:
        return datetime.now(UTC) + timedelta(days=30)


def obter_pagamento() -> ProvedorPagamento:
    cfg = configuracoes()
    if cfg.provedor_pagamento == "stripe":
        return Stripe(cfg)
    return PagamentoFalso()
