"""Cadastro, login (e-mail, Google, Apple), renovação, recuperação de senha."""

from __future__ import annotations

from datetime import UTC, datetime, timedelta

from fastapi import APIRouter, Depends
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy import select, update
from sqlalchemy.orm import Session

from app.config import configuracoes
from app.db import obter_sessao
from app.erros import ErroApi
from app.modelos import Consentimento, TokenRecuperacao, TokenRenovacao, Usuario
from app.provedores import login_social
from app.provedores.email import ProvedorEmail, obter_email
from app.seguranca import emitir_tokens, hash_senha, hash_token, senha_confere, token_aleatorio

rotas = APIRouter(prefix="/v1/auth", tags=["autenticação"])

VERSAO_TERMOS = "2026-11-rascunho"


class Cadastro(BaseModel):
    email: EmailStr
    senha: str = Field(min_length=8, max_length=200)
    nome: str = Field(default="", max_length=120)
    aceite_termos: bool


class Login(BaseModel):
    email: EmailStr
    senha: str


class Renovacao(BaseModel):
    token_renovacao: str


class LoginSocial(BaseModel):
    id_token: str
    nome: str | None = Field(default=None, max_length=120)


class Recuperacao(BaseModel):
    email: EmailStr


class Redefinicao(BaseModel):
    token: str
    senha: str = Field(min_length=8, max_length=200)


def _por_email(sessao: Session, email: str) -> Usuario | None:
    return sessao.scalars(select(Usuario).where(Usuario.email == email.lower())).first()


def _registrar_aceite(sessao: Session, usuario: Usuario) -> None:
    for doc in ("termos", "privacidade"):
        sessao.add(Consentimento(usuario_id=usuario.id, documento=doc, versao=VERSAO_TERMOS))


@rotas.post("/cadastro", status_code=201)
def cadastro(dados: Cadastro, sessao: Session = Depends(obter_sessao)):
    if not dados.aceite_termos:
        raise ErroApi(400, "aceite_obrigatorio", "É preciso aceitar os termos para criar a conta.")
    if _por_email(sessao, dados.email):
        raise ErroApi(409, "email_em_uso", "Já existe uma conta com este e-mail.")
    usuario = Usuario(
        email=dados.email.lower(), hash_senha=hash_senha(dados.senha), nome=dados.nome.strip()
    )
    sessao.add(usuario)
    sessao.flush()
    _registrar_aceite(sessao, usuario)
    sessao.commit()
    return emitir_tokens(sessao, usuario)


@rotas.post("/entrar")
def entrar(dados: Login, sessao: Session = Depends(obter_sessao)):
    usuario = _por_email(sessao, dados.email)
    if usuario is None or not senha_confere(usuario.hash_senha, dados.senha):
        raise ErroApi(401, "credenciais_invalidas", "E-mail ou senha incorretos.")
    return emitir_tokens(sessao, usuario)


@rotas.post("/renovar")
def renovar(dados: Renovacao, sessao: Session = Depends(obter_sessao)):
    """Rotação: o token usado é revogado e um novo par é emitido."""
    registro = sessao.scalars(
        select(TokenRenovacao).where(TokenRenovacao.hash_token == hash_token(dados.token_renovacao))
    ).first()
    if registro is None or registro.expira_em < datetime.now(UTC):
        raise ErroApi(401, "renovacao_invalida", "Sua sessão expirou. Entre de novo.")
    if registro.revogado:
        # Reuso de token revogado: possível vazamento. Revoga todos os tokens da pessoa.
        sessao.execute(
            update(TokenRenovacao)
            .where(TokenRenovacao.usuario_id == registro.usuario_id)
            .values(revogado=True)
        )
        sessao.commit()
        raise ErroApi(401, "renovacao_invalida", "Sua sessão expirou. Entre de novo.")
    registro.revogado = True
    usuario = sessao.get(Usuario, registro.usuario_id)
    sessao.commit()
    return emitir_tokens(sessao, usuario)


@rotas.post("/sair", status_code=204)
def sair(dados: Renovacao, sessao: Session = Depends(obter_sessao)):
    sessao.execute(
        update(TokenRenovacao)
        .where(TokenRenovacao.hash_token == hash_token(dados.token_renovacao))
        .values(revogado=True)
    )
    sessao.commit()


def _login_social(provedor: str, dados: LoginSocial, sessao: Session) -> dict:
    try:
        ident = login_social.verificar(provedor, dados.id_token)
    except login_social.LoginSocialIndisponivel as e:
        raise ErroApi(
            503, "login_social_indisponivel", "Este acesso ainda não está configurado."
        ) from e
    except login_social.TokenSocialInvalido as e:
        raise ErroApi(401, "token_social_invalido", "Não conseguimos confirmar seu acesso.") from e
    usuario = sessao.scalars(
        select(Usuario).where(Usuario.provedores_sociais[provedor].astext == ident.sub)
    ).first()
    if usuario is None:
        existente = _por_email(sessao, ident.email)
        if existente is not None:
            if not ident.email_verificado:
                raise ErroApi(409, "email_em_uso", "Já existe uma conta com este e-mail.")
            usuario = existente
        else:
            usuario = Usuario(email=ident.email, nome=dados.nome or ident.nome or "")
            sessao.add(usuario)
            sessao.flush()
            _registrar_aceite(sessao, usuario)
        usuario.provedores_sociais = {**(usuario.provedores_sociais or {}), provedor: ident.sub}
        sessao.commit()
    return emitir_tokens(sessao, usuario)


@rotas.post("/google")
def google(dados: LoginSocial, sessao: Session = Depends(obter_sessao)):
    return _login_social("google", dados, sessao)


@rotas.post("/apple")
def apple(dados: LoginSocial, sessao: Session = Depends(obter_sessao)):
    return _login_social("apple", dados, sessao)


@rotas.post("/recuperar", status_code=202)
def recuperar(
    dados: Recuperacao,
    sessao: Session = Depends(obter_sessao),
    email: ProvedorEmail = Depends(obter_email),
):
    """Responde igual exista ou não a conta, para não revelar quais e-mails estão cadastrados."""
    usuario = _por_email(sessao, dados.email)
    if usuario is not None:
        token = token_aleatorio()
        sessao.add(
            TokenRecuperacao(
                usuario_id=usuario.id,
                hash_token=hash_token(token),
                expira_em=datetime.now(UTC) + timedelta(hours=1),
            )
        )
        sessao.commit()
        link = f"{configuracoes().url_publica_app}/redefinir-senha?token={token}"
        email.enviar(
            usuario.email,
            "Entrelinhas: criar nova senha",
            f"Para criar uma nova senha, abra o link abaixo em até 1 hora:\n\n{link}\n\n"
            "Se você não pediu, ignore este e-mail.",
        )
    return {"ok": True}


@rotas.post("/redefinir")
def redefinir(dados: Redefinicao, sessao: Session = Depends(obter_sessao)):
    registro = sessao.scalars(
        select(TokenRecuperacao).where(TokenRecuperacao.hash_token == hash_token(dados.token))
    ).first()
    if registro is None or registro.usado or registro.expira_em < datetime.now(UTC):
        raise ErroApi(400, "token_invalido", "Este link expirou. Peça um novo.")
    usuario = sessao.get(Usuario, registro.usuario_id)
    usuario.hash_senha = hash_senha(dados.senha)
    registro.usado = True
    sessao.execute(
        update(TokenRenovacao).where(TokenRenovacao.usuario_id == usuario.id).values(revogado=True)
    )
    sessao.commit()
    return {"ok": True}
