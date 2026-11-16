"""Leitura, filtragem para exibição e versionamento de fichas."""

from __future__ import annotations

import copy
import secrets

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core import textos
from app.modelos import Ficha, FichaVersao, Obra, agora
from app.rubrica import nivel_regra_dura_a5
from app.servicos.obras import slugificar

STATUS_VISIVEIS = ("publicada", "em_revisao")


def novo_slug(sessao: Session, obra: Obra) -> str:
    base = slugificar(obra.titulo)[:80]
    while True:
        slug = f"{base}-{secrets.token_hex(3)}"
        if not sessao.scalar(select(Ficha.id).where(Ficha.slug == slug)):
            return slug


def filtrar_para_exibicao(dados: dict, config: dict) -> dict:
    """Remove do que SAI do servidor o que a configuração não permite expor.

    O banco guarda tudo. A regra dura do A5 vale com qualquer combinação de flags.
    """
    ficha = copy.deepcopy(dados)
    a5_duro = ficha["camada_a"]["A5"]["nivel"] >= nivel_regra_dura_a5()
    for ev in ficha.get("evidencias", []):
        if not config["flags"]["trechos_literais"] or (a5_duro and ev["eixo"] == "A5"):
            ev["trecho_literal"] = None
    if a5_duro:
        ficha["aviso_a5"] = textos.AVISO_TRECHO_SUPRIMIDO_A5
    if ficha["procedencia"]["fonte_da_analise"] in (
        "fontes_publicas",
        "metadados_e_conhecimento_previo",
    ):
        ficha["aviso_estimativa"] = textos.AVISO_ESTIMATIVA
    ficha["aviso_independencia"] = textos.AVISO_INDEPENDENCIA
    return ficha


def resumo_publico(ficha: Ficha) -> dict:
    d = ficha.dados or {}
    p = d.get("procedencia", {})
    return {
        "obra_id": str(ficha.obra_id),
        "slug": ficha.slug,
        "status": ficha.status,
        "faixa_final": d.get("faixa_final"),
        "recomendacao_contextual": d.get("recomendacao_contextual"),
        "texto_recomendacao": d.get("texto_recomendacao"),
        "fonte_da_analise": p.get("fonte_da_analise"),
        "texto_fonte_analise": textos.TEXTOS_FONTE_ANALISE.get(p.get("fonte_da_analise", "")),
        "confianca": p.get("confianca"),
        "revisada_por_humano": p.get("revisada_por_humano", False),
        "aviso_independencia": textos.AVISO_INDEPENDENCIA,
    }


def publicar_versao(
    sessao: Session,
    ficha: Ficha,
    dados: dict,
    *,
    autor_id=None,
    autor_papel: str = "sistema",
    motivo: str,
    status: str | None = None,
) -> Ficha:
    """Grava a nova versão no histórico imutável e atualiza as colunas indexadas."""
    ficha.versao_ficha = dados["versao_ficha"]
    ficha.dados = dados
    ficha.status = status or dados["status"]
    ficha.dados["status"] = ficha.status
    ficha.faixa_final = dados["faixa_final"]
    ficha.fonte_da_analise = dados["procedencia"]["fonte_da_analise"]
    ficha.confianca = dados["procedencia"]["confianca"]
    ficha.revisada_por_humano = dados["procedencia"]["revisada_por_humano"]
    ficha.versao_rubrica = dados["versao_rubrica"]
    ficha.erro = None
    ficha.atualizada_em = agora()
    sessao.add(
        FichaVersao(
            ficha_id=ficha.id,
            versao=ficha.versao_ficha,
            dados=copy.deepcopy(ficha.dados),
            autor_id=autor_id,
            autor_papel=autor_papel,
            motivo=motivo,
        )
    )
    sessao.commit()
    return ficha
