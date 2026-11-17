"""Leitura de código de barras e localização do livro numa imagem (OpenCV + zxing-cpp)."""

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


def _ordenar_cantos(p: np.ndarray) -> np.ndarray:
    s, d = p.sum(axis=1), np.diff(p, axis=1).ravel()
    return np.array(
        [p[np.argmin(s)], p[np.argmin(d)], p[np.argmax(s)], p[np.argmax(d)]], dtype=np.float32
    )


def localizar_livro(imagem: Image.Image, area_minima: float = 0.12) -> Image.Image:
    """Acha o maior quadrilátero plausível (a capa) e corrige a perspectiva.

    Se nada convincente aparecer, devolve a imagem inteira: o recorte é uma ajuda, não um
    requisito.
    """
    bgr = cv2.cvtColor(np.asarray(imagem), cv2.COLOR_RGB2BGR)
    altura, largura = bgr.shape[:2]
    escala = 800 / max(altura, largura)
    pequena = cv2.resize(bgr, None, fx=escala, fy=escala) if escala < 1 else bgr.copy()
    escala = min(escala, 1.0)
    cinza = cv2.GaussianBlur(cv2.cvtColor(pequena, cv2.COLOR_BGR2GRAY), (5, 5), 0)
    bordas = cv2.dilate(cv2.Canny(cinza, 40, 120), np.ones((3, 3), np.uint8), iterations=2)
    contornos, _ = cv2.findContours(bordas, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    area_total = pequena.shape[0] * pequena.shape[1]
    melhor = None
    for c in sorted(contornos, key=cv2.contourArea, reverse=True)[:8]:
        area = cv2.contourArea(c)
        if area < area_minima * area_total or area > 0.98 * area_total:
            continue
        aprox = cv2.approxPolyDP(c, 0.03 * cv2.arcLength(c, True), True)
        if len(aprox) == 4 and cv2.isContourConvex(aprox):
            melhor = aprox.reshape(4, 2).astype(np.float32) / escala
            break
    if melhor is None:
        return imagem
    cantos = _ordenar_cantos(melhor)
    larg = int(max(np.linalg.norm(cantos[0] - cantos[1]), np.linalg.norm(cantos[3] - cantos[2])))
    alt = int(max(np.linalg.norm(cantos[0] - cantos[3]), np.linalg.norm(cantos[1] - cantos[2])))
    if larg < 40 or alt < 40:
        return imagem
    destino = np.array([[0, 0], [larg, 0], [larg, alt], [0, alt]], dtype=np.float32)
    matriz = cv2.getPerspectiveTransform(cantos, destino)
    corrigida = cv2.warpPerspective(np.asarray(imagem), matriz, (larg, alt))
    return Image.fromarray(corrigida)
