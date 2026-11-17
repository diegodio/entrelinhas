"""Modelos de embedding de capa (seção 5).

- `Dinov2`: DINOv2 pré-treinado (Hugging Face transformers), CPU por padrão, GPU quando
  houver. Licença Apache 2.0. Escrito, mas NÃO exercitado neste ambiente: os pesos não
  puderam ser baixados (rede bloqueada para o Hugging Face). Ver docs/reconhecimento.md.
- `Histograma`: modelo-base sem rede neural (cor HSV + estrutura em tons de cinza). Serve
  de linha de base mensurável e de reserva quando o DINOv2 não está instalado.
- `CapaFalsa`: determinístico, para testes.

Vetores de modelos diferentes nunca são comparados: toda busca filtra por nome e versão.
"""

from __future__ import annotations

import hashlib
from typing import Protocol

import numpy as np
from PIL import Image, ImageOps

from app.config import configuracoes


class ModeloDeCapa(Protocol):
    nome: str
    versao: str

    def embutir(self, imagem: Image.Image) -> np.ndarray: ...


def _normalizar(v: np.ndarray) -> np.ndarray:
    n = float(np.linalg.norm(v))
    return (v / n).astype(np.float32) if n > 0 else v.astype(np.float32)


class Histograma:
    nome = "histograma"
    versao = "1"

    def embutir(self, imagem: Image.Image) -> np.ndarray:
        rgb = ImageOps.exif_transpose(imagem).convert("RGB")
        # Cor: histograma HSV 8x4x4, robusto a pequenas mudanças de enquadramento.
        hsv = np.asarray(rgb.resize((96, 144)).convert("HSV"), dtype=np.int32)
        h = (hsv[..., 0] * 8) // 256
        s = (hsv[..., 1] * 4) // 256
        v = (hsv[..., 2] * 4) // 256
        hist = np.bincount((h * 16 + s * 4 + v).ravel(), minlength=128).astype(np.float32)
        hist = np.sqrt(hist / hist.sum())
        # Estrutura: miniatura 12x18 em tons de cinza, centrada e equalizada.
        cinza = np.asarray(ImageOps.equalize(rgb.convert("L")).resize((12, 18)), dtype=np.float32)
        cinza = (cinza - cinza.mean()) / (cinza.std() + 1e-6)
        return _normalizar(np.concatenate([hist * 2.0, cinza.ravel() / 15.0]))


class Dinov2:
    def __init__(self, nome_modelo: str, pesos_locais: str = ""):
        import torch
        from transformers import AutoImageProcessor, AutoModel

        origem = pesos_locais or nome_modelo
        self.nome = nome_modelo if not pesos_locais else f"{nome_modelo}+ajustado"
        self.versao = "local" if pesos_locais else "1"
        self.dispositivo = "cuda" if torch.cuda.is_available() else "cpu"
        self.processador = AutoImageProcessor.from_pretrained(origem)
        self.modelo = AutoModel.from_pretrained(origem).to(self.dispositivo).eval()
        self._torch = torch

    def embutir(self, imagem: Image.Image) -> np.ndarray:
        entradas = self.processador(images=imagem.convert("RGB"), return_tensors="pt").to(
            self.dispositivo
        )
        with self._torch.no_grad():
            saida = self.modelo(**entradas)
        # Token CLS concatenado à média dos tokens de patch (prática comum para recuperação).
        cls = saida.last_hidden_state[:, 0]
        media = saida.last_hidden_state[:, 1:].mean(dim=1)
        v = self._torch.cat([cls, media], dim=1)[0].cpu().numpy()
        return _normalizar(v)


class CapaFalsa:
    nome = "falso"
    versao = "1"

    def embutir(self, imagem: Image.Image) -> np.ndarray:
        miniatura = np.asarray(imagem.convert("L").resize((8, 8)), dtype=np.uint8).tobytes()
        semente = int.from_bytes(hashlib.sha256(miniatura).digest()[:4], "big")
        return _normalizar(np.random.default_rng(semente).standard_normal(64))


_cache: dict[str, ModeloDeCapa] = {}


def obter_modelo_capa() -> ModeloDeCapa:
    cfg = configuracoes()
    chave = f"{cfg.modelo_capa}|{cfg.modelo_capa_nome}|{cfg.modelo_capa_pesos_locais}"
    if chave not in _cache:
        if cfg.modelo_capa == "dinov2":
            _cache[chave] = Dinov2(cfg.modelo_capa_nome, cfg.modelo_capa_pesos_locais)
        elif cfg.modelo_capa == "falso":
            _cache[chave] = CapaFalsa()
        else:
            _cache[chave] = Histograma()
    return _cache[chave]
