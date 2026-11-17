import hashlib
import hmac
import json
import time

import pytest

from app.config import Configuracoes
from app.modelos import Assinatura, Contestacao, Edicao, Ficha, FichaVersao, Obra
from app.provedores import llm as llm_mod
from app.provedores import pagamento as pag
from app.provedores.email import obter_email

from .conftest import cabecalho, criar_usuario
from .test_pipeline import saida_valida

# ---------------------------------------------------------------- assinaturas


def test_checkout_falso_ativa_plano_familia(cliente, usuario):
    h = cabecalho(usuario)
    r = cliente.post("/v1/assinaturas/checkout", json={"plano": "familia"}, headers=h).json()
    assert r["provedor"] == "falso" and "assinatura=ok" in r["url"]
    assert cliente.get("/v1/assinaturas/eu", headers=h).json()["plano"] == "familia"
    assert (
        cliente.post("/v1/assinaturas/checkout", json={"plano": "ouro"}, headers=h).json()["codigo"]
        == "plano_invalido"
    )


def test_plano_escola_so_pelo_gestor(cliente, usuario, sessao):
    h = cabecalho(usuario)
    org = cliente.post("/v1/organizacoes", json={"nome": "Escola Azul"}, headers=h).json()
    outro = criar_usuario(sessao, "prof@teste.br")
    cliente.post(
        f"/v1/organizacoes/{org['id']}/membros",
        json={"email": "prof@teste.br", "papel": "professor"},
        headers=h,
    )
    r = cliente.post(
        "/v1/assinaturas/checkout",
        json={"plano": "escola", "organizacao_id": org["id"]},
        headers=cabecalho(outro),
    )
    assert r.status_code == 403
    cliente.post(
        "/v1/assinaturas/checkout", json={"plano": "escola", "organizacao_id": org["id"]}, headers=h
    )
    # Membro da organização herda o plano Escola.
    assert cliente.get("/v1/eu", headers=cabecalho(outro)).json()["uso"]["plano"] == "escola"


def test_stripe_verifica_assinatura_do_webhook():
    cfg = Configuracoes(stripe_secret_key="sk_test", stripe_webhook_secret="whsec_x")
    s = pag.Stripe(cfg)
    corpo = json.dumps(
        {
            "type": "checkout.session.completed",
            "data": {
                "object": {
                    "subscription": "sub_1",
                    "client_reference_id": "u1",
                    "metadata": {"plano": "familia"},
                }
            },
        }
    ).encode()
    t = int(time.time())
    assinatura = hmac.new(b"whsec_x", f"{t}.".encode() + corpo, hashlib.sha256).hexdigest()
    evento = s.ler_webhook(corpo, f"t={t},v1={assinatura}")
    assert evento.tipo == "ativada" and evento.id_externo == "sub_1" and evento.plano == "familia"
    with pytest.raises(pag.PagamentoInvalido):
        s.ler_webhook(corpo, f"t={t},v1={'0' * 64}")
    with pytest.raises(pag.PagamentoInvalido):  # fora da janela de tempo (repetição)
        velho = t - 3600
        a2 = hmac.new(b"whsec_x", f"{velho}.".encode() + corpo, hashlib.sha256).hexdigest()
        s.ler_webhook(corpo, f"t={velho},v1={a2}")


def test_webhook_cancelamento_mantem_dono(sessao, usuario):
    from app.api.assinaturas import ativar

    ativar(sessao, plano="familia", origem="stripe", id_externo="sub_9", usuario_id=usuario.id)
    ativar(sessao, plano="familia", origem="stripe", id_externo="sub_9")  # evento sem metadados
    a = sessao.query(Assinatura).one()
    assert a.usuario_id == usuario.id


# ---------------------------------------------------------------- organizações


@pytest.fixture
def org(cliente, usuario, sessao):
    h = cabecalho(usuario)
    o = cliente.post(
        "/v1/organizacoes", json={"nome": "Biblioteca Central", "tipo": "biblioteca"}, headers=h
    ).json()
    lista = cliente.post(
        f"/v1/organizacoes/{o['id']}/listas",
        json={"nome": "6º ano", "tipo": "turma", "idade_referencia": 11},
        headers=h,
    ).json()
    return {"id": o["id"], "lista": lista["id"], "h": h}


