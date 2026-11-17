"""Gera capas FICTÍCIAS para avaliar o reconhecimento sem depender de imagens de terceiros.

Inclui de propósito os casos difíceis da seção 5: edições diferentes da mesma obra (mesmo
título, capas diferentes) e volumes de uma série (capas quase iguais, títulos parecidos).

Uso: python ml/gerar_capas_sinteticas.py [--quantidade 60]
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

PASTA = Path(__file__).parent / "dados" / "sinteticas"

PALAVRAS = [
    "Jardim",
    "Rio",
    "Farol",
    "Relógio",
    "Vento",
    "Ilha",
    "Casa",
    "Noite",
    "Mapa",
    "Sombra",
    "Fogo",
    "Pássaro",
    "Cidade",
    "Mar",
    "Lanterna",
    "Ponte",
    "Estrela",
    "Vidro",
    "Floresta",
    "Inverno",
    "Segredo",
    "Caderno",
    "Trem",
    "Lua",
]
COMPLEMENTOS = [
    "Escondido",
    "de Vidro",
    "do Sul",
    "Perdido",
    "de Papel",
    "Azul",
    "das Águas",
    "sem Nome",
    "do Norte",
    "de Prata",
    "Distante",
    "Antigo",
]
NOMES = [
    "Ana",
    "Bruno",
    "Carla",
    "Diego",
    "Elisa",
    "Fábio",
    "Gabriela",
    "Hugo",
    "Isabel",
    "João",
    "Lívia",
    "Marcos",
    "Nina",
    "Otávio",
    "Paula",
    "Rafael",
    "Sofia",
    "Tiago",
]
SOBRENOMES = [
    "Alves",
    "Barros",
    "Costa",
    "Duarte",
    "Esteves",
    "Ferraz",
    "Gomes",
    "Lima",
    "Moraes",
    "Nogueira",
    "Prates",
    "Queiroz",
    "Rocha",
    "Siqueira",
    "Teixeira",
]


def _fonte(tamanho: int, serifa: bool = True):
    candidatos = (
        ["/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf"]
        if serifa
        else ["/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"]
    )
    for c in candidatos:
        if Path(c).exists():
            return ImageFont.truetype(c, tamanho)
    return ImageFont.load_default(size=tamanho)


def desenhar(titulo: str, autor: str, rng: np.random.Generator, estilo: int) -> Image.Image:
    fundo = tuple(int(v) for v in rng.integers(20, 200, 3))
    claro = (245, 240, 230)
    img = Image.new("RGB", (600, 900), fundo)
    d = ImageDraw.Draw(img)
    if estilo == 0:
        for i in range(6):
            d.ellipse(
                [150 - i * 20, 450 - i * 20, 450 + i * 20, 750 + i * 20], outline=claro, width=2
            )
    elif estilo == 1:
        for i in range(0, 600, 40):
            d.line([(i, 900), (i + 300, 380)], fill=claro, width=2)
    else:
        cor2 = tuple(int(v) for v in rng.integers(60, 240, 3))
        d.rectangle([0, 520, 600, 900], fill=cor2)
    serifa = _fonte(int(rng.integers(52, 68)))
    y = 100
    for linha in _quebrar(titulo.upper(), serifa, 500, d):
        d.text((300, y), linha, font=serifa, fill=claro, anchor="ma")
        y += int(serifa.size * 1.2)
    d.text((300, 800), autor, font=_fonte(32, serifa=False), fill=claro, anchor="ma")
    return img


def _quebrar(texto, fonte, largura, d):
    linhas, atual = [], ""
    for p in texto.split():
        teste = f"{atual} {p}".strip()
        if d.textlength(teste, font=fonte) <= largura:
            atual = teste
        else:
            linhas.append(atual)
            atual = p
    return [*linhas, atual]


def gerar(quantidade: int, semente: int = 7) -> list[dict]:
    rng = np.random.default_rng(semente)
    PASTA.mkdir(parents=True, exist_ok=True)
    itens: list[dict] = []
    vistos: set[str] = set()
    while len(itens) < quantidade:
        titulo = f"{rng.choice(['O', 'A', 'Os'])} {rng.choice(PALAVRAS)} {rng.choice(COMPLEMENTOS)}"
        if titulo in vistos:
            continue
        vistos.add(titulo)
        autor = f"{rng.choice(NOMES)} {rng.choice(SOBRENOMES)}"
        grupo = f"g{len(itens)}"
        tipo = rng.choice(["simples", "simples", "edicoes", "serie"])
        if tipo == "edicoes":  # mesma obra, duas edições com capas diferentes
            for ed in range(2):
                itens.append(
                    {
                        "titulo": titulo,
                        "autor": autor,
                        "grupo": grupo,
                        "obra": grupo,
                        "edicao": ed,
                        "estilo": int(rng.integers(0, 3)),
                        "caso": "edicoes",
                    }
                )
        elif tipo == "serie":  # volumes: mesma arte, títulos quase iguais, obras diferentes
            estilo = int(rng.integers(0, 3))
            for vol in range(1, 4):
                itens.append(
                    {
                        "titulo": f"{titulo}: Volume {vol}",
                        "autor": autor,
                        "grupo": grupo,
                        "obra": f"{grupo}v{vol}",
                        "edicao": 0,
                        "estilo": estilo,
                        "caso": "serie",
                        "semente_arte": len(itens),
                    }
                )
        else:
            itens.append(
                {
                    "titulo": titulo,
                    "autor": autor,
                    "grupo": grupo,
                    "obra": grupo,
                    "edicao": 0,
                    "estilo": int(rng.integers(0, 3)),
                    "caso": "simples",
                }
            )
    for i, item in enumerate(itens):
        semente_arte = item.get("semente_arte", i)
        if item["caso"] == "serie":  # mesma paleta para todos os volumes
            semente_arte = int(item["grupo"][1:]) * 1000
        img = desenhar(
            item["titulo"], item["autor"], np.random.default_rng(semente_arte), item["estilo"]
        )
        item["arquivo"] = f"capa_{i:03d}.png"
        img.save(PASTA / item["arquivo"])
    (PASTA / "manifesto.json").write_text(json.dumps(itens, ensure_ascii=False, indent=2))
    return itens


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--quantidade", type=int, default=60)
    args = p.parse_args()
    itens = gerar(args.quantidade)
    print(f"{len(itens)} capas em {PASTA}")
