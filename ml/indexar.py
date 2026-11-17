"""Índice de capas (seção 5, item 2).

Percorre as edições do catálogo, obtém a capa pela URL de origem, gera o embedding com o
modelo configurado (MODELO_CAPA) e grava em `capas` com nome e versão do modelo. Guarda
só o vetor e a URL: a imagem é usada na hora e descartada.

Reindexar depois de trocar de modelo é este mesmo comando. Vetores de modelos diferentes
convivem na tabela e nunca são comparados entre si.

Uso (a partir da raiz do repositório):
    PYTHONPATH=backend backend/.venv/bin/python ml/indexar.py [--somente-faltantes]
"""

from __future__ import annotations

import argparse
import io
import sys
from pathlib import Path

import httpx
from PIL import Image
from sqlalchemy import select

RAIZ = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RAIZ / "backend"))

from app.db import fabrica_sessao  # noqa: E402
from app.modelos import Capa, Edicao  # noqa: E402
from app.provedores.modelo_capa import obter_modelo_capa  # noqa: E402
from app.reconhecimento.servico import indexar_capa  # noqa: E402

PASTA_ESTATICA = RAIZ / "backend" / "app"


def abrir_capa(url: str, cliente: httpx.Client) -> Image.Image:
    if url.startswith("/estatico/"):
        return Image.open(PASTA_ESTATICA / url.lstrip("/")).convert("RGB")
    r = cliente.get(url, timeout=15, follow_redirects=True)
    r.raise_for_status()
    return Image.open(io.BytesIO(r.content)).convert("RGB")


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument(
        "--somente-faltantes",
        action="store_true",
        help="pula edições que já têm vetor deste modelo",
    )
    args = p.parse_args()
    modelo = obter_modelo_capa()
    cliente = httpx.Client(headers={"User-Agent": "Entrelinhas/0.1 (indexacao de capas)"})
    ok = falhas = pulados = 0
    with fabrica_sessao()() as sessao:
        edicoes = sessao.scalars(select(Edicao).where(Edicao.capa_url.is_not(None))).all()
        for e in edicoes:
            if args.somente_faltantes and sessao.scalar(
                select(Capa.id).where(
                    Capa.edicao_id == e.id,
                    Capa.modelo == modelo.nome,
                    Capa.versao_modelo == modelo.versao,
                )
            ):
                pulados += 1
                continue
            try:
                indexar_capa(sessao, e, abrir_capa(e.capa_url, cliente), modelo, e.capa_url)
                ok += 1
            except Exception as erro:  # uma capa ruim não interrompe o resto
                falhas += 1
                print(f"falhou {e.id} ({e.capa_url}): {erro}", file=sys.stderr)
    print(f"modelo={modelo.nome}/{modelo.versao} indexadas={ok} puladas={pulados} falhas={falhas}")


if __name__ == "__main__":
    main()
