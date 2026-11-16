"""Testes da regra de agregação (seção 3.1). O módulo mais crítico do produto."""

import itertools

import pytest

from app.core.agregacao import (
    NiveisInvalidos,
    agregar,
    arredondar_meio_para_cima,
    nivel_extensao,
    nivel_leitura,
    recomendacao_contextual,
)
from app.rubrica import IDS_EIXOS, carregar_rubrica


def niveis(**kw):
    base = dict.fromkeys(IDS_EIXOS, 0)
    base.update(kw)
    return base


# ------------------------------------------------ tabelas de mapeamento por eixo

MAPEAMENTOS = {
    "A1": ["Livre", "10+", "12+", "14+", "16+"],
    "A2": ["Livre", "10+", "12+", "16+", "18+"],
    "A3": ["Livre", "10+", "12+", "14+", "16+"],
    "A4": ["Livre", "10+", "12+", "14+", "16+"],
    "A5": ["Livre", "12+", "14+", "16+", "18+"],
    "A6": ["Livre", "10+", "14+", "16+", "18+"],
}


@pytest.mark.parametrize(
    "eixo,nivel,faixa",
    [(e, n, f) for e, fs in MAPEAMENTOS.items() for n, f in enumerate(fs)],
)
def test_cada_linha_de_cada_tabela(eixo, nivel, faixa):
    r = agregar(niveis(**{eixo: nivel}))
    assert r.faixas_por_eixo[eixo] == faixa
    assert r.faixa_base == faixa
    # Um único eixo nunca dispara o agravante.
    assert r.agravante_acumulo_aplicado is False
    assert r.faixa_final == faixa


def test_tabelas_do_teste_batem_com_a_rubrica():
    rubrica = carregar_rubrica()
    for eixo in rubrica["camada_a"]["eixos"]:
        esperado = [eixo["mapeamento_faixa"][str(n)] for n in range(5)]
        assert MAPEAMENTOS[eixo["id"]] == esperado


def test_tudo_zero_e_livre():
    r = agregar(niveis())
    assert r.faixa_final == "Livre"
    assert r.eixo_determinante == "A1"
    assert r.recomendacao_contextual == "independente"


def test_maximo_e_nao_media():
    # A1=3 (14+) e o resto 1 (10+): a média seria baixa; o máximo é 14+.
    r = agregar(niveis(A1=3, A2=1, A3=1, A4=1, A5=0, A6=1))
    assert r.faixa_final == "14+"


# ------------------------------------------------------------------ agravante


def test_agravante_zero_eixos_em_16():
    r = agregar(niveis(A1=3, A3=3))  # 14+ e 14+
    assert r.agravante_acumulo_aplicado is False
    assert r.faixa_final == "14+"


def test_agravante_um_eixo_em_16():
    r = agregar(niveis(A2=3, A1=3))  # 16+ e 14+
    assert r.agravante_acumulo_aplicado is False
    assert r.faixa_final == "16+"


def test_agravante_dois_eixos_em_16():
    r = agregar(niveis(A2=3, A6=3))  # 16+ e 16+
    assert r.agravante_acumulo_aplicado is True
    assert r.faixa_base == "16+"
    assert r.faixa_final == "18+"


def test_agravante_seis_eixos_aplica_uma_unica_vez():
    r = agregar(niveis(A1=4, A2=3, A3=4, A4=4, A5=3, A6=3))  # todos 16+
    assert r.agravante_acumulo_aplicado is True
    assert r.faixa_base == "16+"
    assert r.faixa_final == "18+"  # um degrau só


def test_teto_18():
    r = agregar(niveis(A2=4, A5=4, A6=4))  # 18+ em três eixos
    assert r.agravante_acumulo_aplicado is True
    assert r.faixa_base == "18+"
    assert r.faixa_final == "18+"


def test_agravante_conta_eixo_em_18_como_acima_de_16():
    r = agregar(niveis(A2=4, A1=4))  # 18+ e 16+
    assert r.agravante_acumulo_aplicado is True
    assert r.faixa_final == "18+"


# -------------------------------------------------------- eixo determinante


def test_determinante_pela_maior_faixa():
    r = agregar(niveis(A1=2, A6=2))  # 12+ e 14+
    assert r.eixo_determinante == "A6"


def test_determinante_empate_pelo_maior_nivel():
    # A1=4 -> 16+ (nível 4); A2=3 -> 16+ (nível 3). Empate de faixa: vence maior nível.
    r = agregar(niveis(A2=3, A1=4))
    assert r.eixo_determinante == "A1"


