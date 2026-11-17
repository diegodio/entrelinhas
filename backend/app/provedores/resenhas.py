"""Fontes de resenhas e descrições públicas (seção 4.4, passo 1).

Só entram fontes cujos termos permitem o uso. A padrão é a Wikipédia em português
(texto sob CC BY-SA, com atribuição pela URL registrada em fontes_da_ficha). Outras
fontes podem ser adicionadas implementando FonteDeResenhas.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol

import httpx


@dataclass
class Resenha:
    texto: str
    url: str
    fonte: str
    licenca: str


class FonteDeResenhas(Protocol):
    nome: str

    def buscar(self, titulo: str, autores: list[str]) -> list[Resenha]: ...


class Wikipedia:
    nome = "wikipedia_pt"
    API = "https://pt.wikipedia.org/w/api.php"

    def __init__(self, cliente: httpx.Client):
        self.cliente = cliente

    def buscar(self, titulo: str, autores: list[str]) -> list[Resenha]:
        consulta = f'"{titulo}" {autores[0] if autores else ""} livro'.strip()
        try:
            r = self.cliente.get(
                self.API,
                params={
                    "action": "query",
                    "list": "search",
                    "srsearch": consulta,
                    "srlimit": 3,
                    "format": "json",
                },
                timeout=6,
            )
            r.raise_for_status()
            achados = r.json().get("query", {}).get("search", [])
        except (httpx.HTTPError, ValueError):
            return []
        titulo_baixo = titulo.lower()
        resultado = []
        for a in achados:
            # Só aceita página cujo título contém o título da obra (evita homônimos).
            if titulo_baixo not in a.get("title", "").lower():
                continue
            try:
                r = self.cliente.get(
                    self.API,
                    params={
                        "action": "query",
                        "prop": "extracts",
                        "explaintext": 1,
                        "exsectionformat": "plain",
                        "pageids": a["pageid"],
                        "format": "json",
                    },
                    timeout=6,
                )
                r.raise_for_status()
                pagina = next(iter(r.json()["query"]["pages"].values()))
            except (httpx.HTTPError, ValueError, KeyError, StopIteration):
                continue
            texto = (pagina.get("extract") or "").strip()
            if len(texto) > 200:
                resultado.append(
                    Resenha(
                        texto=texto[:12000],
                        url=f"https://pt.wikipedia.org/?curid={a['pageid']}",
                        fonte="Wikipédia (pt)",
                        licenca="CC BY-SA 4.0",
                    )
                )
            break
        return resultado


class SemResenhas:
    nome = "nenhuma"

    def buscar(self, titulo: str, autores: list[str]) -> list[Resenha]:
        return []
