"""Relatório de acervo: distribuição por faixa, alertas frequentes, obras acima da idade de
referência, e exportação em CSV e PDF."""

from __future__ import annotations

import csv
import io
from collections import Counter

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle

from app.core import textos
from app.modelos import Lista
from app.rubrica import faixas_ordenadas
from app.servicos import obras as obras_servico


def _idade(faixa: str) -> int:
    return 0 if faixa == "Livre" else int(faixa.rstrip("+"))


def gerar(sessao, lista: Lista) -> dict:
    faixas = faixas_ordenadas()
    distribuicao = Counter()
    alertas = Counter()
    linhas = []
    acima = []
    for item in lista.itens:
        obra = obras_servico.obter(sessao, item.obra_id)
        ficha = obra.ficha
        visivel = ficha is not None and ficha.dados and ficha.status in ("publicada", "em_revisao")
        faixa = ficha.faixa_final if visivel else None
        flags = ficha.dados["camada_b"]["flags"] if visivel else []
        distribuicao[faixa or "sem_ficha"] += 1
        alertas.update(flags)
        linha = {
            "obra_id": str(obra.id),
            "titulo": obra.titulo,
            "autores": ", ".join(obra.autores),
            "isbn13": next((e.isbn13 for e in obra.edicoes if e.isbn13), None),
            "faixa": faixa,
            "alertas": [textos.ROTULOS_FLAGS.get(f, f) for f in flags],
            "nivel_leitura": ficha.dados["camada_c"]["rotulo_nivel_leitura"] if visivel else None,
            "situacao_ficha": ficha.status if ficha else "sem_ficha",
            "revisada_por_humano": bool(visivel and ficha.revisada_por_humano),
        }
        linhas.append(linha)
        if lista.idade_referencia is not None and faixa and _idade(faixa) > lista.idade_referencia:
            acima.append(linha)
    return {
        "lista": {
            "id": str(lista.id),
            "nome": lista.nome,
            "tipo": lista.tipo,
            "idade_referencia": lista.idade_referencia,
            "ano_escolar": lista.ano_escolar,
        },
        "total": len(linhas),
        "distribuicao_faixa": [
            {"faixa": f, "quantidade": distribuicao.get(f, 0)} for f in [*faixas, "sem_ficha"]
        ],
        "alertas_frequentes": [
            {"alerta": textos.ROTULOS_FLAGS.get(a, a), "quantidade": q}
            for a, q in alertas.most_common(10)
        ],
        "acima_da_idade": acima,
        "obras": sorted(linhas, key=lambda x: x["titulo"].lower()),
    }


def para_csv(relatorio: dict) -> bytes:
    saida = io.StringIO()
    w = csv.writer(saida, delimiter=";")
    w.writerow(
        [
            "titulo",
            "autores",
            "isbn13",
            "faixa",
            "alertas",
            "nivel_leitura",
            "situacao_ficha",
            "revisada_por_humano",
        ]
    )
    for o in relatorio["obras"]:
        w.writerow(
            [
                o["titulo"],
                o["autores"],
                o["isbn13"] or "",
                o["faixa"] or "",
                " | ".join(o["alertas"]),
                o["nivel_leitura"] or "",
                o["situacao_ficha"],
                "sim" if o["revisada_por_humano"] else "não",
            ]
        )
    return saida.getvalue().encode("utf-8-sig")


def para_pdf(relatorio: dict) -> bytes:
    base = ParagraphStyle("b", fontName="Helvetica", fontSize=9, leading=12)
    titulo = ParagraphStyle("t", parent=base, fontName="Times-Bold", fontSize=18, leading=22)
    secao = ParagraphStyle(
        "s",
        parent=base,
        fontName="Times-Bold",
        fontSize=12,
        leading=16,
        spaceBefore=10,
        spaceAfter=4,
    )
    saida = io.BytesIO()
    doc = SimpleDocTemplate(
        saida,
        pagesize=A4,
        leftMargin=16 * mm,
        rightMargin=16 * mm,
        topMargin=14 * mm,
        bottomMargin=14 * mm,
        title=f"Relatório: {relatorio['lista']['nome']}",
    )
    lst = relatorio["lista"]
    corpo = [
        Paragraph(f"Relatório de acervo: {lst['nome']}", titulo),
        Paragraph(
            f"{relatorio['total']} obras"
            + (
                f" · idade de referência: {lst['idade_referencia']} anos"
                if lst["idade_referencia"] is not None
                else ""
            ),
            base,
        ),
        Paragraph("Distribuição por faixa", secao),
    ]

    def tabela(dados, larguras):
        t = Table(dados, colWidths=larguras, repeatRows=1)
        t.setStyle(
            TableStyle(
                [
                    ("FONT", (0, 0), (-1, 0), "Helvetica-Bold"),
                    ("LINEBELOW", (0, 0), (-1, -1), 0.4, colors.HexColor("#E3DAC8")),
                    ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ]
            )
        )
        return t

    corpo.append(
        tabela(
            [["Faixa", "Quantidade"]]
            + [
                [d["faixa"] if d["faixa"] != "sem_ficha" else "Sem ficha", d["quantidade"]]
                for d in relatorio["distribuicao_faixa"]
            ],
            [40 * mm, 30 * mm],
        )
    )
    corpo.append(Paragraph("Alertas mais frequentes", secao))
    corpo.append(
        tabela(
            [["Alerta", "Quantidade"]]
            + [[a["alerta"], a["quantidade"]] for a in relatorio["alertas_frequentes"]]
            or [["—", 0]],
            [100 * mm, 30 * mm],
        )
    )
    if lst["idade_referencia"] is not None:
        corpo.append(Paragraph("Obras acima da idade de referência", secao))
        corpo.append(
            tabela(
                [["Obra", "Faixa"]]
                + [[Paragraph(o["titulo"], base), o["faixa"]] for o in relatorio["acima_da_idade"]]
                or [["Nenhuma", ""]],
                [140 * mm, 30 * mm],
            )
        )
    corpo.append(Paragraph("Obras", secao))
    corpo.append(
        tabela(
            [["Obra", "Faixa", "Alertas", "Nível"]]
            + [
                [
                    Paragraph(o["titulo"], base),
                    o["faixa"] or "—",
                    Paragraph(", ".join(o["alertas"]), base),
                    o["nivel_leitura"] or "—",
                ]
                for o in relatorio["obras"]
            ],
            [62 * mm, 18 * mm, 72 * mm, 26 * mm],
        )
    )
    corpo += [Spacer(1, 10), Paragraph(textos.AVISO_INDEPENDENCIA, base)]
    doc.build(corpo)
    return saida.getvalue()
