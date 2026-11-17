"""Reconhecimento de livro por imagem (seção 4.5): código de barras, OCR e capa, com fusão.

Política: na dúvida, mostrar candidatos em vez de afirmar o livro errado. Pesos e limiares
vivem em `configuracao` (limite.reconhecimento) e são recalibrados com ml/avaliar.py.
"""

from __future__ import annotations

import re
import time
import unicodedata
import uuid
from concurrent.futures import ThreadPoolExecutor
from concurrent.futures import TimeoutError as TempoEsgotado
from dataclasses import dataclass, field

import numpy as np
from PIL import Image
from sqlalchemy import select, text
from sqlalchemy.orm import Session

from app.core import isbn as isbn_util
from app.modelos import Capa, Edicao
from app.provedores.metadados import Cascata
from app.provedores.modelo_capa import ModeloDeCapa
from app.provedores.ocr import LinhaOcr, MotorOcr
from app.reconhecimento.imagem import ler_codigo, localizar_livro
from app.servicos import obras as obras_servico

TEMPO_MAXIMO_OCR = 1.6  # segundos; depois disso a resposta segue sem o OCR
_executor = ThreadPoolExecutor(max_workers=4)


def normalizar_texto(t: str) -> str:
    t = unicodedata.normalize("NFKD", t).encode("ascii", "ignore").decode().lower()
    return re.sub(r"[^a-z0-9 ]+", " ", t).strip()


@dataclass
class Candidato:
    obra_id: uuid.UUID
    ocr: float = 0.0
    capa: float = 0.0
    pontuacao: float = 0.0
    sinais: list[str] = field(default_factory=list)


@dataclass
class Resultado:
    status: str  # identificado | candidatos | nao_identificado | nao_e_livro
    obra_id: uuid.UUID | None = None
    candidatos: list[Candidato] = field(default_factory=list)
    isbn: str | None = None
    texto_ocr: list[str] = field(default_factory=list)
    tempo_ms: int = 0


# ------------------------------------------------------------------- sinais

def pontuar_ocr(sessao: Session, linhas: list[LinhaOcr], minimo: float) -> dict[uuid.UUID, float]:
    """Similaridade de trigramas entre o texto da capa e título/autor do catálogo."""
    texto = normalizar_texto(" ".join(linha.texto for linha in linhas[:12]))
    if len(texto) < 3:
        return {}
    linhas_sql = sessao.execute(
        text(
            """
            SELECT id,
                   word_similarity(lower(unaccent_simples(titulo)), :t) AS st,
                   word_similarity(lower(unaccent_simples(autores_texto)), :t) AS sa
            FROM obras
            WHERE word_similarity(lower(unaccent_simples(titulo)), :t) >= :minimo
            ORDER BY st DESC
            LIMIT 20
            """
        ),
        {"t": texto, "minimo": minimo},
    ).all()
    return {r.id: min(1.0, 0.75 * r.st + 0.25 * (r.sa or 0.0)) for r in linhas_sql}


def pontuar_capa(sessao: Session, modelo: ModeloDeCapa, imagem: Image.Image,
                 limite: int = 20) -> dict[uuid.UUID, float]:
    """Vizinhos mais próximos no índice de capas (só vetores do mesmo modelo e versão)."""
    vetor = modelo.embutir(imagem)
    distancia = Capa.vetor.cosine_distance(vetor.tolist())
    linhas = sessao.execute(
        select(Edicao.obra_id, (1 - distancia).label("sim"))
        .join(Edicao, Edicao.id == Capa.edicao_id)
        .where(Capa.modelo == modelo.nome, Capa.versao_modelo == modelo.versao)
        .order_by(distancia)
        .limit(limite)
    ).all()
    resultado: dict[uuid.UUID, float] = {}
    for obra_id, sim in linhas:
        resultado[obra_id] = max(resultado.get(obra_id, 0.0), float(sim))
    return resultado


def fundir(ocr: dict, capa: dict, cfg: dict) -> list[Candidato]:
    """Combina os sinais por obra. A similaridade da capa é reescalada pelo piso calibrado
    (capas quaisquer já têm alguma semelhança entre si)."""
    piso = cfg.get("piso_capa", 0.5)
    candidatos: dict[uuid.UUID, Candidato] = {}
    for oid, s in ocr.items():
        candidatos.setdefault(oid, Candidato(oid)).ocr = s
    for oid, s in capa.items():
        candidatos.setdefault(oid, Candidato(oid)).capa = max(0.0, (s - piso) / (1 - piso))
    for c in candidatos.values():
        pesos = []
        if ocr:
            pesos.append((cfg["peso_ocr"], c.ocr))
        if capa:
            pesos.append((cfg["peso_capa"], c.capa))
        total = sum(p for p, _ in pesos) or 1
        c.pontuacao = sum(p * v for p, v in pesos) / total
        c.sinais = [n for n, v in (("ocr", c.ocr), ("capa", c.capa)) if v > 0.05]
    return sorted(candidatos.values(), key=lambda c: -c.pontuacao)


