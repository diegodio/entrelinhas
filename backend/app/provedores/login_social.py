"""Verificação de ID tokens do Google e da Apple pelas chaves públicas (JWKS) de cada um.

Escrito conforme a documentação dos provedores; não exercitado contra contas reais neste
ambiente (exige client IDs configurados). Ver docs/como-rodar.md.
"""

from __future__ import annotations

from dataclasses import dataclass
from functools import lru_cache

import jwt

from app.config import configuracoes

EMISSORES = {
    "google": (
        "https://www.googleapis.com/oauth2/v3/certs",
        ("https://accounts.google.com", "accounts.google.com"),
    ),
    "apple": ("https://appleid.apple.com/auth/keys", ("https://appleid.apple.com",)),
}


class LoginSocialIndisponivel(Exception):
    pass


class TokenSocialInvalido(Exception):
    pass


@dataclass
class IdentidadeSocial:
    provedor: str
    sub: str
    email: str
    email_verificado: bool
    nome: str | None = None


@lru_cache
def _cliente_jwks(url: str) -> jwt.PyJWKClient:
    return jwt.PyJWKClient(url, cache_keys=True)


def _audiencias(provedor: str) -> list[str]:
    cfg = configuracoes()
    bruto = cfg.google_client_ids if provedor == "google" else cfg.apple_client_ids
    return [a.strip() for a in bruto.split(",") if a.strip()]


def verificar(provedor: str, id_token: str) -> IdentidadeSocial:
    if provedor not in EMISSORES:
        raise TokenSocialInvalido(provedor)
    audiencias = _audiencias(provedor)
    if not audiencias:
        raise LoginSocialIndisponivel(provedor)
    url, emissores = EMISSORES[provedor]
    try:
        chave = _cliente_jwks(url).get_signing_key_from_jwt(id_token)
        carga = jwt.decode(
            id_token,
            chave.key,
            algorithms=["RS256"],
            audience=audiencias,
            issuer=list(emissores),
        )
    except jwt.PyJWTError as e:
        raise TokenSocialInvalido(str(e)) from e
    email = carga.get("email")
    if not email:
        raise TokenSocialInvalido("Token sem e-mail.")
    verificado = carga.get("email_verified") in (True, "true")
    return IdentidadeSocial(provedor, carga["sub"], email.lower(), verificado, carga.get("name"))
