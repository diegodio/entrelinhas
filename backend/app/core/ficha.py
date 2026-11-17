"""Montagem da ficha (contrato da seção 4.3).

Os campos calculados (faixas, eixo determinante, recomendação, extensão, nível de
leitura) saem SEMPRE do código da seção 3.1, nunca copiados da resposta do modelo.
"""

from __future__ import annotations

import copy
from datetime import UTC, datetime

from app.core import textos
from app.core.agregacao import (
    agregar,
    arredondar_meio_para_cima,
    nivel_extensao,
)
from app.motor.validador import FONTES_COM_TEXTO
from app.rubrica import IDS_EIXOS, carregar_rubrica, nivel_regra_dura_a5


def aplicar_protecoes_evidencias(
    evidencias: list[dict],
    niveis: dict[str, int],
    fonte_da_analise: str,
    max_trechos: int,
    limite_palavras: int,
    rubrica: dict,
) -> list[dict]:
    """Defesa em profundidade: mesmo uma saída validada passa por estas regras de novo."""
    a5_duro = niveis.get("A5", 0) >= nivel_regra_dura_a5(rubrica)
    sem_texto = fonte_da_analise not in FONTES_COM_TEXTO
    resultado: list[dict] = []
    trechos = 0
    for ev in evidencias:
        item = {
            "eixo": ev["eixo"],
            "parafrase": str(ev.get("parafrase") or "").strip(),
            "trecho_literal": ev.get("trecho_literal") or None,
            "fonte": ev.get("fonte") or None,
            "localizacao": ev.get("localizacao") or None,
        }
        if sem_texto:
            item["trecho_literal"] = None
            item["localizacao"] = None
        if a5_duro and item["eixo"] == "A5":
            item["trecho_literal"] = None
        if item["trecho_literal"]:
            if trechos >= max_trechos or len(item["trecho_literal"].split()) > limite_palavras:
                item["trecho_literal"] = None
            else:
                trechos += 1
        resultado.append(item)
    return resultado


def montar_ficha(
    *,
    obra_id: str,
    saida: dict,
    paginas: int | None,
    procedencia: dict,
    versao_ficha: int,
    status: str = "publicada",
    max_trechos: int | None = None,
    limite_palavras: int | None = None,
    rubrica: dict | None = None,
    agora: datetime | None = None,
) -> dict:
    """Recebe a saída JÁ VALIDADA do classificador (ou da revisão humana) e monta a ficha."""
    rubrica = rubrica or carregar_rubrica()
    saida = copy.deepcopy(saida)
    niveis = {e: saida["camada_a"][e]["nivel"] for e in IDS_EIXOS}
    resultado = agregar(niveis, rubrica)

    camada_a = {
        e: {
            "nivel": niveis[e],
            "faixa": resultado.faixas_por_eixo[e],
            "justificativa": str(saida["camada_a"][e].get("justificativa") or "").strip(),
        }
        for e in IDS_EIXOS
    }

    regras_ev = rubrica["evidencia"]
    evidencias = aplicar_protecoes_evidencias(
        saida.get("evidencias", []),
        niveis,
        procedencia["fonte_da_analise"],
        max_trechos if max_trechos is not None else regras_ev["max_trechos_por_ficha_padrao"],
        limite_palavras
        if limite_palavras is not None
        else regras_ev["limite_palavras_trecho_padrao"],
        rubrica,
    )

    c = saida["camada_c"]
    extensao = nivel_extensao(paginas, rubrica) if paginas else None
    dimensoes = [c["vocabulario"], c["estrutura_narrativa"], c["densidade_tematica"]]
    if extensao is not None:
        dimensoes.append(extensao)
    # Sem número de páginas, a média usa as três dimensões disponíveis (docs/decisoes.md).
    nivel = arredondar_meio_para_cima(sum(dimensoes) / len(dimensoes))
    vf = c["valor_formativo"]

    flags = list(dict.fromkeys(saida["camada_b"].get("flags", [])))
    justificativas_b = {
        k: v for k, v in (saida["camada_b"].get("justificativas") or {}).items() if k in flags
    }

    return {
        "obra_id": str(obra_id),
        "versao_rubrica": rubrica["versao"],
        "versao_ficha": versao_ficha,
        "status": status,
        "faixa_final": resultado.faixa_final,
        "faixa_base": resultado.faixa_base,
        "agravante_acumulo_aplicado": resultado.agravante_acumulo_aplicado,
        "eixo_determinante": resultado.eixo_determinante,
        "recomendacao_contextual": resultado.recomendacao_contextual,
        "texto_recomendacao": textos.texto_recomendacao(
            resultado.recomendacao_contextual, resultado.faixa_final
        ),
        "camada_a": camada_a,
        "evidencias": evidencias,
        "camada_b": {"flags": flags, "justificativas": justificativas_b},
        "camada_c": {
            "vocabulario": c["vocabulario"],
            "estrutura_narrativa": c["estrutura_narrativa"],
            "densidade_tematica": c["densidade_tematica"],
            "extensao": extensao,
            "nivel_leitura": nivel,
            "rotulo_nivel_leitura": rubrica["camada_c"]["nivel_leitura"]["rotulos"][str(nivel)],
            "exigencia_repertorio": list(c.get("exigencia_repertorio") or []),
            "valor_formativo": {
                "nivel": vf["nivel"],
                "marcadores": list(vf.get("marcadores") or []),
                "justificativa": str(vf.get("justificativa") or "").strip(),
            },
        },
        "procedencia": {
            "fonte_da_analise": procedencia["fonte_da_analise"],
            "confianca": float(procedencia["confianca"]),
            "modelo": procedencia.get("modelo"),
            "fontes": list(procedencia.get("fontes") or []),
            "revisada_por_humano": bool(procedencia.get("revisada_por_humano", False)),
            "revisada_em": procedencia.get("revisada_em"),
        },
        "atualizada_em": (agora or datetime.now(UTC)).isoformat(),
    }


def ficha_para_saida(ficha: dict) -> dict:
    """Converte uma ficha publicada de volta ao formato de entrada (usado pela revisão)."""
    return {
        "camada_a": {
            e: {"nivel": v["nivel"], "justificativa": v["justificativa"]}
            for e, v in ficha["camada_a"].items()
        },
        "evidencias": copy.deepcopy(ficha["evidencias"]),
        "camada_b": copy.deepcopy(ficha["camada_b"]),
        "camada_c": {
            "vocabulario": ficha["camada_c"]["vocabulario"],
            "estrutura_narrativa": ficha["camada_c"]["estrutura_narrativa"],
            "densidade_tematica": ficha["camada_c"]["densidade_tematica"],
            "exigencia_repertorio": list(ficha["camada_c"]["exigencia_repertorio"]),
            "valor_formativo": copy.deepcopy(ficha["camada_c"]["valor_formativo"]),
        },
        "confianca": ficha["procedencia"]["confianca"],
        "observacoes": "",
    }
