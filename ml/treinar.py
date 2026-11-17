"""Ajuste fino contrastivo do DINOv2 para capas (seção 5, item 4). PREPARADO, NÃO EXECUTADO.

Não rodou neste ambiente: os pesos do DINOv2 (Hugging Face) e o PyTorch não puderam ser
baixados. O script segue a receita abaixo e foi escrito para rodar numa máquina com GPU.

Receita:
  - Pares positivos: a capa limpa e uma foto simulada dela (ml/distorcoes.py), e as amostras
    reais consentidas (amostras_reconhecimento com obra confirmada ou corrigida).
  - Negativos: as outras capas do lote (InfoNCE simétrico com negativos do próprio lote).
  - Negativos difíceis: o amostrador monta lotes que juntam edições diferentes da mesma
    obra e volumes da mesma série, que são os erros que importam.
  - Edições da mesma obra são tratadas como positivos entre si (a resposta certa é a obra).
  - Exporta com save_pretrained em ml/modelos/<nome>, formato que o adaptador `Dinov2`
    carrega via MODELO_CAPA=dinov2 MODELO_CAPA_PESOS_LOCAIS=ml/modelos/<nome>.
  - Depois: reindexar (ml/indexar.py) e comparar com a base (ml/avaliar.py) ANTES de trocar.

Dependências extras: pip install -e "backend[ml]"  (torch, torchvision, transformers)

Uso:
    PYTHONPATH=backend python ml/treinar.py --epocas 10 --lote 32 --saida ml/modelos/capas-v1
"""

from __future__ import annotations

import argparse
import json
import random
import sys
from collections import defaultdict
from pathlib import Path

import numpy as np
from PIL import Image

RAIZ = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RAIZ / "ml"))
sys.path.insert(0, str(RAIZ / "backend"))

from distorcoes import foto_simulada  # noqa: E402

DADOS = RAIZ / "ml" / "dados"


def carregar_exemplos(incluir_amostras: bool) -> list[dict]:
    """[{"capa": caminho, "obra": rótulo, "grupo": série/obra, "fotos": [caminhos reais]}]"""
    exemplos = []
    manifesto = DADOS / "sinteticas" / "manifesto.json"
    if manifesto.exists():
        for item in json.loads(manifesto.read_text()):
            exemplos.append(
                {
                    "capa": DADOS / "sinteticas" / item["arquivo"],
                    "obra": item["obra"],
                    "grupo": item["grupo"],
                    "fotos": [],
                }
            )
    catalogo = DADOS / "catalogo"  # capas reais baixadas por quem roda o treino (licença!)
    if catalogo.exists():
        for meta in catalogo.glob("*.json"):
            info = json.loads(meta.read_text())
            exemplos.append(
                {
                    "capa": catalogo / info["arquivo"],
                    "obra": info["obra_id"],
                    "grupo": info.get("serie") or info["obra_id"],
                    "fotos": [],
                }
            )
    if incluir_amostras:
        exemplos += _amostras_consentidas()
    return exemplos


def _amostras_consentidas() -> list[dict]:
    from sqlalchemy import select

    from app.db import fabrica_sessao
    from app.modelos import AmostraReconhecimento, Edicao
    from app.servicos import armazenamento

    porobra: dict[str, list] = defaultdict(list)
    with fabrica_sessao()() as s:
        for a in s.scalars(select(AmostraReconhecimento)):
            obra = a.obra_corrigida_id or (a.resultado or {}).get("obra_id")
            if obra:
                porobra[str(obra)].append(a.caminho_imagem)
        exemplos = []
        for obra_id, caminhos in porobra.items():
            edicao = s.scalars(select(Edicao).where(Edicao.obra_id == obra_id)).first()
            if edicao is None or not edicao.capa_url:
                continue
            destino = DADOS / "cache" / f"{obra_id}.jpg"
            destino.parent.mkdir(parents=True, exist_ok=True)
            fotos = []
            for i, c in enumerate(caminhos):
                f = DADOS / "cache" / f"{obra_id}_{i}.jpg"
                f.write_bytes(armazenamento.obter().ler(c))
                fotos.append(f)
            exemplos.append(
                {
                    "capa": None,
                    "capa_url": edicao.capa_url,
                    "obra": obra_id,
                    "grupo": obra_id,
                    "fotos": fotos,
                }
            )
    return [e for e in exemplos if e.get("capa")]


