"""Distorções sintéticas que imitam uma foto de livro tirada numa livraria (seção 5, item 3).

perspectiva, reflexo, desfoque, pouca luz, oclusão por dedos e etiqueta de preço, além de
colocar a capa sobre um fundo. Todas determinísticas dado o gerador aleatório.
"""

from __future__ import annotations

import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter


def sobre_fundo(
    capa: Image.Image, rng: np.random.Generator, perspectiva: float = 0.12
) -> Image.Image:
    c = np.asarray(capa.convert("RGB"))
    h, w = c.shape[:2]
    lado = int(max(h, w) * 1.5)
    cor = rng.integers(40, 200, 3)
    fundo = np.clip(np.full((lado, lado, 3), cor) + rng.normal(0, 12, (lado, lado, 3)), 0, 255)
    fundo = cv2.GaussianBlur(fundo.astype(np.uint8), (7, 7), 0)
    ox, oy = (lado - w) / 2, (lado - h) / 2
    j = lambda: rng.uniform(-perspectiva, perspectiva) * w  # noqa: E731
    src = np.float32([[0, 0], [w, 0], [w, h], [0, h]])
    dst = np.float32(
        [
            [ox + j(), oy + j()],
            [ox + w + j(), oy + j()],
            [ox + w + j(), oy + h + j()],
            [ox + j(), oy + h + j()],
        ]
    )
    m = cv2.getPerspectiveTransform(src, dst)
    saida = cv2.warpPerspective(
        c, m, (lado, lado), dst=fundo.copy(), borderMode=cv2.BORDER_TRANSPARENT
    )
    return Image.fromarray(saida)


def reflexo(img: Image.Image, rng: np.random.Generator) -> Image.Image:
    img = img.copy()
    w, h = img.size
    d = ImageDraw.Draw(img, "RGBA")
    x, y = rng.uniform(0.1, 0.7) * w, rng.uniform(0.1, 0.7) * h
    d.ellipse([x, y, x + w * 0.35, y + h * 0.15], fill=(255, 255, 255, int(rng.uniform(60, 140))))
    return img.filter(ImageFilter.GaussianBlur(0.6))


def desfoque(img: Image.Image, rng: np.random.Generator) -> Image.Image:
    return img.filter(ImageFilter.GaussianBlur(rng.uniform(1.5, 3.5)))


def pouca_luz(img: Image.Image, rng: np.random.Generator) -> Image.Image:
    escura = ImageEnhance.Brightness(img).enhance(rng.uniform(0.3, 0.55))
    arr = np.asarray(escura).astype(np.float32)
    arr += rng.normal(0, 8, arr.shape)  # ruído de sensor
    return Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8))


def oclusao_dedo(img: Image.Image, rng: np.random.Generator) -> Image.Image:
    img = img.copy()
    w, h = img.size
    d = ImageDraw.Draw(img)
    pele = tuple(int(v) for v in rng.integers([170, 120, 90], [235, 185, 150]))
    lado = rng.choice([0, 1])
    x = 0 if lado == 0 else w - w * 0.18
    y = rng.uniform(0.3, 0.7) * h
    d.rounded_rectangle([x, y, x + w * 0.18, y + h * 0.09], radius=int(h * 0.04), fill=pele)
    return img


def etiqueta_preco(img: Image.Image, rng: np.random.Generator) -> Image.Image:
    img = img.copy()
    w, h = img.size
    d = ImageDraw.Draw(img)
    x, y = rng.uniform(0.05, 0.6) * w, rng.uniform(0.05, 0.85) * h
    d.rectangle([x, y, x + w * 0.3, y + h * 0.07], fill=(250, 250, 245), outline=(200, 30, 30))
    d.text((x + 6, y + 4), f"R$ {rng.integers(20, 90)},90", fill=(200, 30, 30))
    return img


DISTORCOES = {
    "reflexo": reflexo,
    "desfoque": desfoque,
    "pouca_luz": pouca_luz,
    "oclusao_dedo": oclusao_dedo,
    "etiqueta_preco": etiqueta_preco,
}


def foto_simulada(
    capa: Image.Image, rng: np.random.Generator, n_distorcoes: int = 2
) -> tuple[Image.Image, list[str]]:
    """Capa sobre fundo, em perspectiva, com n distorções sorteadas."""
    nomes = list(rng.choice(list(DISTORCOES), size=n_distorcoes, replace=False))
    img = capa.convert("RGB")
    for nome in nomes:
        if nome in ("oclusao_dedo", "etiqueta_preco"):
            img = DISTORCOES[nome](img, rng)
    img = sobre_fundo(img, rng)
    for nome in nomes:
        if nome not in ("oclusao_dedo", "etiqueta_preco"):
            img = DISTORCOES[nome](img, rng)
    img.thumbnail((1024, 1024))
    return img, ["perspectiva", *nomes]
