"""Acesso à Rubrica Entrelinhas. A rubrica é dado: tudo o que o código precisa sai do JSON."""

from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path

CAMINHO_RUBRICA = Path(__file__).with_name("rubrica_v1.json")
IDS_EIXOS = ("A1", "A2", "A3", "A4", "A5", "A6")
NIVEIS_VALIDOS = range(0, 5)


@lru_cache(maxsize=1)
def carregar_rubrica() -> dict:
    with CAMINHO_RUBRICA.open(encoding="utf-8") as arquivo:
        rubrica = json.load(arquivo)
    ids = tuple(e["id"] for e in rubrica["camada_a"]["eixos"])
    if ids != IDS_EIXOS:
        raise ValueError(f"Rubrica com eixos inesperados: {ids}")
    return rubrica


def eixo_por_id(rubrica: dict, eixo_id: str) -> dict:
    for eixo in rubrica["camada_a"]["eixos"]:
        if eixo["id"] == eixo_id:
            return eixo
    raise KeyError(eixo_id)


def faixas_ordenadas(rubrica: dict | None = None) -> list[str]:
    return list((rubrica or carregar_rubrica())["faixas_ordenadas"])


def nivel_regra_dura_a5(rubrica: dict | None = None) -> int:
    """Lê o limiar da regra dura do A5 ("nivel >= 3") da própria rubrica."""
    condicao = eixo_por_id(rubrica or carregar_rubrica(), "A5")["regra_dura"]["condicao"]
    operador, valor = condicao.replace("nivel", "").split()
    if operador != ">=":
        raise ValueError(f"Condição da regra dura não suportada: {condicao!r}")
    return int(valor)
