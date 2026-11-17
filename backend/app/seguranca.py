"""Senhas, tokens e dependências de autenticação/autorização."""

from __future__ import annotations

import hashlib
import secrets
import uuid
from datetime import UTC, datetime, timedelta

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import InvalidHashError, VerificationError
from fastapi import Depends, Request
from sqlalchemy.orm import Session

from app.config import configuracoes
from app.db import obter_sessao
from app.erros import ErroApi, nao_autenticado, proibido
from app.modelos import TokenRenovacao, Usuario

_hasher = PasswordHasher()


def hash_senha(senha: str) -> str:
    return _hasher.hash(senha)


def senha_confere(hash_: str | None, senha: str) -> bool:
    if not hash_:
        return False
    try:
        return _hasher.verify(hash_, senha)
    except (VerificationError, InvalidHashError):
        return False


def hash_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()


def token_aleatorio() -> str:
    return secrets.token_urlsafe(48)


def criar_token_acesso(usuario: Usuario) -> str:
    cfg = configuracoes()
    agora = datetime.now(UTC)
    carga = {
        "sub": str(usuario.id),
        "papel": usuario.papel,
        "tipo": "acesso",
        "iat": agora,
        "exp": agora + timedelta(minutes=cfg.jwt_minutos_acesso),
    }
    return jwt.encode(carga, cfg.jwt_segredo, algorithm="HS256")


def emitir_tokens(sessao: Session, usuario: Usuario) -> dict:
    cfg = configuracoes()
    renovacao = token_aleatorio()
    sessao.add(
        TokenRenovacao(
            usuario_id=usuario.id,
            hash_token=hash_token(renovacao),
            expira_em=datetime.now(UTC) + timedelta(days=cfg.dias_renovacao),
        )
    )
    sessao.commit()
    return {
        "token_acesso": criar_token_acesso(usuario),
        "token_renovacao": renovacao,
        "expira_em_segundos": cfg.jwt_minutos_acesso * 60,
    }


def _ler_token(request: Request) -> str | None:
    cabecalho = request.headers.get("authorization", "")
    if cabecalho.lower().startswith("bearer "):
        return cabecalho[7:].strip()
    return None


def usuario_opcional(request: Request, sessao: Session = Depends(obter_sessao)) -> Usuario | None:
    token = _ler_token(request)
    if not token:
        return None
    try:
        carga = jwt.decode(token, configuracoes().jwt_segredo, algorithms=["HS256"])
    except jwt.ExpiredSignatureError as e:
        raise ErroApi(401, "token_expirado", "Sua sessão expirou. Entre de novo.") from e
    except jwt.PyJWTError as e:
        raise nao_autenticado() from e
    if carga.get("tipo") != "acesso":
        raise nao_autenticado()
    usuario = sessao.get(Usuario, uuid.UUID(carga["sub"]))
    if usuario is None:
        raise nao_autenticado()
    return usuario


def usuario_obrigatorio(usuario: Usuario | None = Depends(usuario_opcional)) -> Usuario:
    if usuario is None:
        raise nao_autenticado()
    return usuario


def exigir_papel(*papeis: str):
    def _dep(usuario: Usuario = Depends(usuario_obrigatorio)) -> Usuario:
        if usuario.papel not in papeis:
            raise proibido()
        return usuario

    return _dep
