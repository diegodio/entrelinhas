"""Exportação da ficha em PDF. Respeita as flags e a regra dura do A5 (recebe a ficha já filtrada)."""

from __future__ import annotations

import io
from xml.sax.saxutils import escape

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle

from app.core import textos

CORES_FAIXA = {
    "Livre": "#2F5D50",
    "10+": "#2F6F8F",
    "12+": "#8F6410",
    "14+": "#B05129",
    "16+": "#8C2F1B",
    "18+": "#2B2430",
}
TINTA = colors.HexColor("#23302B")
FRACA = colors.HexColor("#5E6A63")
PAUTA = colors.HexColor("#E3DAC8")

_base = ParagraphStyle("base", fontName="Helvetica", fontSize=10, leading=14, textColor=TINTA)
_titulo = ParagraphStyle("titulo", parent=_base, fontName="Times-Bold", fontSize=20, leading=24)
_secao = ParagraphStyle(
    "secao",
    parent=_base,
    fontName="Times-Bold",
    fontSize=13,
    leading=18,
    spaceBefore=10,
    spaceAfter=4,
)
_apoio = ParagraphStyle("apoio", parent=_base, fontSize=9, leading=12, textColor=FRACA)
_selo = ParagraphStyle(
    "selo",
    parent=_base,
    fontName="Times-Bold",
    fontSize=22,
    leading=26,
    textColor=colors.white,
    alignment=1,
)


def _p(texto: str, estilo=_base) -> Paragraph:
    return Paragraph(escape(texto or ""), estilo)


def gerar_pdf_ficha(obra: dict, ficha: dict, config: dict) -> bytes:
    flags = config["flags"]
    saida = io.BytesIO()
    doc = SimpleDocTemplate(
        saida,
        pagesize=A4,
        leftMargin=18 * mm,
        rightMargin=18 * mm,
        topMargin=16 * mm,
        bottomMargin=16 * mm,
        title=f"Entrelinhas: {obra['titulo']}",
        author="Entrelinhas",
    )
    corpo: list = [
        _p("ENTRELINHAS · ORIENTAÇÃO DE LEITURA", _apoio),
        Spacer(1, 4),
        _p(obra["titulo"], _titulo),
        _p(", ".join(obra.get("autores") or []), _apoio),
        Spacer(1, 10),
    ]
    faixa = ficha["faixa_final"]
    selo = Table([[_p(faixa, _selo), _p(ficha["texto_recomendacao"])]], colWidths=[28 * mm, None])
    selo.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (0, 0), colors.HexColor(CORES_FAIXA.get(faixa, "#5E6A63"))),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("BOX", (0, 0), (-1, -1), 0.5, PAUTA),
                ("LEFTPADDING", (1, 0), (1, 0), 10),
                ("TOPPADDING", (0, 0), (-1, -1), 8),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
            ]
        )
    )
    corpo += [selo, Spacer(1, 8)]

    p = ficha["procedencia"]
    linha = textos.TEXTOS_FONTE_ANALISE.get(p["fonte_da_analise"], p["fonte_da_analise"])
    if flags["confianca"]:
        linha += f" · Confiança {round(p['confianca'] * 100)}%"
    if ficha.get("status") == "em_revisao":
        linha += f" · {textos.ROTULO_EM_REVISAO}"
    elif p.get("revisada_por_humano") and flags["selo_revisao_humana"]:
        linha += f" · {textos.ROTULO_REVISADO}"
    corpo.append(_p(linha, _apoio))
    if ficha.get("aviso_estimativa"):
        corpo.append(_p(ficha["aviso_estimativa"], _apoio))

    corpo.append(_p("Conteúdo sensível", _secao))
    linhas = []
    for eixo, dados in ficha["camada_a"].items():
        if eixo == "A6" and not flags["eixo_a6"]:
            continue
        nome = textos.NOMES_EIXOS[eixo]
        if eixo == ficha["eixo_determinante"] and dados["nivel"] > 0:
            nome += " (define a faixa)"
        just = dados["justificativa"] if flags["justificativa_eixo"] else ""
        linhas.append(
            [
                _p(nome),
                _p(f"{dados['nivel']}/4 · {textos.ROTULOS_NIVEL[dados['nivel']]}"),
                _p(just, _apoio),
            ]
        )
    tabela = Table(linhas, colWidths=[48 * mm, 30 * mm, None])
    tabela.setStyle(
        TableStyle(
            [("LINEBELOW", (0, 0), (-1, -1), 0.5, PAUTA), ("VALIGN", (0, 0), (-1, -1), "TOP")]
        )
    )
    corpo.append(tabela)
    if ficha.get("agravante_acumulo_aplicado"):
        corpo.append(_p(textos.TEXTO_AGRAVANTE, _apoio))
    if ficha.get("aviso_a5"):
        corpo.append(_p(ficha["aviso_a5"], _apoio))
    if flags["parafrase_evidencia"] and ficha.get("evidencias"):
        for ev in ficha["evidencias"]:
            texto = f"{textos.NOMES_EIXOS[ev['eixo']]}: {ev['parafrase']}"
            if ev.get("trecho_literal") and flags["trechos_literais"]:
                texto += f' — "{ev["trecho_literal"]}"'
            corpo.append(_p(texto, _apoio))

    if flags["camada_b"]:
        corpo.append(_p("Alertas de conteúdo", _secao))
        nomes = [textos.ROTULOS_FLAGS.get(f, f) for f in ficha["camada_b"]["flags"]]
        corpo.append(_p(", ".join(nomes) if nomes else "Nenhum alerta de conteúdo."))
    c = ficha["camada_c"]
    if flags["camada_c"]:
        corpo.append(_p("Perfil de leitura", _secao))
        corpo.append(_p(f"Nível de leitura: {c['rotulo_nivel_leitura']}"))
        if c["exigencia_repertorio"]:
            corpo.append(_p("Repertório que ajuda: " + "; ".join(c["exigencia_repertorio"])))
    if flags["valor_formativo"]:
        vf = c["valor_formativo"]
        corpo.append(_p("Valor formativo", _secao))
        marc = ", ".join(textos.ROTULOS_MARCADORES.get(m, m) for m in vf["marcadores"])
        corpo.append(_p(f"{vf['nivel']}" + (f" · {marc}" if marc else "")))
        if vf["justificativa"]:
            corpo.append(_p(vf["justificativa"]))

    corpo += [
        Spacer(1, 14),
        _p(textos.AVISO_INDEPENDENCIA, _apoio),
        _p(f"Rubrica {ficha['versao_rubrica']} · versão {ficha['versao_ficha']} da ficha", _apoio),
    ]
    doc.build(corpo)
    return saida.getvalue()
