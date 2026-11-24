"""Leitura do código de barras numa foto (OpenCV para realce + zxing-cpp)."""

from __future__ import annotations

import io
from dataclasses import dataclass

import cv2
import numpy as np
from PIL import Image, ImageOps

from app.core import isbn as isbn_util


@dataclass
class LeituraCodigo:
    isbn13: str | None  # EAN-13 de livro válido
    codigos_lidos: list[str]  # tudo o que foi decodificado (para depuração)

    @property
    def nao_e_livro(self) -> bool:
        return self.isbn13 is None and any(
            len(c) == 13 and c.isdigit() and isbn_util.valido_13(c) for c in self.codigos_lidos
        )


def carregar(dados: bytes, lado_maximo: int = 1600) -> Image.Image:
    img = ImageOps.exif_transpose(Image.open(io.BytesIO(dados)))
    img = img.convert("RGB")
    img.thumbnail((lado_maximo, lado_maximo))
    return img


def _variacoes(cinza: np.ndarray):
    """Tentativas progressivas quando a primeira leitura falha."""
    yield cinza
    clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8, 8))
    realce = clahe.apply(cinza)
    yield realce
    yield cv2.resize(realce, None, fx=2, fy=2, interpolation=cv2.INTER_CUBIC)
    _, binaria = cv2.threshold(realce, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    yield binaria
    for rot in (cv2.ROTATE_90_CLOCKWISE, cv2.ROTATE_180, cv2.ROTATE_90_COUNTERCLOCKWISE):
        yield cv2.rotate(realce, rot)


def ler_codigo(imagem: Image.Image) -> LeituraCodigo:
    import zxingcpp

    cinza = np.asarray(imagem.convert("L"))
    lidos: list[str] = []
    for variacao in _variacoes(cinza):
        for r in zxingcpp.read_barcodes(variacao):
            texto = r.text.strip()
            if texto and texto not in lidos:
                lidos.append(texto)
            if isbn_util.e_ean_de_livro(texto):
                return LeituraCodigo(texto, lidos)
        if lidos:
            break  # leu algo que não é livro; não adianta insistir
    return LeituraCodigo(None, lidos)
