import copy
import json
from types import SimpleNamespace

import pytest

from app.modelos import Edicao, Ficha, FonteFicha, Obra, Tarefa
from app.motor import prompt as prompt_mod
from app.motor.pipeline import AnaliseFalhou, analisar, consolidar_blocos, dividir_em_blocos
from app.provedores import llm as llm_mod
from app.provedores.resenhas import Resenha

from .conftest import cabecalho


def saida_valida(**mudancas):
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


def saida_14():
    s = saida_valida()
    s["camada_a"]["A1"] = {"nivel": 3, "justificativa": "Há cenas de guerra com ferimentos."}
    s["evidencias"] = [
        {
            "eixo": "A1",
            "parafrase": "Batalhas descritas com feridos.",
            "trecho_literal": None,
            "fonte": "resenha: Wikipédia (pt)",
            "por_que_selecionado": "",
        }
    ]
    s["camada_b"]["flags"] = ["arma_de_fogo"]
    return s


class ResenhasFalsas:
    nome = "falsa"

    def __init__(self, n=1):
        self.n = n

    def buscar(self, titulo, autores):
        return [
            Resenha(
                texto=f"Resenha {i} de {titulo}.",
                url=f"https://x/{i}",
                fonte="Teste",
                licenca="CC BY-SA",
            )
            for i in range(self.n)
        ]


@pytest.fixture
def obra(sessao):
    o = Obra(
        titulo="Livro de Teste",
        autores=["Autora"],
        autores_texto="Autora",
        sinopse="Uma história de guerra.",
        paginas=320,
        fonte_metadados="google_books",
    )
    o.edicoes.append(Edicao(isbn13="9780306406157"))
    sessao.add(o)
    sessao.commit()
    return o


def test_fontes_publicas_publica_ficha_calculada(sessao, obra):
    llm = llm_mod.Falso([saida_14()])
    ficha = analisar(sessao, obra, llm, None, [ResenhasFalsas()])
    assert ficha.status == "publicada"
    d = ficha.dados
    assert d["faixa_final"] == "14+" and d["eixo_determinante"] == "A1"
    assert d["recomendacao_contextual"] == "com_mediacao"
    assert d["procedencia"]["fonte_da_analise"] == "fontes_publicas"
    assert d["procedencia"]["revisada_por_humano"] is False
    assert d["procedencia"]["modelo"] == "falso/falso-1"
    assert d["camada_c"]["extensao"] == 3
    assert {f.tipo for f in sessao.query(FonteFicha).filter_by(ficha_id=ficha.id)} == {
        "sinopse",
        "resenha",
        "metadado",
    }
    # O material entra no prompt como dado, com a regra de não ter trecho literal.
    assert "Resenha 0 de Livro de Teste." in llm.chamadas[0]
    assert "`trecho_literal` é SEMPRE null" in llm.chamadas[0]


def test_sem_resenha_vira_estimativa_com_teto_menor(sessao, obra):
    s = saida_14()
    s["confianca"] = 0.55  # acima do teto de 0,4 para metadados
    llm = llm_mod.Falso([s, {**s, "confianca": 0.35}])
    ficha = analisar(sessao, obra, llm, None, [])
    assert ficha.dados["procedencia"]["fonte_da_analise"] == "metadados_e_conhecimento_previo"
    assert ficha.dados["procedencia"]["confianca"] == 0.35
    assert len(llm.chamadas) == 2
    assert "acima do teto 0.4" in llm.chamadas[1]


def test_saida_invalida_refaz_com_os_erros(sessao, obra):
    ruim = saida_14()
    ruim["camada_b"]["flags"] = ["tema_inventado"]
    ruim["evidencias"][0]["trecho_literal"] = "citação inventada"
    llm = llm_mod.Falso(["```json\n" + json.dumps(ruim) + "\n```", saida_14()])
    analisar(sessao, obra, llm, None, [ResenhasFalsas()])
    assert len(llm.chamadas) == 2
    assert "RESPOSTA ANTERIOR FOI REJEITADA" in llm.chamadas[1]
    assert "fora do vocabulário fechado" in llm.chamadas[1]
    assert "trecho_literal deve ser null" in llm.chamadas[1]


