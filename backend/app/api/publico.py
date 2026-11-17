"""Rotas públicas: configuração, metodologia e resumo compartilhável."""

from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.core import textos
from app.db import obter_sessao
from app.erros import ErroApi, nao_encontrado
from app.modelos import Ficha
from app.rubrica import carregar_rubrica, nivel_regra_dura_a5
from app.servicos import configuracao as cfg_servico
from app.servicos import fichas as fichas_servico
from app.servicos import obras as obras_servico

rotas = APIRouter(prefix="/v1", tags=["público"])


@rotas.get("/configuracao")
def configuracao(sessao: Session = Depends(obter_sessao)):
    config = cfg_servico.carregar(sessao)
    rubrica = carregar_rubrica()
    limites = {k: v for k, v in config["limites"].items() if k not in ("reconhecimento",)}
    return {
        "flags": config["flags"],
        "limites": limites,
        "rubrica": {
            "versao": rubrica["versao"],
            "faixas": rubrica["faixas_ordenadas"],
            "eixos": [{"id": e, "nome": n} for e, n in textos.NOMES_EIXOS.items()],
            "rotulos_nivel": {str(k): v for k, v in textos.ROTULOS_NIVEL.items()},
            "rotulos_flags": textos.ROTULOS_FLAGS,
            "rotulos_marcadores": textos.ROTULOS_MARCADORES,
            "textos_fonte_analise": textos.TEXTOS_FONTE_ANALISE,
            "flags_com_justificativa_obrigatoria": rubrica["camada_b"][
                "flags_com_justificativa_obrigatoria"
            ],
            "nivel_regra_dura_a5": nivel_regra_dura_a5(rubrica),
        },
        "aviso_independencia": textos.AVISO_INDEPENDENCIA,
    }


@rotas.get("/metodologia")
def metodologia(sessao: Session = Depends(obter_sessao)):
    """Conteúdo de "Como classificamos", gerado a partir da rubrica."""
    if not cfg_servico.pode_exibir(cfg_servico.carregar(sessao), "metodologia"):
        raise ErroApi(404, "indisponivel", "A metodologia não está disponível no momento.")
    r = carregar_rubrica()
    agrav = r["agregacao"]["agravante_acumulo"]
    return {
        "versao_rubrica": r["versao"],
        "introducao": (
            "Cada livro é avaliado em seis eixos de conteúdo sensível, com níveis de 0 a 4. "
            "A faixa etária não é decidida pela inteligência artificial: ela é calculada por "
            "uma regra fixa e pública, descrita abaixo. A IA lê o material disponível e "
            "pontua os eixos; editores humanos revisam as fichas."
        ),
        "faixas": r["faixas_ordenadas"],
        "eixos": [
            {
                "id": e["id"],
                "nome": textos.NOMES_EIXOS[e["id"]],
                "nome_completo": e["nome"],
                "escopo": e.get("escopo"),
                "niveis": [
                    {
                        "nivel": int(n),
                        "rotulo": textos.ROTULOS_NIVEL[int(n)],
                        "descricao": d,
                        "faixa": e["mapeamento_faixa"][n],
                    }
                    for n, d in e["descritores"].items()
                ],
            }
            for e in r["camada_a"]["eixos"]
        ],
        "regras": [
            "A faixa de cada eixo vem da tabela do próprio eixo; os eixos têm tabelas diferentes.",
            "A faixa do livro é a maior faixa entre os seis eixos. Nunca é uma média.",
            f"Se dois ou mais eixos ficarem em {textos.faixa_legivel(agrav['condicao_faixa_minima'])} "
            f"ou acima, a faixa sobe um degrau, uma única vez, até no máximo "
            f"{textos.faixa_legivel(agrav['teto'])}.",
            "Os alertas de conteúdo, o perfil de leitura e o valor formativo nunca alteram a faixa.",
            f"Quando o eixo {textos.NOMES_EIXOS['A5']} chega ao nível {nivel_regra_dura_a5(r)}, "
            "nenhum trecho do livro é reproduzido: só uma descrição neutra, sem detalhes de conduta.",
        ],
        "recomendacoes": {k: v["descricao"] for k, v in r["recomendacao_contextual"].items()},
        "alertas": {
            "descricao": "Alertas indicam temas presentes na obra. São sim ou não, de uma lista "
            "fechada, e não alteram a faixa.",
            "lista": list(textos.ROTULOS_FLAGS.values()),
        },
        "perfil_de_leitura": {
            "descricao": "O perfil de leitura mede a exigência do texto, não o risco. "
            "Não altera a faixa.",
            "dimensoes": r["camada_c"]["dimensoes"],
            "rotulos": r["camada_c"]["nivel_leitura"]["rotulos"],
        },
        "valor_formativo": {
            "descricao": "Indica o que a obra pode oferecer à formação do leitor. "
            "Não altera a faixa.",
            "marcadores": list(textos.ROTULOS_MARCADORES.values()),
        },
        "fontes_de_analise": [
            {"fonte": k, "titulo": textos.TEXTOS_FONTE_ANALISE[k], "descricao": v}
            for k, v in r["procedencia"]["fontes"].items()
        ],
        "contestacao": (
            "Qualquer pessoa com conta pode contestar uma ficha, indicando o eixo ou campo e o "
            "motivo. A ficha passa a exibir 'Ficha em revisão após contestação' até a resposta "
            "de um editor."
        ),
        "aviso_independencia": textos.AVISO_INDEPENDENCIA,
    }


@rotas.get("/publico/fichas/{slug}")
def ficha_publica(slug: str, sessao: Session = Depends(obter_sessao)):
    config = cfg_servico.carregar(sessao)
    if not cfg_servico.pode_exibir(config, "compartilhar"):
        raise ErroApi(404, "indisponivel", "O compartilhamento está desligado.")
    ficha = sessao.scalars(
        select(Ficha).where(Ficha.slug == slug).options(selectinload(Ficha.obra))
    ).first()
    if ficha is None or ficha.status not in fichas_servico.STATUS_VISIVEIS:
        raise nao_encontrado("Ficha")
    obra = obras_servico.obter(sessao, ficha.obra_id)
    return {
        "obra": obras_servico.resumo(obra),
        "resumo": fichas_servico.resumo_publico(ficha),
    }
