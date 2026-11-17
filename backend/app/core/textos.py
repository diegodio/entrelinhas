"""Textos produzidos pelo backend (seção 3.2). Os textos da interface vivem nos ARB do app.

Terminologia obrigatória: nunca usar o termo do sistema oficial do Ministério da
Justiça; o produto fala em "Orientação de Leitura". Um teste percorre este arquivo.
"""

from __future__ import annotations

AVISO_INDEPENDENCIA = (
    "Orientação editorial independente, sem vínculo com o Ministério da Justiça "
    "ou com o sistema ClassInd."
)

TEXTOS_RECOMENDACAO = {
    "independente": "Leitura independente a partir de {faixa}.",
    "com_mediacao": "Recomendada com mediação de adulto a partir de {faixa}.",
    "conteudo_adulto": "Conteúdo adulto. Não recomendada antes de {faixa}.",
}
TEXTO_RECOMENDACAO_LIVRE = "Leitura livre, para todas as idades."

NOMES_EIXOS = {
    "A1": "Violência física",
    "A2": "Sexo e intimidade",
    "A3": "Linguagem ofensiva",
    "A4": "Substâncias",
    "A5": "Risco à integridade",
    "A6": "Abuso, trauma e opressão",
}

ROTULOS_NIVEL = {0: "Ausente", 1: "Leve", 2: "Moderado", 3: "Intenso", 4: "Extremo"}

ROTULOS_FLAGS = {
    "morte_de_personagem_principal": "Morte de personagem principal",
    "luto": "Luto",
    "morte_ou_maus_tratos_de_animal": "Morte ou maus-tratos de animal",
    "doenca_terminal": "Doença terminal",
    "bullying": "Bullying",
    "violencia_escolar": "Violência escolar",
    "gravidez_indesejada": "Gravidez indesejada",
    "aborto": "Aborto",
    "violencia_sexual_fora_de_cena": "Violência sexual fora de cena",
    "sequestro_ou_carcere": "Sequestro ou cárcere",
    "automutilacao": "Automutilação",
    "suicidio": "Suicídio",
    "transtorno_alimentar": "Transtorno alimentar",
    "dependencia_quimica": "Dependência química",
    "relacao_abusiva_romantizada": "Relação abusiva romantizada",
    "diferenca_de_poder_em_relacao_afetiva": "Diferença de poder em relação afetiva",
    "discriminacao_sem_critica_narrativa": "Discriminação sem crítica narrativa",
    "conteudo_religioso_sensivel": "Conteúdo religioso sensível",
    "final_tragico": "Final trágico",
    "acidente_grave": "Acidente grave",
    "arma_de_fogo": "Arma de fogo",
}

ROTULOS_MARCADORES = {
    "empatia": "Empatia",
    "repertorio_cultural": "Repertório cultural",
    "pensamento_critico": "Pensamento crítico",
    "qualidade_estetica": "Qualidade estética",
    "conhecimento_historico": "Conhecimento histórico",
    "desenvolvimento_moral": "Desenvolvimento moral",
}

TEXTOS_FONTE_ANALISE = {
    "texto_integral": "Análise do texto integral",
    "amostragem": "Análise por amostragem de trechos",
    "fontes_publicas": "Análise a partir de sinopse e resenhas públicas",
    "metadados_e_conhecimento_previo": "Estimativa sem acesso ao texto",
}

AVISO_ESTIMATIVA = (
    "Esta ficha é uma estimativa gerada sem acesso ao texto da obra. "
    "Trate a faixa como orientação inicial, não como análise."
)

AVISO_TRECHO_SUPRIMIDO_A5 = (
    "Trechos desta obra não são reproduzidos por descreverem conduta de risco. "
    "A orientação se baseia em descrição neutra das cenas."
)

TEXTO_AGRAVANTE = "Dois ou mais eixos em 16 anos ou acima elevam a faixa em um degrau."
ROTULO_REVISADO = "Revisado por editor humano"
ROTULO_EM_REVISAO = "Ficha em revisão após contestação"


def faixa_legivel(faixa: str) -> str:
    """Em frases, "14+" vira "14 anos". No selo, continua "14+"."""
    return faixa if faixa == "Livre" else faixa.replace("+", " anos")


def texto_recomendacao(tipo: str, faixa: str) -> str:
    if faixa == "Livre" and tipo == "independente":
        return TEXTO_RECOMENDACAO_LIVRE
    return TEXTOS_RECOMENDACAO[tipo].format(faixa=faixa_legivel(faixa))
