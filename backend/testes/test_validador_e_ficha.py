import copy

import pytest

from app.core.ficha import ficha_para_saida, montar_ficha
from app.motor.validador import SaidaModeloInvalida, validar_saida_modelo


def saida_base(**mudancas):
    s = {
        "camada_a": {
            e: {"nivel": 0, "justificativa": ""} for e in ("A1", "A2", "A3", "A4", "A5", "A6")
        },
        "evidencias": [],
        "camada_b": {"flags": [], "justificativas": {}},
        "camada_c": {
            "vocabulario": 2,
            "estrutura_narrativa": 2,
            "densidade_tematica": 3,
            "exigencia_repertorio": [],
            "valor_formativo": {"nivel": "Médio", "marcadores": ["empatia"], "justificativa": "x"},
        },
        "confianca": 0.5,
        "observacoes": "",
    }
    s.update(mudancas)
    return s


def erros_de(saida, fonte="fontes_publicas", **kw):
    with pytest.raises(SaidaModeloInvalida) as e:
        validar_saida_modelo(saida, fonte, **kw)
    return e.value.erros


def test_saida_valida():
    assert validar_saida_modelo(saida_base(), "fontes_publicas")


def test_eixo_ausente_e_nivel_invalido():
    s = saida_base()
    del s["camada_a"]["A3"]
    s["camada_a"]["A1"]["nivel"] = 5
    erros = erros_de(s)
    assert any("A3 ausente" in e for e in erros)
    assert any("A1.nivel inválido" in e for e in erros)


def test_justificativa_e_evidencia_obrigatorias():
    s = saida_base()
    s["camada_a"]["A1"] = {"nivel": 1, "justificativa": ""}
    s["camada_a"]["A2"] = {"nivel": 2, "justificativa": "ok"}
    erros = erros_de(s)
    assert any("A1: nível 1 sem justificativa" in e for e in erros)
    assert any("A2: nível 2 exige ao menos uma evidência" in e for e in erros)


def test_flag_fora_do_vocabulario_e_justificativa_obrigatoria():
    s = saida_base(
        camada_b={"flags": ["tema_inventado", "relacao_abusiva_romantizada"], "justificativas": {}}
    )
    erros = erros_de(s)
    assert any("fora do vocabulário" in e for e in erros)
    assert any("sem justificativa obrigatória" in e for e in erros)


def test_regra_dura_a5_no_validador():
    s = saida_base()
    s["camada_a"]["A5"] = {"nivel": 3, "justificativa": "cena explícita"}
    s["evidencias"] = [{"eixo": "A5", "parafrase": "neutra", "trecho_literal": "proibido"}]
    erros = erros_de(s, "texto_integral")
    assert any("Regra dura A5" in e for e in erros)


def test_sem_texto_nao_aceita_trecho_nem_localizacao():
    s = saida_base()
    s["camada_a"]["A1"] = {"nivel": 2, "justificativa": "briga"}
    s["evidencias"] = [
        {"eixo": "A1", "parafrase": "briga", "trecho_literal": "algo", "localizacao": "cap. 3"}
    ]
    erros = erros_de(s, "fontes_publicas")
    assert any("trecho_literal deve ser null" in e for e in erros)
    assert any("localização deve ser null" in e for e in erros)


def test_teto_de_confianca_por_fonte():
    erros = erros_de(saida_base(confianca=0.7), "fontes_publicas")
    assert any("acima do teto" in e for e in erros)
    erros = erros_de(saida_base(confianca=0.5), "metadados_e_conhecimento_previo")
    assert any("acima do teto" in e for e in erros)
    assert validar_saida_modelo(saida_base(confianca=0.9), "texto_integral")


def test_camada_c_e_marcadores():
    s = saida_base()
    s["camada_c"]["vocabulario"] = 0
    s["camada_c"]["exigencia_repertorio"] = ["a", "b", "c", "d"]
    s["camada_c"]["valor_formativo"]["marcadores"] = ["coragem"]
    erros = erros_de(s)
    assert len([e for e in erros if "camada_c" in e or "marcador" in e]) == 3


def test_resposta_nao_objeto():
    assert erros_de([]) == ["A resposta não é um objeto JSON."]


# --------------------------------------------------------------- montagem


def montar(saida, fonte="texto_integral", paginas=200, **kw):
    return montar_ficha(
        obra_id="o1",
        saida=saida,
        paginas=paginas,
        procedencia={"fonte_da_analise": fonte, "confianca": 0.5},
        versao_ficha=1,
        **kw,
    )


def test_campos_calculados_vem_do_codigo():
    s = saida_base()
    s["camada_a"]["A2"] = {"nivel": 3, "justificativa": "cena"}
    s["camada_a"]["A6"] = {"nivel": 3, "justificativa": "abuso"}
    s["faixa_final"] = "Livre"  # lixo que o modelo poderia mandar: ignorado
    f = montar(s)
    assert f["faixa_final"] == "18+" and f["agravante_acumulo_aplicado"] is True
    assert f["eixo_determinante"] == "A2"
    assert f["camada_a"]["A6"]["faixa"] == "16+"
    assert f["camada_c"]["extensao"] == 2
    assert f["camada_c"]["nivel_leitura"] == 2  # (2+2+3+2)/4 = 2,25


def test_montagem_reforca_a5_e_sem_texto():
    s = saida_base()
    s["camada_a"]["A5"] = {"nivel": 4, "justificativa": "método"}
    s["camada_a"]["A1"] = {"nivel": 2, "justificativa": "briga"}
    s["evidencias"] = [
        {"eixo": "A5", "parafrase": "neutra", "trecho_literal": "proibido"},
        {"eixo": "A1", "parafrase": "briga", "trecho_literal": "permitido"},
    ]
    f = montar(s, "texto_integral")
    assert f["evidencias"][0]["trecho_literal"] is None
    assert f["evidencias"][1]["trecho_literal"] == "permitido"
    f = montar(s, "fontes_publicas")
    assert all(ev["trecho_literal"] is None for ev in f["evidencias"])


def test_limite_de_trechos_e_palavras():
    s = saida_base()
    s["camada_a"]["A1"] = {"nivel": 2, "justificativa": "x"}
    s["evidencias"] = [
        {"eixo": "A1", "parafrase": "p", "trecho_literal": f"t{i}"} for i in range(8)
    ]
    s["evidencias"].append({"eixo": "A1", "parafrase": "p", "trecho_literal": "pal " * 41})
    f = montar(s, max_trechos=6)
    assert sum(1 for ev in f["evidencias"] if ev["trecho_literal"]) == 6


def test_sem_paginas_usa_tres_dimensoes():
    f = montar(saida_base(), paginas=None)
    assert f["camada_c"]["extensao"] is None
    assert f["camada_c"]["nivel_leitura"] == 2  # (2+2+3)/3 = 2,33


def test_ida_e_volta_revisao():
    s = saida_base()
    s["camada_a"]["A1"] = {"nivel": 2, "justificativa": "x"}
    s["evidencias"] = [{"eixo": "A1", "parafrase": "p", "trecho_literal": None}]
    f = montar(s)
    s2 = ficha_para_saida(f)
    validar_saida_modelo(s2, "texto_integral")
    f2 = montar(copy.deepcopy(s2))
    assert {k: v for k, v in f2.items() if k != "atualizada_em"} == {
        k: v for k, v in f.items() if k != "atualizada_em"
    }
