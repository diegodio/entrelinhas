"""Planos, direito de acesso e limite mensal (seção 4.11). O limite vive no servidor."""

from __future__ import annotations

from datetime import UTC, datetime

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.modelos import Assinatura, Consulta, MembroOrganizacao, Usuario, inicio_do_mes
from app.servicos import configuracao as cfg_servico


def _ativa(a: Assinatura) -> bool:
    return a.estado == "ativa" and (a.valida_ate is None or a.valida_ate > datetime.now(UTC))


def plano_do_usuario(sessao: Session, usuario: Usuario) -> dict:
    """Devolve {"plano": gratuito|familia|escola, "origem", "valida_ate", "organizacao_id"}."""
    proprias = sessao.scalars(select(Assinatura).where(Assinatura.usuario_id == usuario.id)).all()
    for a in sorted(proprias, key=lambda x: x.plano != "escola"):
        if _ativa(a):
            return {
                "plano": a.plano,
                "origem": a.origem,
                "valida_ate": a.valida_ate,
                "organizacao_id": None,
            }
    orgs = sessao.scalars(
        select(MembroOrganizacao.organizacao_id).where(MembroOrganizacao.usuario_id == usuario.id)
    ).all()
    if orgs:
        da_org = sessao.scalars(select(Assinatura).where(Assinatura.organizacao_id.in_(orgs))).all()
        for a in da_org:
            if _ativa(a):
                return {
                    "plano": "escola",
                    "origem": a.origem,
                    "valida_ate": a.valida_ate,
                    "organizacao_id": str(a.organizacao_id),
                }
    return {"plano": "gratuito", "origem": None, "valida_ate": None, "organizacao_id": None}


def consultas_do_mes(sessao: Session, usuario: Usuario) -> int:
    return (
        sessao.scalar(
            select(func.count(Consulta.id)).where(
                Consulta.usuario_id == usuario.id,
                Consulta.conta_no_limite.is_(True),
                Consulta.criado_em >= inicio_do_mes(),
            )
        )
        or 0
    )


def uso(sessao: Session, usuario: Usuario) -> dict:
    plano = plano_do_usuario(sessao, usuario)
    limite = cfg_servico.carregar(sessao)["limites"]["consultas_gratis_mes"]
    usadas = consultas_do_mes(sessao, usuario)
    return {
        **plano,
        "valida_ate": plano["valida_ate"].isoformat() if plano["valida_ate"] else None,
        "consultas_usadas": usadas,
        "consultas_limite": None if plano["plano"] != "gratuito" else limite,
    }


class LimiteAtingido(Exception):
    pass


def registrar_consulta(sessao: Session, usuario: Usuario, obra_id) -> None:
    """Uma ficha já aberta não consome nova consulta. Planos pagos não têm limite."""
    ja_abriu = sessao.scalar(
        select(func.count(Consulta.id)).where(
            Consulta.usuario_id == usuario.id, Consulta.obra_id == obra_id
        )
    )
    plano = plano_do_usuario(sessao, usuario)["plano"]
    if ja_abriu:
        sessao.add(Consulta(usuario_id=usuario.id, obra_id=obra_id, conta_no_limite=False))
        sessao.commit()
        return
    if plano == "gratuito":
        limite = cfg_servico.carregar(sessao)["limites"]["consultas_gratis_mes"]
        if consultas_do_mes(sessao, usuario) >= limite:
            raise LimiteAtingido()
    sessao.add(
        Consulta(usuario_id=usuario.id, obra_id=obra_id, conta_no_limite=plano == "gratuito")
    )
    sessao.commit()


def limite_de_perfis(sessao: Session, usuario: Usuario) -> int | None:
    if plano_do_usuario(sessao, usuario)["plano"] != "gratuito":
        return None
    return cfg_servico.carregar(sessao)["limites"]["perfis_plano_gratuito"]
