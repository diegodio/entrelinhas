"""A expressão do sistema oficial não aparece em nenhum texto do produto (princípio 2)."""

import re
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]
PROIBIDA = re.compile(r"classifica[cç][aã]o\s+indicativa", re.IGNORECASE)


def arquivos_de_texto():
    yield from (RAIZ / "backend" / "app").rglob("*.py")
    yield from (RAIZ / "app" / "lib").rglob("*.arb")
    yield from (RAIZ / "app" / "lib").rglob("*.dart")


def test_expressao_proibida_ausente():
    arquivos = list(arquivos_de_texto())
    assert len(arquivos) > 20
    encontrados = [str(a) for a in arquivos if PROIBIDA.search(a.read_text(encoding="utf-8"))]
    assert encontrados == []


def test_aviso_de_independencia_presente():
    from app.core import textos

    assert "sem vínculo com o Ministério da Justiça" in textos.AVISO_INDEPENDENCIA
    assert "ClassInd" in textos.AVISO_INDEPENDENCIA
