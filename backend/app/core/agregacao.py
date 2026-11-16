"""Regra de agregação da faixa etária (seção 3.1 do prompt).

Módulo PURO: sem IA, sem banco, sem rede. Recebe níveis, devolve faixa.
Se esta regra quebrar, o produto inteiro mente; por isso tem a cobertura
de testes mais rigorosa do projeto (testes/test_agregacao.py).

Invariantes:
- A faixa nasce só da Camada A. Camadas B e C nunca a alteram.
- O mapeamento nível -> faixa é POR EIXO, lido da rubrica.
- Agregação por máximo, nunca média.
- Agravante de acúmulo: >= 2 eixos em 16+ sobem um degrau, uma vez, teto 18+.
- A IA nunca decide a faixa: este código decide.
"""

from __future__ import annotations

from dataclasses import asdict, dataclass

from app.rubrica import IDS_EIXOS, NIVEIS_VALIDOS, carregar_rubrica, eixo_por_id


class NiveisInvalidos(ValueError):
    """Os níveis recebidos não cumprem o contrato (6 eixos, inteiros de 0 a 4)."""


@dataclass(frozen=True)
class ResultadoAgregacao:
    faixa_final: str
    faixa_base: str
    agravante_acumulo_aplicado: bool
    eixo_determinante: str
    faixas_por_eixo: dict[str, str]
    recomendacao_contextual: str  # independente | com_mediacao | conteudo_adulto

    def como_dict(self) -> dict:
        return asdict(self)


def _rubrica(rubrica: dict | None) -> dict:
    return rubrica if rubrica is not None else carregar_rubrica()


def indice_faixa(rubrica: dict, faixa: str) -> int:
    try:
        return rubrica["faixas_ordenadas"].index(faixa)
    except ValueError as erro:
        raise NiveisInvalidos(f"Faixa desconhecida: {faixa!r}") from erro


def subir_degrau(rubrica: dict, faixa: str, degraus: int = 1) -> str:
    faixas = rubrica["faixas_ordenadas"]
    teto = indice_faixa(rubrica, rubrica["agregacao"]["agravante_acumulo"]["teto"])
    return faixas[min(indice_faixa(rubrica, faixa) + degraus, teto)]


def validar_niveis(niveis: dict) -> None:
    if not isinstance(niveis, dict):
        raise NiveisInvalidos("Os níveis devem ser um dicionário {eixo: nível}.")
    recebidos = tuple(sorted(niveis))
    if recebidos != IDS_EIXOS:
        raise NiveisInvalidos(f"Esperados os eixos {IDS_EIXOS}, recebidos {recebidos}.")
    for eixo_id, nivel in niveis.items():
        # bool é subclasse de int em Python; True não é um nível.
        if isinstance(nivel, bool) or not isinstance(nivel, int) or nivel not in NIVEIS_VALIDOS:
            raise NiveisInvalidos(f"Eixo {eixo_id}: nível inválido {nivel!r} (esperado 0 a 4).")


def faixa_do_eixo(rubrica: dict, eixo_id: str, nivel: int) -> str:
    return eixo_por_id(rubrica, eixo_id)["mapeamento_faixa"][str(nivel)]


def agregar(niveis: dict, rubrica: dict | None = None) -> ResultadoAgregacao:
    """Aplica a regra completa sobre os níveis da Camada A: {"A1": 0-4, ..., "A6": 0-4}."""
    rubrica = _rubrica(rubrica)
    validar_niveis(niveis)

    faixas_por_eixo = {e: faixa_do_eixo(rubrica, e, niveis[e]) for e in IDS_EIXOS}

    # Faixa base: a maior faixa entre os eixos. Nunca média.
    faixa_base = max(faixas_por_eixo.values(), key=lambda f: indice_faixa(rubrica, f))

    # Eixo determinante: maior faixa; empate pelo maior nível; depois ordem A1..A6.
    eixo_determinante = min(
        (e for e in IDS_EIXOS if faixas_por_eixo[e] == faixa_base),
        key=lambda e: (-niveis[e], IDS_EIXOS.index(e)),
    )

    regra = rubrica["agregacao"]["agravante_acumulo"]
    limiar = indice_faixa(rubrica, regra["condicao_faixa_minima"])
    eixos_no_limiar = sum(1 for f in faixas_por_eixo.values() if indice_faixa(rubrica, f) >= limiar)
    agravante = eixos_no_limiar >= regra["quantidade_minima_eixos"]
    faixa_final = (
        subir_degrau(rubrica, faixa_base, regra["efeito_degraus"]) if agravante else faixa_base
    )

    return ResultadoAgregacao(
        faixa_final=faixa_final,
        faixa_base=faixa_base,
        agravante_acumulo_aplicado=agravante,
        eixo_determinante=eixo_determinante,
        faixas_por_eixo=faixas_por_eixo,
        recomendacao_contextual=recomendacao_contextual(niveis),
    )


def recomendacao_contextual(niveis: dict) -> str:
    validar_niveis(niveis)
    valores = list(niveis.values())
    if any(n == 4 for n in valores):
        return "conteudo_adulto"
    if any(n == 3 for n in valores) or sum(1 for n in valores if n >= 2) >= 2:
        return "com_mediacao"
    return "independente"


# ------------------------------------------------------------------- camada C


def nivel_extensao(paginas: int, rubrica: dict | None = None) -> int:
    rubrica = _rubrica(rubrica)
    if isinstance(paginas, bool) or not isinstance(paginas, int) or paginas < 1:
        raise NiveisInvalidos(f"Número de páginas inválido: {paginas!r}")
    for limiar in rubrica["camada_c"]["dimensoes"]["extensao"]["limiares"]:
        if limiar["ate_paginas"] is None or paginas <= limiar["ate_paginas"]:
            return limiar["nivel"]
    raise NiveisInvalidos(f"Página fora de qualquer limiar: {paginas}")


def arredondar_meio_para_cima(valor: float) -> int:
    # round() do Python arredonda meio para o par (2.5 -> 2). A rubrica pede meio para cima.
    return int(valor + 0.5)


def nivel_leitura(
    vocabulario: int,
    estrutura: int,
    densidade: int,
    extensao: int,
    rubrica: dict | None = None,
) -> tuple[int, str]:
    rubrica = _rubrica(rubrica)
    for nome, valor in (
        ("vocabulario", vocabulario),
        ("estrutura_narrativa", estrutura),
        ("densidade_tematica", densidade),
        ("extensao", extensao),
    ):
        if isinstance(valor, bool) or not isinstance(valor, int) or not 1 <= valor <= 5:
            raise NiveisInvalidos(f"Dimensão {nome}: valor inválido {valor!r} (esperado 1 a 5).")
    nivel = arredondar_meio_para_cima((vocabulario + estrutura + densidade + extensao) / 4)
    return nivel, rubrica["camada_c"]["nivel_leitura"]["rotulos"][str(nivel)]