def test_tres_falhas_nao_publicam_ficha_parcial(sessao, obra):
    llm = llm_mod.Falso(["isto não é JSON"])
    with pytest.raises(AnaliseFalhou):
        analisar(sessao, obra, llm, None, [])
    assert len(llm.chamadas) == 3
    ficha = sessao.query(Ficha).filter_by(obra_id=obra.id).one()
    assert ficha.dados is None and ficha.versao_ficha == 0


def test_regra_a5_rejeitada_no_validador(sessao, obra):
    s = saida_valida()
    s["camada_a"]["A5"] = {"nivel": 3, "justificativa": "cena"}
    s["evidencias"] = [
        {
            "eixo": "A5",
            "parafrase": "neutra",
            "trecho_literal": "método",
            "fonte": "x",
            "por_que_selecionado": "",
        }
    ]
    llm = llm_mod.Falso([s])
    with pytest.raises(AnaliseFalhou):
        analisar(sessao, obra, llm, None, [])
    assert "Regra dura A5" in llm.chamadas[1]


def test_pedir_analise_pela_api_e_falha_clara_sem_llm(cliente, sessao, obra, usuario):
    h = cabecalho(usuario)
    llm_mod._falso_global.respostas = [{**saida_14(), "confianca": 0.35}]
    llm_mod._falso_global.chamadas.clear()
    r = cliente.post(f"/v1/obras/{obra.id}/analise", headers=h)
    assert r.status_code == 202
    assert cliente.get(f"/v1/obras/{obra.id}").json()["status_ficha"] == "publicada"
    assert cliente.post(f"/v1/obras/{obra.id}/analise", headers=h).status_code == 409

    outra = Obra(titulo="Outra", autores=[], autores_texto="", fonte_metadados="x")
    sessao.add(outra)
    sessao.commit()
    llm_mod._falso_global.respostas = None  # sem LLM: falha com mensagem, sem inventar ficha
    cliente.post(f"/v1/obras/{outra.id}/analise", headers=h)
    assert cliente.get(f"/v1/obras/{outra.id}").json()["status_ficha"] == "indisponivel"
    tarefa = sessao.query(Tarefa).order_by(Tarefa.criado_em.desc()).first()
    sessao.refresh(tarefa)
    assert tarefa.estado == "erro" and "sem respostas" in tarefa.erro
    # Pedir de novo é permitido depois de uma falha.
    llm_mod._falso_global.respostas = [saida_valida(confianca=0.3)]
    assert cliente.post(f"/v1/obras/{outra.id}/analise", headers=h).status_code == 202
    assert cliente.get(f"/v1/obras/{outra.id}").json()["status_ficha"] == "publicada"


def test_texto_integral_em_blocos_consolida(sessao, obra):
    a = saida_14()
    b = saida_valida()
    b["camada_a"]["A3"] = {"nivel": 2, "justificativa": "palavrões"}
    b["evidencias"] = [
        {
            "eixo": "A3",
            "parafrase": "x",
            "trecho_literal": "um trecho curto",
            "fonte": "texto",
            "por_que_selecionado": "",
        }
    ]
    b["camada_b"]["flags"] = ["luto"]
    b["confianca"] = 0.9
    a["confianca"] = 0.8
    llm = llm_mod.Falso([a, b])
    texto = "palavra " * 7000
    ficha = analisar(sessao, obra, llm, None, [], texto_obra=texto)
    d = ficha.dados
    assert len(llm.chamadas) == 2
    assert d["camada_a"]["A1"]["nivel"] == 3 and d["camada_a"]["A3"]["nivel"] == 2
    assert set(d["camada_b"]["flags"]) == {"arma_de_fogo", "luto"}
    assert d["procedencia"]["fonte_da_analise"] == "texto_integral"
    assert d["procedencia"]["confianca"] == 0.8
    assert d["evidencias"][1]["trecho_literal"] == "um trecho curto"


