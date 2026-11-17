"""Importação em lote de ISBNs para uma lista de acervo (tarefa assíncrona)."""

from __future__ import annotations

import csv
import io
import uuid

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core import isbn as isbn_util
from app.modelos import ItemLista, Lista, Tarefa

LIMITE_LINHAS = 5000


class CsvInvalido(ValueError):
    pass


def ler_csv(conteudo: bytes) -> list[str]:
    """Aceita uma coluna chamada isbn (ou a primeira coluna, sem cabeçalho)."""
    try:
        texto = conteudo.decode("utf-8-sig")
    except UnicodeDecodeError:
        texto = conteudo.decode("latin-1")
    amostra = texto[:2048]
    try:
        dialeto = csv.Sniffer().sniff(amostra, delimiters=",;\t")
    except csv.Error:
        dialeto = csv.excel
    linhas = list(csv.reader(io.StringIO(texto), dialeto))
    if not linhas:
        raise CsvInvalido("O arquivo está vazio.")
    cabecalho = [c.strip().lower() for c in linhas[0]]
    if "isbn" in cabecalho:
        coluna, dados = cabecalho.index("isbn"), linhas[1:]
    else:
        coluna, dados = 0, linhas
    valores = [
        linha[coluna].strip() for linha in dados if len(linha) > coluna and linha[coluna].strip()
    ]
    if len(valores) > LIMITE_LINHAS:
        raise CsvInvalido(f"O arquivo tem mais de {LIMITE_LINHAS} linhas.")
    return valores


def executar_importacao(sessao: Session, tarefa: Tarefa) -> dict:
    from app import tarefas
    from app.deps import obter_cascata
    from app.servicos import obras as obras_servico

    p = tarefa.parametros
    lista = sessao.get(Lista, uuid.UUID(p["lista_id"]))
    cascata = obter_cascata()
    linhas: list[dict] = []
    aceitos = rejeitados = nao_encontrados = pendentes = 0
    for n, bruto in enumerate(p["isbns"], start=2):
        isbn13 = isbn_util.validar(bruto)
        if not isbn13:
            rejeitados += 1
            linhas.append(
                {"linha": n, "isbn": bruto, "situacao": "rejeitado", "motivo": "ISBN inválido"}
            )
            continue
        obra, _ = obras_servico.buscar_por_isbn(sessao, isbn13, cascata)
        if obra is None:
            nao_encontrados += 1
            linhas.append({"linha": n, "isbn": isbn13, "situacao": "nao_encontrado"})
            continue
        if not sessao.scalar(
            select(ItemLista.id).where(ItemLista.lista_id == lista.id, ItemLista.obra_id == obra.id)
        ):
            sessao.add(ItemLista(lista_id=lista.id, obra_id=obra.id))
            sessao.commit()
        aceitos += 1
        situacao = "aceito"
        if obra.ficha is None or obra.ficha.status == "indisponivel":
            tarefas.enfileirar_analise(sessao, obra)
            pendentes += 1
            situacao = "analise_pendente"
        linhas.append(
            {
                "linha": n,
                "isbn": isbn13,
                "situacao": situacao,
                "obra_id": str(obra.id),
                "titulo": obra.titulo,
            }
        )
    return {
        "aceitos": aceitos,
        "rejeitados": rejeitados,
        "nao_encontrados": nao_encontrados,
        "analises_pendentes": pendentes,
        "linhas": linhas,
    }