def test_membros_e_papeis(cliente, org, sessao):
    criar_usuario(sessao, "bib@teste.br")
    r = cliente.post(
        f"/v1/organizacoes/{org['id']}/membros",
        json={"email": "ninguem@teste.br", "papel": "professor"},
        headers=org["h"],
    )
    assert r.json()["codigo"] == "usuario_nao_encontrado"
    cliente.post(
        f"/v1/organizacoes/{org['id']}/membros",
        json={"email": "bib@teste.br", "papel": "professor"},
        headers=org["h"],
    )
    d = cliente.get(f"/v1/organizacoes/{org['id']}", headers=org["h"]).json()
    assert {m["papel"] for m in d["membros"]} == {"gestor", "professor"}
    # Professor não cria lista de acervo; gestor não pode sair sendo o único.
    from app.modelos import Usuario

    p = sessao.query(Usuario).filter_by(email="bib@teste.br").one()
    r = cliente.post(
        f"/v1/organizacoes/{org['id']}/listas", json={"nome": "Acervo"}, headers=cabecalho(p)
    )
    assert r.status_code == 403
    gestor_id = [m["usuario_id"] for m in d["membros"] if m["papel"] == "gestor"][0]
    r = cliente.delete(f"/v1/organizacoes/{org['id']}/membros/{gestor_id}", headers=org["h"])
    assert r.json()["codigo"] == "ultimo_gestor"
    # Quem não é membro não vê nada.
    estranho = criar_usuario(sessao, "x@teste.br")
    assert (
        cliente.get(f"/v1/organizacoes/{org['id']}", headers=cabecalho(estranho)).status_code == 404
    )


def test_importacao_exige_plano_e_processa_linhas(cliente, org, sessao, demo):
    obra = Obra(titulo="Com ISBN", autores=["A"], autores_texto="A", fonte_metadados="x")
    obra.edicoes.append(Edicao(isbn13="9780306406157"))
    sessao.add(obra)
    sessao.commit()
    csv_ = b"isbn\n978-0-306-40615-7\n123\n9788535902778\n"
    arquivo = {"arquivo": ("isbns.csv", csv_, "text/csv")}
    r = cliente.post(
        f"/v1/organizacoes/{org['id']}/importacoes",
        data={"lista_id": org["lista"]},
        files=arquivo,
        headers=org["h"],
    )
    assert r.status_code == 402
    cliente.post(
        "/v1/assinaturas/checkout",
        json={"plano": "escola", "organizacao_id": org["id"]},
        headers=org["h"],
    )
    llm_mod._falso_global.respostas = [saida_valida(confianca=0.3)]
    r = cliente.post(
        f"/v1/organizacoes/{org['id']}/importacoes",
        data={"lista_id": org["lista"]},
        files={"arquivo": ("isbns.csv", csv_, "text/csv")},
        headers=org["h"],
    ).json()
    andamento = cliente.get(
        f"/v1/organizacoes/{org['id']}/importacoes/{r['tarefa_id']}", headers=org["h"]
    ).json()
    res = andamento["resultado"]
    assert andamento["estado"] == "ok"
    assert (res["aceitos"], res["rejeitados"], res["nao_encontrados"]) == (1, 1, 1)
    assert res["analises_pendentes"] == 1
    # A obra entrou na lista e, com o LLM falso, a análise já publicou a ficha.
    d = cliente.get(f"/v1/organizacoes/{org['id']}/listas/{org['lista']}", headers=org["h"]).json()
    assert d["itens"][0]["obra"]["status_ficha"] == "publicada"


def test_relatorio_json_csv_pdf(cliente, org, sessao, demo):
    cliente.post(
        "/v1/assinaturas/checkout",
        json={"plano": "escola", "organizacao_id": org["id"]},
        headers=org["h"],
    )
    for titulo in ("O Jardim de Vidro", "A Ilha dos Relógios", "Depois da Meia-Noite"):
        cliente.post(
            f"/v1/listas/{org['lista']}/itens",
            json={"obra_id": str(demo[titulo].id)},
            headers=org["h"],
        )
    base = f"/v1/organizacoes/{org['id']}/listas/{org['lista']}/relatorio"
    r = cliente.get(base, headers=org["h"]).json()
    assert r["total"] == 3
    dist = {d["faixa"]: d["quantidade"] for d in r["distribuicao_faixa"]}
    assert dist["14+"] == 1 and dist["18+"] == 1 and dist["Livre"] == 1
    assert {o["titulo"] for o in r["acima_da_idade"]} == {
        "O Jardim de Vidro",
        "Depois da Meia-Noite",
    }
    assert any(a["alerta"] == "Luto" for a in r["alertas_frequentes"])
    csv_ = cliente.get(base, params={"formato": "csv"}, headers=org["h"])
    assert "O Jardim de Vidro" in csv_.content.decode("utf-8-sig")
    pdf = cliente.get(base, params={"formato": "pdf"}, headers=org["h"])
    assert pdf.content.startswith(b"%PDF")


# --------------------------------------------------------------------- revisão


@pytest.fixture
def revisora(sessao):
    return criar_usuario(sessao, "rev@teste.br", papel="revisor")


def test_revisao_exige_papel(cliente, usuario, demo):
    assert cliente.get("/v1/revisao/fila", headers=cabecalho(usuario)).status_code == 403
    assert cliente.get("/v1/revisao/fila").status_code == 401


