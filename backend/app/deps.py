"""Fábricas de provedores usadas como dependências FastAPI (substituíveis nos testes)."""

from __future__ import annotations

from functools import lru_cache

import httpx

from app.config import configuracoes
from app.provedores.metadados import Cascata, cascata_padrao


@lru_cache
def _cliente_http() -> httpx.Client:
    return httpx.Client(headers={"User-Agent": "Entrelinhas/0.1 (+orientacao de leitura)"})


def obter_cascata() -> Cascata | None:
    cfg = configuracoes()
    if not cfg.fontes_metadados.strip():
        return None
    return cascata_padrao(cfg.fontes_metadados, _cliente_http(), cfg.google_books_api_key)


def obter_cliente_http() -> httpx.Client:
    return _cliente_http()


def obter_fontes_resenhas() -> list:
    from app.provedores.resenhas import Wikipedia

    nomes = [n.strip() for n in configuracoes().fontes_resenhas.split(",") if n.strip()]
    fontes = []
    for nome in nomes:
        if nome == "wikipedia_pt":
            fontes.append(Wikipedia(_cliente_http()))
    return fontes
