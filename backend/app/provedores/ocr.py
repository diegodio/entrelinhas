"""Motores de OCR (seção 4.7). Devolvem linhas de texto com a altura aproximada da letra,
para que as maiores linhas virem candidatas a título e autor."""

from __future__ import annotations

import base64
import io
from dataclasses import dataclass
from typing import Protocol

import httpx
from PIL import Image

from app.config import configuracoes


@dataclass
class LinhaOcr:
    texto: str
    altura: float
    confianca: float


class MotorOcr(Protocol):
    nome: str

    def ler(self, imagem: Image.Image) -> list[LinhaOcr]: ...


class Tesseract:
    """Tesseract local (código aberto). Requer o binário e os idiomas por+eng instalados."""

    nome = "tesseract"

    def ler(self, imagem: Image.Image) -> list[LinhaOcr]:
        import pytesseract

        cinza = imagem.convert("L")
        dados = pytesseract.image_to_data(
            cinza, lang="por+eng", config="--psm 11", output_type=pytesseract.Output.DICT
        )
        linhas: dict[tuple, list[int]] = {}
        for i, texto in enumerate(dados["text"]):
            if texto.strip() and float(dados["conf"][i]) > 30:
                chave = (dados["block_num"][i], dados["par_num"][i], dados["line_num"][i])
                linhas.setdefault(chave, []).append(i)
        resultado = []
        for idx in linhas.values():
            palavras = [dados["text"][i] for i in idx]
            altura = sum(dados["height"][i] for i in idx) / len(idx)
            conf = sum(float(dados["conf"][i]) for i in idx) / len(idx) / 100
            resultado.append(LinhaOcr(" ".join(palavras), altura, conf))
        return sorted(resultado, key=lambda linha: -linha.altura)


class GoogleVision:
    """Google Cloud Vision (TEXT_DETECTION). Escrito pela documentação; não exercitado aqui."""

    nome = "google_vision"

    def __init__(self, chave: str, cliente: httpx.Client | None = None):
        self.chave = chave
        self.cliente = cliente or httpx.Client(timeout=10)

    def ler(self, imagem: Image.Image) -> list[LinhaOcr]:
        buffer = io.BytesIO()
        imagem.convert("RGB").save(buffer, format="JPEG", quality=90)
        r = self.cliente.post(
            "https://vision.googleapis.com/v1/images:annotate",
            params={"key": self.chave},
            json={"requests": [{
                "image": {"content": base64.b64encode(buffer.getvalue()).decode()},
                "features": [{"type": "TEXT_DETECTION"}],
            }]},
        )
        r.raise_for_status()
        anotacoes = r.json()["responses"][0].get("textAnnotations", [])[1:]
        resultado = []
        for a in anotacoes:
            ys = [v.get("y", 0) for v in a["boundingPoly"]["vertices"]]
            resultado.append(LinhaOcr(a["description"], max(ys) - min(ys), 0.9))
        return sorted(resultado, key=lambda linha: -linha.altura)


class OcrFalso:
    nome = "falso"

    def __init__(self, linhas: list[str] | None = None):
        self.linhas = linhas or []

    def ler(self, imagem: Image.Image) -> list[LinhaOcr]:
        return [LinhaOcr(t, 100 - i, 0.9) for i, t in enumerate(self.linhas)]


def obter_ocr() -> MotorOcr:
    cfg = configuracoes()
    if cfg.motor_ocr == "google_vision" and cfg.google_vision_api_key:
        return GoogleVision(cfg.google_vision_api_key)
    if cfg.motor_ocr == "falso":
        return OcrFalso()
    return Tesseract()