def test_determinante_empate_total_pela_ordem():
    r = agregar(niveis(A3=3, A4=3))  # ambos 14+ nível 3
    assert r.eixo_determinante == "A3"


def test_determinante_empate_de_faixa_com_niveis_diferentes():
    # A5=1 -> 12+ (nível 1); A1=2 -> 12+ (nível 2): vence A1 pelo nível.
    r = agregar(niveis(A5=1, A1=2))
    assert r.eixo_determinante == "A1"


# ---------------------------------------------------------- recomendações


def test_recomendacao_independente():
    assert recomendacao_contextual(niveis(A1=2, A3=1)) == "independente"


def test_recomendacao_com_mediacao_por_nivel_3():
    assert recomendacao_contextual(niveis(A1=3)) == "com_mediacao"


def test_recomendacao_com_mediacao_por_dois_eixos_em_2():
    assert recomendacao_contextual(niveis(A1=2, A4=2)) == "com_mediacao"


def test_recomendacao_conteudo_adulto():
    assert recomendacao_contextual(niveis(A3=4)) == "conteudo_adulto"


def test_recomendacao_adulto_prevalece_sobre_mediacao():
    assert recomendacao_contextual(niveis(A1=3, A2=4)) == "conteudo_adulto"


# --------------------------------------------------------- entradas inválidas


@pytest.mark.parametrize(
    "entrada",
    [
        {"A1": 0},
        {**niveis(), "A7": 0},
        {**niveis(), "A1": 5},
        {**niveis(), "A1": -1},
        {**niveis(), "A1": 2.0},
        {**niveis(), "A1": "2"},
        {**niveis(), "A1": None},
        {**niveis(), "A1": True},
        [],
        None,
    ],
)
def test_entradas_invalidas(entrada):
    with pytest.raises(NiveisInvalidos):
        agregar(entrada)


# ------------------------------------------------------------- camada C


@pytest.mark.parametrize(
    "paginas,nivel",
    [
        (1, 1),
        (149, 1),
        (150, 2),
        (300, 2),
        (301, 3),
        (500, 3),
        (501, 4),
        (800, 4),
        (801, 5),
        (5000, 5),
    ],
)
def test_extensao(paginas, nivel):
    assert nivel_extensao(paginas) == nivel


@pytest.mark.parametrize("paginas", [0, -3, None, 12.5, True])
def test_extensao_invalida(paginas):
    with pytest.raises(NiveisInvalidos):
        nivel_extensao(paginas)


def test_arredondamento_meio_para_cima():
    assert arredondar_meio_para_cima(2.5) == 3  # round() daria 2
    assert arredondar_meio_para_cima(3.5) == 4
    assert arredondar_meio_para_cima(2.25) == 2
    assert arredondar_meio_para_cima(2.75) == 3


def test_nivel_leitura_x5_sobe():
    # média 2,5 -> 3 "Intermediário" (round bancário daria 2)
    assert nivel_leitura(2, 3, 2, 3) == (3, "Intermediário")
    # média 1,5 -> 2
    assert nivel_leitura(1, 2, 1, 2) == (2, "Em formação")


def test_nivel_leitura_rotulos():
    assert nivel_leitura(1, 1, 1, 1) == (1, "Iniciante")
    assert nivel_leitura(5, 5, 5, 5) == (5, "Especializado")
    assert nivel_leitura(4, 4, 4, 4) == (4, "Avançado")


@pytest.mark.parametrize("valores", [(0, 1, 1, 1), (1, 6, 1, 1), (1, 1, 1.5, 1), (1, 1, 1, None)])
def test_nivel_leitura_invalido(valores):
    with pytest.raises(NiveisInvalidos):
        nivel_leitura(*valores)


# ---------------------------------------------------------------- determinismo


def test_determinismo_exaustivo():
    """Mesma entrada, mesma saída — e propriedades da regra em todas as 15.625 combinações."""
    rubrica = carregar_rubrica()
    ordem = rubrica["faixas_ordenadas"]
    for combo in itertools.product(range(5), repeat=6):
        n = dict(zip(IDS_EIXOS, combo, strict=True))
        a, b = agregar(n), agregar(dict(n))
        assert a == b
        # A faixa final nunca é menor que a de nenhum eixo.
        assert all(ordem.index(a.faixa_final) >= ordem.index(f) for f in a.faixas_por_eixo.values())
        # O agravante sobe no máximo um degrau.
        assert ordem.index(a.faixa_final) - ordem.index(a.faixa_base) in (0, 1)
