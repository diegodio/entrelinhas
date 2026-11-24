"""Identificação do livro pelo código de barras (EAN-13 / ISBN).

Escopo atual: só código de barras. O reconhecimento pela capa (OCR + modelo de imagem)
foi retirado por enquanto; o histórico do git guarda a versão anterior.
"""

from __future__ import annotations

import time
import uuid
from dataclasses import dataclass

from PIL import Image
from sqlalchemy.orm import Session

from app.core import isbn as isbn_util
from app.provedores.metadados import Cascata
from app.reconhecimento.imagem import ler_codigo
from app.servicos import obras as obras_servico


@dataclass
class Resultado:
    # identificado | nao_identificado (ISBN lido, livro fora do catálogo)
    # | nao_e_livro (EAN de produto) | sem_codigo (nenhum código legível)
    status: str
    obra_id: uuid.UUID | None = None
    isbn: str | None = None
    tempo_ms: int = 0


def reconhecer(
    sessao: Session,
    imagem: Image.Image | None,
    isbn_cliente: str | None,
    cascata: Cascata | None,
) -> Resultado:
    inicio = time.perf_counter()

    def pronto(r: Resultado) -> Resultado:
        r.tempo_ms = int((time.perf_counter() - inicio) * 1000)
        return r

    def por_isbn(i13: str) -> Resultado:
        obra, _ = obras_servico.buscar_por_isbn(sessao, i13, cascata)
        if obra is not None:
            return pronto(Resultado("identificado", obra.id, isbn=i13))
        return pronto(Resultado("nao_identificado", isbn=i13))

    # 1. ISBN lido pelo aparelho: conferido aqui (dígito e prefixo de livro).
    if isbn_cliente:
        i13 = isbn_util.validar(isbn_cliente)
        if i13 and isbn_util.e_ean_de_livro(i13):
            return por_isbn(i13)

    # 2. Código de barras na foto.
    if imagem is None:
        return pronto(Resultado("sem_codigo"))
    leitura = ler_codigo(imagem)
    if leitura.isbn13:
        return por_isbn(leitura.isbn13)
    if leitura.nao_e_livro:
        return pronto(Resultado("nao_e_livro"))
    return pronto(Resultado("sem_codigo"))