def decidir(candidatos: list[Candidato], cfg: dict) -> tuple[str, list[Candidato]]:
    if not candidatos or candidatos[0].pontuacao < cfg["limiar_candidato"]:
        return "nao_identificado", []
    melhor = candidatos[0]
    segundo = candidatos[1].pontuacao if len(candidatos) > 1 else 0.0
    if melhor.pontuacao >= cfg["limiar_identificado"] and melhor.pontuacao - segundo >= cfg[
        "margem_minima"
    ]:
        return "identificado", [melhor]
    plausiveis = [c for c in candidatos if c.pontuacao >= cfg["limiar_candidato"]]
    return "candidatos", plausiveis[: cfg["max_candidatos"]]


# ------------------------------------------------------------------ serviço

def reconhecer(
    sessao: Session,
    imagem: Image.Image,
    dica: str,
    isbn_cliente: str | None,
    ocr: MotorOcr,
    modelo: ModeloDeCapa,
    cascata: Cascata | None,
    cfg: dict,
) -> Resultado:
    inicio = time.perf_counter()

    def pronto(r: Resultado) -> Resultado:
        r.tempo_ms = int((time.perf_counter() - inicio) * 1000)
        return r

    # 1. ISBN informado pelo aparelho: confirmado aqui (dígito e prefixo de livro).
    if isbn_cliente:
        i13 = isbn_util.validar(isbn_cliente)
        if i13:
            obra, _ = obras_servico.buscar_por_isbn(sessao, i13, cascata)
            if obra is not None:
                return pronto(Resultado("identificado", obra.id, isbn=i13))

    # 2. Código de barras na imagem.
    if dica in ("codigo_de_barras", "desconhecido", "capa"):
        leitura = ler_codigo(imagem)
        if leitura.isbn13:
            obra, _ = obras_servico.buscar_por_isbn(sessao, leitura.isbn13, cascata)
            if obra is not None:
                return pronto(Resultado("identificado", obra.id, isbn=leitura.isbn13))
            return pronto(Resultado("nao_identificado", isbn=leitura.isbn13))
        if leitura.nao_e_livro:
            return pronto(Resultado("nao_e_livro"))
        if dica == "codigo_de_barras":
            return pronto(Resultado("nao_identificado"))

    # 3. Capa: recorta se veio o quadro inteiro; OCR e embedding em paralelo.
    capa_img = localizar_livro(imagem) if dica == "desconhecido" else imagem
    futuro_ocr = _executor.submit(ocr.ler, capa_img)
    sinal_capa = pontuar_capa(sessao, modelo, capa_img)
    try:
        linhas = futuro_ocr.result(timeout=TEMPO_MAXIMO_OCR)
    except TempoEsgotado:
        linhas = []  # responde com o que a capa já resolveu
    sinal_ocr = pontuar_ocr(sessao, linhas, cfg.get("similaridade_minima_ocr", 0.2))
    status, escolhidos = decidir(fundir(sinal_ocr, sinal_capa, cfg), cfg)
    return pronto(Resultado(
        status,
        escolhidos[0].obra_id if status == "identificado" else None,
        escolhidos,
        texto_ocr=[linha.texto for linha in linhas[:8]],
    ))


def indexar_capa(sessao: Session, edicao: Edicao, imagem: Image.Image,
                 modelo: ModeloDeCapa, url_origem: str) -> Capa:
    """Grava (ou atualiza) o vetor da capa de uma edição para o modelo dado."""
    vetor = modelo.embutir(imagem).astype(np.float32).tolist()
    capa = sessao.scalars(
        select(Capa).where(Capa.edicao_id == edicao.id, Capa.modelo == modelo.nome,
                           Capa.versao_modelo == modelo.versao)
    ).first()
    if capa is None:
        capa = Capa(edicao_id=edicao.id, modelo=modelo.nome, versao_modelo=modelo.versao,
                    url_origem=url_origem, vetor=vetor)
        sessao.add(capa)
    else:
        capa.vetor, capa.url_origem = vetor, url_origem
    sessao.commit()
    return capa