class AmostradorDificil:
    """Lotes que juntam itens do mesmo grupo (série/edições) com itens aleatórios."""

    def __init__(self, exemplos: list[dict], lote: int, seed: int = 0):
        self.exemplos, self.lote = exemplos, lote
        self.rng = random.Random(seed)
        self.por_grupo: dict[str, list[int]] = defaultdict(list)
        for i, e in enumerate(exemplos):
            self.por_grupo[e["grupo"]].append(i)

    def __iter__(self):
        indices = list(range(len(self.exemplos)))
        self.rng.shuffle(indices)
        usados: set[int] = set()
        lote: list[int] = []
        for i in indices:
            if i in usados:
                continue
            irmaos = [j for j in self.por_grupo[self.exemplos[i]["grupo"]] if j not in usados]
            for j in irmaos[: self.lote - len(lote)]:
                lote.append(j)
                usados.add(j)
            if len(lote) >= self.lote:
                yield lote
                lote = []
        if len(lote) > 1:
            yield lote


def treinar(args) -> None:
    import torch
    import torch.nn.functional as F
    from transformers import AutoImageProcessor, AutoModel

    dispositivo = "cuda" if torch.cuda.is_available() else "cpu"
    processador = AutoImageProcessor.from_pretrained(args.base)
    modelo = AutoModel.from_pretrained(args.base).to(dispositivo)
    otimizador = torch.optim.AdamW(modelo.parameters(), lr=args.lr, weight_decay=0.05)
    exemplos = carregar_exemplos(args.incluir_amostras)
    if len(exemplos) < 8:
        sys.exit("Exemplos insuficientes. Gere capas sintéticas ou adicione o catálogo.")
    rng = np.random.default_rng(args.semente)
    temperatura = 0.07

    def emb(imagens):
        x = processador(images=imagens, return_tensors="pt").to(dispositivo)
        saida = modelo(**x).last_hidden_state
        v = torch.cat([saida[:, 0], saida[:, 1:].mean(dim=1)], dim=1)
        return F.normalize(v, dim=-1)

    for epoca in range(args.epocas):
        modelo.train()
        perdas = []
        for lote in AmostradorDificil(exemplos, args.lote, seed=epoca):
            capas, fotos, rotulos = [], [], []
            for i in lote:
                e = exemplos[i]
                capa = Image.open(e["capa"]).convert("RGB")
                foto = (
                    Image.open(rng.choice(e["fotos"])).convert("RGB")
                    if e["fotos"] and rng.random() < 0.5
                    else foto_simulada(capa, rng)[0]
                )
                capas.append(capa)
                fotos.append(foto)
                rotulos.append(e["obra"])
            a, b = emb(capas), emb(fotos)
            logits = a @ b.T / temperatura
            # Edições da mesma obra contam como positivas entre si.
            alvo = torch.tensor(
                [[float(x == y) for y in rotulos] for x in rotulos], device=dispositivo
            )
            alvo = alvo / alvo.sum(dim=1, keepdim=True)
            perda = (
                -(alvo * F.log_softmax(logits, dim=1)).sum(1).mean()
                - (alvo.T * F.log_softmax(logits.T, dim=1)).sum(1).mean()
            ) / 2
            otimizador.zero_grad()
            perda.backward()
            otimizador.step()
            perdas.append(float(perda))
        print(f"época {epoca + 1}/{args.epocas} perda média {np.mean(perdas):.4f}")

    saida = Path(args.saida)
    saida.mkdir(parents=True, exist_ok=True)
    modelo.save_pretrained(saida)
    processador.save_pretrained(saida)
    (saida / "TREINO.json").write_text(json.dumps(vars(args), default=str, indent=2))
    print(f"Modelo salvo em {saida}. Próximos passos: reindexar e rodar ml/avaliar.py com")
    print(f"  MODELO_CAPA=dinov2 MODELO_CAPA_PESOS_LOCAIS={saida}")


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--base", default="facebook/dinov2-small")
    p.add_argument("--epocas", type=int, default=10)
    p.add_argument("--lote", type=int, default=32)
    p.add_argument("--lr", type=float, default=1e-5)
    p.add_argument("--semente", type=int, default=0)
    p.add_argument(
        "--incluir-amostras",
        action="store_true",
        help="usa as imagens consentidas de amostras_reconhecimento",
    )
    p.add_argument("--saida", default="ml/modelos/capas-v1")
    treinar(p.parse_args())