def test_consolidar_e_dividir():
    a, b = saida_valida(), copy.deepcopy(saida_valida())
    a["camada_a"]["A2"] = {"nivel": 1, "justificativa": "a"}
    b["camada_a"]["A2"] = {"nivel": 3, "justificativa": "b"}
    b["camada_c"]["vocabulario"] = 3  # (2+3)/2 = 2,5 -> 3
    c = consolidar_blocos([a, b])
    assert c["camada_a"]["A2"] == {"nivel": 3, "justificativa": "b"}
    assert c["camada_c"]["vocabulario"] == 3
    assert len(dividir_em_blocos("a " * 13000)) == 3


def test_prompt_vem_da_rubrica_e_esquema_fecha_vocabulario():
    p = prompt_mod.montar_prompt({"titulo": "X"}, [], "fontes_publicas", 0.6)
    assert "Nível 4: Descrição gráfica e detalhada do ato" in p
    assert "Você NÃO decide faixa etária" in p
    assert "REGRA DURA DO EIXO A5" in p
    e = prompt_mod.esquema_saida()
    assert "luto" in e["properties"]["camada_b"]["properties"]["flags"]["items"]["enum"]
    assert e["properties"]["camada_a"]["required"] == ["A1", "A2", "A3", "A4", "A5", "A6"]


def test_extrair_json_tolerante():
    assert prompt_mod.extrair_json('Aqui está:\n```json\n{"a": 1}\n```') == {"a": 1}
    with pytest.raises(ValueError):
        prompt_mod.extrair_json("nada")


# ------------------------------------------- adaptador Anthropic (SDK simulado)


class _ClienteFalso:
    def __init__(self, resposta):
        self.resposta = resposta
        self.parametros = None
        self.beta = SimpleNamespace(messages=SimpleNamespace(create=self._create))

    def _create(self, **kw):
        self.parametros = kw
        return self.resposta


def _adaptador(resposta, fallbacks=True):
    from app.config import Configuracoes

    a = llm_mod.Anthropic(Configuracoes(anthropic_api_key="teste", llm_fallbacks=fallbacks))
    a.cliente = _ClienteFalso(resposta)
    return a


def test_anthropic_envia_saida_estruturada_e_fallback():
    resposta = SimpleNamespace(
        stop_reason="end_turn",
        stop_details=None,
        content=[SimpleNamespace(type="text", text='{"ok": 1}')],
    )
    a = _adaptador(resposta)
    assert a.gerar_json("sis", "prompt", {"type": "object"}) == '{"ok": 1}'
    p = a.cliente.parametros
    assert p["model"] == "claude-opus-5-5"
    assert p["output_config"]["format"] == {"type": "json_schema", "schema": {"type": "object"}}
    assert p["fallbacks"] == "default" and p["betas"] == ["server-side-fallback-2026-07-01"]
    assert "thinking" not in p and "temperature" not in p
    sem = _adaptador(resposta, fallbacks=False)
    sem.gerar_json("sis", "prompt", {})
    assert "fallbacks" not in sem.cliente.parametros


def test_anthropic_recusa_vira_erro_claro():
    resposta = SimpleNamespace(
        stop_reason="refusal", stop_details=SimpleNamespace(category="cyber"), content=[]
    )
    with pytest.raises(llm_mod.LLMRecusou):
        _adaptador(resposta).gerar_json("s", "p", {})


def test_sem_chave_ou_sem_provedor():
    from app.config import Configuracoes

    with pytest.raises(llm_mod.LLMIndisponivel):
        llm_mod.Anthropic(Configuracoes(anthropic_api_key=""))
    with pytest.raises(llm_mod.LLMIndisponivel):
        llm_mod.OpenAI(Configuracoes(openai_api_key="x", modelo_llm=""))
    with pytest.raises(llm_mod.LLMIndisponivel):
        llm_mod.Nenhum().gerar_json("s", "p", {})