def test_fila_e_publicacao_recalcula_faixa(cliente, revisora, demo, sessao):
    h = cabecalho(revisora)
    fila = cliente.get("/v1/revisao/fila", headers=h).json()
    titulos = [f["titulo"] for f in fila]
    assert "A Ilha dos Relógios" not in titulos  # já revisada
    assert "Vozes do Pátio" in titulos  # contestada
    obra = demo["O Jardim de Vidro"]
    d = cliente.get(f"/v1/revisao/fichas/{obra.id}", headers=h).json()
    editavel = d["editavel"]
    editavel["camada_a"]["A6"] = {"nivel": 1, "justificativa": "Abuso só mencionado, sem cena."}
    corpo = {k: editavel[k] for k in ("camada_a", "evidencias", "camada_b", "camada_c")}
    # Prévia não publica.
    p = cliente.post(
        f"/v1/revisao/fichas/{obra.id}/previa", json={**corpo, "motivo": "teste"}, headers=h
    ).json()
    assert p["faixa_final"] == "12+"
    assert sessao.query(Ficha).filter_by(obra_id=obra.id).one().faixa_final == "14+"
    # Motivo é obrigatório.
    assert (
        cliente.post(
            f"/v1/revisao/fichas/{obra.id}", json={**corpo, "motivo": ""}, headers=h
        ).status_code
        == 422
    )
    r = cliente.post(
        f"/v1/revisao/fichas/{obra.id}",
        json={**corpo, "motivo": "Revisão editorial: A6 é só contexto."},
        headers=h,
    ).json()
    assert r["faixa_final"] == "12+" and r["status"] == "publicada"
    ficha = sessao.query(Ficha).filter_by(obra_id=obra.id).one()
    sessao.refresh(ficha)
    assert ficha.revisada_por_humano is True
    versao = (
        sessao.query(FichaVersao)
        .filter_by(ficha_id=ficha.id)
        .order_by(FichaVersao.versao.desc())
        .first()
    )
    assert versao.autor_papel == "revisor" and "A6" in versao.motivo


def test_revisao_invalida_e_regra_a5(cliente, revisora, demo):
    h = cabecalho(revisora)
    obra = demo["Ruído Branco em Agosto"]
    ed = cliente.get(f"/v1/revisao/fichas/{obra.id}", headers=h).json()["editavel"]
    ed["evidencias"][0]["trecho_literal"] = "detalhe proibido"
    corpo = {k: ed[k] for k in ("camada_a", "evidencias", "camada_b", "camada_c")}
    r = cliente.post(
        f"/v1/revisao/fichas/{obra.id}", json={**corpo, "motivo": "tentativa"}, headers=h
    )
    assert r.status_code == 422 and r.json()["codigo"] == "revisao_invalida"


def test_responder_contestacao_avisa_e_libera_ficha(cliente, revisora, demo, sessao):
    obra = demo["Vozes do Pátio"]
    c = sessao.query(Contestacao).one()
    email = obter_email()
    email.enviados.clear()
    r = cliente.post(
        f"/v1/revisao/contestacoes/{c.id}",
        json={"decisao": "recusada", "resposta": "Os xingamentos são recorrentes."},
        headers=cabecalho(revisora),
    ).json()
    assert r == {"status": "recusada", "ficha_status": "publicada"}
    assert email.enviados and "Vozes do Pátio" in email.enviados[-1][1]
    ficha = sessao.query(Ficha).filter_by(obra_id=obra.id).one()
    sessao.refresh(ficha)
    assert ficha.status == "publicada"


def test_admin_analisa_texto_integral(cliente, sessao, demo):
    adm = criar_usuario(sessao, "adm@teste.br", papel="admin")
    obra = demo["O Último Farol"]
    s = saida_valida(confianca=0.9)
    s["camada_a"]["A1"] = {"nivel": 2, "justificativa": "briga"}
    s["evidencias"] = [
        {
            "eixo": "A1",
            "parafrase": "Briga no farol.",
            "trecho_literal": "e brigaram",
            "fonte": "texto",
            "por_que_selecionado": "",
        }
    ]
    llm_mod._falso_global.respostas = [s]
    texto = ("palavra " * 300).encode()
    r = cliente.post(
        f"/v1/admin/obras/{obra.id}/texto",
        data={"fonte": "texto_integral"},
        files={"arquivo": ("obra.txt", texto, "text/plain")},
        headers=cabecalho(adm),
    )
    assert r.status_code == 202
    ficha = sessao.query(Ficha).filter_by(obra_id=obra.id).one()
    sessao.refresh(ficha)
    assert ficha.dados["procedencia"]["fonte_da_analise"] == "texto_integral"
    assert ficha.dados["evidencias"][0]["trecho_literal"] == "e brigaram"  # guardado...
    u = criar_usuario(sessao, "leitor@teste.br")
    vista = cliente.get(f"/v1/obras/{obra.id}/ficha", headers=cabecalho(u)).json()["ficha"]
    assert vista["evidencias"][0]["trecho_literal"] is None  # ...mas não exibido (flag desligada)
    assert (
        cliente.post(
            f"/v1/admin/obras/{obra.id}/texto",
            files={"arquivo": ("o.txt", texto, "text/plain")},
            headers=cabecalho(u),
        ).status_code
        == 403
    )
