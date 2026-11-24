"""Flags e limites vindos do servidor (seção 4.8).

Ponto único: gerar e guardar tudo, mostrar o que a configuração permitir.
Nenhuma flag apaga dado. Chave desconhecida é erro, nunca "verdadeiro".
"""

from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.modelos import Configuracao

FLAGS_PADRAO: dict[str, tuple[bool, str]] = {
    "trechos_literais": (False, "Trechos exatos da obra (só fazem sentido com texto integral)"),
    "parafrase_evidencia": (True, "Descrição das cenas que sustentam cada nível"),
    "camada_b": (True, "Alertas de conteúdo"),
    "camada_c": (True, "Perfil de leitura"),
    "valor_formativo": (True, "Bloco de valor formativo"),
    "eixo_a6": (True, "Exibição do eixo A6"),
    "confianca": (True, "Barra de confiança"),
    "justificativa_eixo": (True, "Justificativa por eixo"),
    "selo_revisao_humana": (True, "Selo 'Revisado por editor humano'"),
    "metodologia": (True, "Página 'Como classificamos'"),
    "exportar_pdf": (True, "Exportação da ficha"),
    "compartilhar": (True, "Link público do resumo"),
    "scanner": (True, "Tela da câmera"),
    "busca_titulo": (True, "Busca por texto"),
}

LIMITES_PADRAO: dict[str, tuple[object, str]] = {
    "consultas_gratis_mes": (10, "Fichas completas novas por mês no plano gratuito"),
    "perfis_plano_gratuito": (1, "Perfis de leitor no plano gratuito"),
    "listas_plano_gratuito": (3, "Listas pessoais no plano gratuito (as duas padrão contam)"),
    "palavras_por_trecho": (40, "Limite de palavras por trecho literal"),
    "trechos_por_ficha": (6, "Máximo de trechos literais por ficha"),
    "tetos_confianca": (
        {
            "texto_integral": 1.0,
            "amostragem": 0.8,
            "fontes_publicas": 0.6,
            "metadados_e_conhecimento_previo": 0.4,
        },
        "Teto de confiança por fonte da análise",
    ),
}


class FlagDesconhecida(KeyError):
    pass


def semear(sessao: Session) -> None:
    existentes = set(sessao.scalars(select(Configuracao.chave)))
    for chave, (valor, descricao) in {**FLAGS_PADRAO, **LIMITES_PADRAO}.items():
        nome = f"flag.{chave}" if chave in FLAGS_PADRAO else f"limite.{chave}"
        if nome not in existentes:
            sessao.add(Configuracao(chave=nome, valor=valor, descricao=descricao))
    sessao.commit()


def carregar(sessao: Session) -> dict:
    """Mescla o banco sobre os padrões; o banco sempre vence."""
    flags = {k: v for k, (v, _) in FLAGS_PADRAO.items()}
    limites = {k: v for k, (v, _) in LIMITES_PADRAO.items()}
    for item in sessao.scalars(select(Configuracao)):
        if item.chave.startswith("flag.") and item.chave[5:] in flags:
            flags[item.chave[5:]] = bool(item.valor)
        elif item.chave.startswith("limite.") and item.chave[7:] in limites:
            padrao = limites[item.chave[7:]]
            limites[item.chave[7:]] = (
                {**padrao, **item.valor} if isinstance(padrao, dict) else item.valor
            )
    return {"flags": flags, "limites": limites}


def pode_exibir(config: dict, chave: str) -> bool:
    if chave not in config["flags"]:
        raise FlagDesconhecida(f"Flag de visibilidade desconhecida: {chave!r}")
    return bool(config["flags"][chave])


def definir(sessao: Session, chave: str, valor) -> None:
    if chave.startswith("flag.") and chave[5:] not in FLAGS_PADRAO:
        raise FlagDesconhecida(chave)
    if chave.startswith("limite.") and chave[7:] not in LIMITES_PADRAO:
        raise FlagDesconhecida(chave)
    item = sessao.get(Configuracao, chave)
    if item is None:
        sessao.add(Configuracao(chave=chave, valor=valor))
    else:
        item.valor = valor
    sessao.commit()
