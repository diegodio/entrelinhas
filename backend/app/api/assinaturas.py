"""Planos e assinaturas: estado do plano, checkout (web), recibos das lojas (celular), webhook."""

from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, Request
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.config import configuracoes
from app.db import obter_sessao
from app.erros import ErroApi
from app.modelos import Assinatura, MembroOrganizacao, Usuario
from app.provedores import pagamento as pag
from app.seguranca import usuario_obrigatorio
from app.servicos import planos

rotas = APIRouter(prefix="/v1/assinaturas", tags=["assinaturas"])
PLANOS_PAGOS = ("familia", "escola")


@rotas.get("/eu")
def meu_plano(
    usuario: Usuario = Depends(usuario_obrigatorio), sessao: Session = Depends(obter_sessao)
):
    return planos.uso(sessao, usuario)


def _exigir_gestor(sessao: Session, usuario: Usuario, organizacao_id: str | None) -> None:
    if not organizacao_id:
        raise ErroApi(
            400,
            "organizacao_obrigatoria",
            "O plano Escola é contratado por uma escola ou biblioteca.",
        )
    papel = sessao.scalar(
        select(MembroOrganizacao.papel).where(
            MembroOrganizacao.organizacao_id == uuid.UUID(organizacao_id),
            MembroOrganizacao.usuario_id == usuario.id,
        )
    )
    if papel != "gestor":
        raise ErroApi(403, "proibido", "Só o gestor da instituição contrata o plano Escola.")


def ativar(
    sessao: Session,
    *,
    plano: str,
    origem: str,
    id_externo: str | None,
    usuario_id=None,
    organizacao_id=None,
    valida_ate=None,
) -> Assinatura:
    existente = None
    if id_externo:
        existente = sessao.scalars(
            select(Assinatura).where(Assinatura.id_externo == id_externo)
        ).first()
    if existente is None:
        existente = Assinatura(plano=plano, origem=origem, id_externo=id_externo)
        sessao.add(existente)
    existente.plano = plano
    existente.estado = "ativa"
    existente.valida_ate = valida_ate
    # Só sobrescreve o dono quando o evento traz essa informação.
    if plano == "escola" and organizacao_id:
        existente.organizacao_id = uuid.UUID(str(organizacao_id))
        existente.usuario_id = None
    elif usuario_id:
        existente.usuario_id = uuid.UUID(str(usuario_id))
    sessao.commit()
    return existente


class Checkout(BaseModel):
    plano: str
    organizacao_id: str | None = None


@rotas.post("/checkout")
def checkout(
    dados: Checkout,
    usuario: Usuario = Depends(usuario_obrigatorio),
    sessao: Session = Depends(obter_sessao),
):
    """Web: devolve a URL do checkout do Stripe. Local (falso): ativa e devolve o retorno."""
    if dados.plano not in PLANOS_PAGOS:
        raise ErroApi(400, "plano_invalido", "Escolha um plano pago.")
    if dados.plano == "escola":
        _exigir_gestor(sessao, usuario, dados.organizacao_id)
    try:
        provedor = pag.obter_pagamento()
        url = provedor.criar_checkout(
            str(usuario.id),
            usuario.email,
            dados.plano,
            dados.organizacao_id,
            f"{configuracoes().url_publica_app}/planos",
        )
    except pag.PagamentoIndisponivel as e:
        raise ErroApi(
            503, "pagamento_indisponivel", "A assinatura não está disponível neste ambiente."
        ) from e
    if provedor.nome == "falso":
        ativar(
            sessao,
            plano=dados.plano,
            origem="falso",
            id_externo=None,
            usuario_id=usuario.id,
            organizacao_id=dados.organizacao_id,
            valida_ate=pag.PagamentoFalso.validade(),
        )
    return {"url": url, "provedor": provedor.nome}


class ReciboLoja(BaseModel):
    origem: str  # app_store | google_play
    plano: str
    produto: str
    recibo: str  # transação original (Apple) ou token de compra (Google)


@rotas.post("/loja")
def recibo_loja(
    dados: ReciboLoja,
    usuario: Usuario = Depends(usuario_obrigatorio),
    sessao: Session = Depends(obter_sessao),
):
    """Celular: o app manda o recibo da compra; o servidor confere com a loja."""
    if dados.plano != "familia":
        raise ErroApi(400, "plano_invalido", "Nas lojas está disponível o plano Família.")
    cfg = configuracoes()
    try:
        if dados.origem == "app_store":
            id_externo, fim = pag.validar_app_store(cfg, dados.recibo)
        elif dados.origem == "google_play":
            id_externo, fim = pag.validar_google_play(cfg, dados.produto, dados.recibo)
        else:
            raise ErroApi(400, "origem_invalida", "Loja desconhecida.")
    except pag.PagamentoIndisponivel as e:
        raise ErroApi(
            503, "pagamento_indisponivel", "A assinatura não está disponível neste ambiente."
        ) from e
    except pag.PagamentoInvalido as e:
        raise ErroApi(402, "recibo_invalido", str(e)) from e
    ativar(
        sessao,
        plano="familia",
        origem=dados.origem,
        id_externo=id_externo,
        usuario_id=usuario.id,
        valida_ate=fim,
    )
    return planos.uso(sessao, usuario)


@rotas.post("/stripe/webhook", status_code=204)
async def webhook_stripe(request: Request, sessao: Session = Depends(obter_sessao)):
    corpo = await request.body()
    try:
        provedor = pag.Stripe(configuracoes())
        evento = provedor.ler_webhook(corpo, request.headers.get("stripe-signature", ""))
    except pag.PagamentoIndisponivel as e:
        raise ErroApi(503, "pagamento_indisponivel", "Stripe não configurado.") from e
    except pag.PagamentoInvalido as e:
        raise ErroApi(400, "webhook_invalido", str(e)) from e
    if evento is None:
        return
    if evento.tipo == "cancelada":
        a = sessao.scalars(
            select(Assinatura).where(Assinatura.id_externo == evento.id_externo)
        ).first()
        if a is not None:
            a.estado = "cancelada"
            a.valida_ate = evento.valida_ate or a.valida_ate
            sessao.commit()
        return
    ativar(
        sessao,
        plano=evento.plano or "familia",
        origem="stripe",
        id_externo=evento.id_externo,
        usuario_id=evento.usuario_id,
        organizacao_id=evento.organizacao_id,
        valida_ate=evento.valida_ate,
    )
