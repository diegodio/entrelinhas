"""Avaliação do reconhecimento (seção 5, item 3).

Mede acerto em primeiro lugar (top-1) e entre os cinco primeiros (top-5) para cada sinal
(capa, OCR) e para a fusão, e varre limiares para produzir a curva de cobertura x precisão
que escolhe `limiar_identificado` e `margem_minima`.

Conjuntos:
  1. Capas sintéticas (ml/gerar_capas_sinteticas.py) com distorções de ml/distorcoes.py.
  2. Fotos reais rotuladas em ml/dados/fotos_reais/ (ver o LEIAME da pasta), se houver.

Roda num banco SEPARADO (padrão: entrelinhas_ml), recriado a cada execução, para não
misturar obras de teste com o catálogo.

Uso (a partir da raiz do repositório):
    PYTHONPATH=backend backend/.venv/bin/python ml/avaliar.py [--fotos-por-capa 3]
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import sys
import time
from pathlib import Path

import numpy as np

RAIZ = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RAIZ / "backend"))
sys.path.insert(0, str(RAIZ / "ml"))
os.environ.setdefault("DATABASE_URL", "postgresql+psycopg://postgres@/entrelinhas_ml?host=/tmp")
os.environ.setdefault("FONTES_METADADOS", "")

from PIL import Image  # noqa: E402

DADOS = RAIZ / "ml" / "dados"
RESULTADOS = RAIZ / "ml" / "resultados"


def preparar_banco():
    from alembic import command
    from alembic.config import Config
    from sqlalchemy import text

    from app.db import motor

    with motor().begin() as c:
        c.execute(text("DROP SCHEMA public CASCADE; CREATE SCHEMA public;"))
    cfg = Config(str(RAIZ / "backend" / "alembic.ini"))
    cfg.set_main_option("script_location", str(RAIZ / "backend" / "migracoes"))
    command.upgrade(cfg, "head")


def carregar_catalogo(sessao, modelo, itens: list[dict]) -> dict[str, str]:
    """Cria obras/edições sintéticas e indexa as capas. Devolve {obra_rotulo: obra_id}."""
    from app.modelos import Edicao, Obra
    from app.reconhecimento.servico import indexar_capa

    ids: dict[str, str] = {}
    for item in itens:
        if item["obra"] not in ids:
            obra = Obra(
                titulo=item["titulo"],
                autores=[item["autor"]],
                autores_texto=item["autor"],
                fonte_metadados="avaliacao",
            )
            sessao.add(obra)
            sessao.flush()
            ids[item["obra"]] = obra.id
        edicao = Edicao(obra_id=ids[item["obra"]], capa_url=item["arquivo"])
        sessao.add(edicao)
        sessao.flush()
        with Image.open(DADOS / "sinteticas" / item["arquivo"]) as img:
            indexar_capa(sessao, edicao, img.convert("RGB"), modelo, item["arquivo"])
    sessao.commit()
    return ids


def consultas_sinteticas(itens, fotos_por_capa: int, semente: int):
    from distorcoes import foto_simulada

    rng = np.random.default_rng(semente)
    for item in itens:
        with Image.open(DADOS / "sinteticas" / item["arquivo"]) as capa:
            for _ in range(fotos_por_capa):
                foto, distorcoes = foto_simulada(capa, rng, n_distorcoes=int(rng.integers(1, 3)))
                yield foto, item["obra"], item["caso"], distorcoes


def consultas_reais():
    """ml/dados/fotos_reais/rotulos.csv: arquivo,titulo (o título deve existir no catálogo
    de avaliação; para o catálogo real, use o modo --banco-real)."""
    pasta = DADOS / "fotos_reais"
    rotulos = pasta / "rotulos.csv"
    if not rotulos.exists():
        return
    with rotulos.open(encoding="utf-8") as f:
        for linha in csv.DictReader(f):
            caminho = pasta / linha["arquivo"]
            if caminho.exists():
                yield Image.open(caminho).convert("RGB"), linha["obra"], "real", ["foto_real"]


def posicao(lista: list, alvo) -> int | None:
    for i, c in enumerate(lista):
        if c == alvo:
            return i
    return None


def medir(sessao, ocr, modelo, consultas, ids, cfg) -> list[dict]:
    from app.reconhecimento.imagem import localizar_livro
    from app.reconhecimento.servico import fundir, pontuar_capa, pontuar_ocr

    registros = []
    for foto, rotulo, caso, distorcoes in consultas:
        inicio = time.perf_counter()
        recorte = localizar_livro(foto)
        linhas = ocr.ler(recorte)
        s_ocr = pontuar_ocr(sessao, linhas, cfg["similaridade_minima_ocr"])
        s_capa = pontuar_capa(sessao, modelo, recorte)
        fundidos = fundir(s_ocr, s_capa, cfg)
        alvo = ids[rotulo]
        registros.append(
            {
                "caso": caso,
                "distorcoes": distorcoes,
                "rank_ocr": posicao(sorted(s_ocr, key=lambda k: -s_ocr[k]), alvo),
                "rank_capa": posicao(sorted(s_capa, key=lambda k: -s_capa[k]), alvo),
                "rank_fusao": posicao([c.obra_id for c in fundidos], alvo),
                "top": fundidos[0].pontuacao if fundidos else 0.0,
                "margem": (
                    fundidos[0].pontuacao - (fundidos[1].pontuacao if len(fundidos) > 1 else 0.0)
                )
                if fundidos
                else 0.0,
                "top_correto": bool(fundidos) and fundidos[0].obra_id == alvo,
                "sim_capa_alvo": s_capa.get(alvo),
                "sim_capa_outras": sorted(
                    (v for k, v in s_capa.items() if k != alvo), reverse=True
                )[:1],
                "ms": int((time.perf_counter() - inicio) * 1000),
            }
        )
    return registros


def resumo(registros: list[dict]) -> dict:
    n = len(registros)

    def taxa(campo, k):
        return round(sum(1 for r in registros if r[campo] is not None and r[campo] < k) / n, 3)

    return {
        "consultas": n,
        "top1": {s: taxa(f"rank_{s}", 1) for s in ("capa", "ocr", "fusao")},
        "top5": {s: taxa(f"rank_{s}", 5) for s in ("capa", "ocr", "fusao")},
        "por_caso": {
            caso: {
                "consultas": len(rs),
                "top1_fusao": round(sum(1 for r in rs if r["rank_fusao"] == 0) / len(rs), 3),
            }
            for caso in sorted({r["caso"] for r in registros})
            for rs in [[r for r in registros if r["caso"] == caso]]
        },
        "tempo_ms_mediana": int(np.median([r["ms"] for r in registros])),
    }


def curva(registros: list[dict], precisao_alvo: float) -> dict:
    """Cobertura e precisão do status "identificado" para cada par (limiar, margem)."""
    pontos = []
    for limiar in np.arange(0.40, 0.96, 0.02):
        for margem in (0.0, 0.05, 0.08, 0.12, 0.16, 0.20, 0.25):
            ident = [r for r in registros if r["top"] >= limiar and r["margem"] >= margem]
            if not ident:
                continue
            precisao = sum(1 for r in ident if r["top_correto"]) / len(ident)
            pontos.append(
                {
                    "limiar": round(float(limiar), 2),
                    "margem": margem,
                    "cobertura": round(len(ident) / len(registros), 3),
                    "precisao": round(precisao, 4),
                }
            )
    aceitaveis = [p for p in pontos if p["precisao"] >= precisao_alvo]
    recomendado = max(aceitaveis, key=lambda p: (p["cobertura"], p["limiar"]), default=None)
    return {"precisao_alvo": precisao_alvo, "recomendado": recomendado, "pontos": pontos}


def piso_capa(registros: list[dict]) -> float:
    """Similaridade típica entre capas DIFERENTES (percentil 95): vira o piso da fusão."""
    outras = [r["sim_capa_outras"][0] for r in registros if r["sim_capa_outras"]]
    return round(float(np.percentile(outras, 95)), 3) if outras else 0.5


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("--fotos-por-capa", type=int, default=3)
    p.add_argument("--semente", type=int, default=11)
    p.add_argument("--precisao-alvo", type=float, default=0.99)
    args = p.parse_args()

    from app.db import fabrica_sessao
    from app.provedores.modelo_capa import obter_modelo_capa
    from app.provedores.ocr import obter_ocr
    from app.servicos import configuracao as cfg_servico

    manifesto = DADOS / "sinteticas" / "manifesto.json"
    if not manifesto.exists():
        sys.exit("Gere as capas antes: python ml/gerar_capas_sinteticas.py")
    itens = json.loads(manifesto.read_text())
    preparar_banco()
    modelo, ocr = obter_modelo_capa(), obter_ocr()
    with fabrica_sessao()() as sessao:
        cfg_servico.semear(sessao)
        cfg = cfg_servico.carregar(sessao)["limites"]["reconhecimento"]
        ids = carregar_catalogo(sessao, modelo, itens)
        # Primeira passada só para calibrar o piso da capa; depois mede com ele.
        amostra = medir(
            sessao, ocr, modelo, consultas_sinteticas(itens[:20], 1, args.semente + 1), ids, cfg
        )
        cfg = {**cfg, "piso_capa": piso_capa(amostra)}
        registros = medir(
            sessao,
            ocr,
            modelo,
            consultas_sinteticas(itens, args.fotos_por_capa, args.semente),
            ids,
            cfg,
        )
        reais = (
            list(medir(sessao, ocr, modelo, consultas_reais(), ids, cfg))
            if (DADOS / "fotos_reais" / "rotulos.csv").exists()
            else []
        )

    relatorio = {
        "modelo_capa": f"{modelo.nome}/{modelo.versao}",
        "ocr": ocr.nome,
        "capas_no_indice": len(itens),
        "piso_capa_calibrado": cfg["piso_capa"],
        "sinteticas": resumo(registros),
        "curva_sinteticas": curva(registros, args.precisao_alvo),
        "fotos_reais": resumo(reais) if reais else "nenhuma foto real rotulada",
    }
    RESULTADOS.mkdir(exist_ok=True)
    destino = RESULTADOS / f"avaliacao_{modelo.nome.replace('/', '_')}.json"
    destino.write_text(json.dumps(relatorio, ensure_ascii=False, indent=2))
    print(
        json.dumps(
            {k: v for k, v in relatorio.items() if k != "curva_sinteticas"},
            ensure_ascii=False,
            indent=2,
        )
    )
    print("recomendado:", relatorio["curva_sinteticas"]["recomendado"])
    print(f"relatório completo: {destino}")


if __name__ == "__main__":
    main()
