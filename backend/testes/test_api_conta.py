from app.modelos import Assinatura, Ficha, TokenRenovacao
from app.provedores.email import obter_email

from .conftest import cabecalho, criar_usuario


def cadastrar(cliente, email="nova@teste.br", senha="senha-boa-123"):
    return cliente.post("/v1/auth/cadastro",
                        json={"email": email, "senha": senha, "nome": "Nova", "aceite_termos": True})


def test_cadastro_login_e_eu(cliente):
    r = cadastrar(cliente)
    assert r.status_code == 201
    tokens = r.json()
    eu = cliente.get("/v1/eu", headers={"Authorization": f"Bearer {tokens['token_acesso']}"}).json()
    assert eu["email"] == "nova@teste.br" and eu["uso"]["plano"] == "gratuito"
    assert eu["uso"]["consultas_limite"] == 10
    assert cadastrar(cliente).json()["codigo"] == "email_em_uso"
    r = cliente.post("/v1/auth/entrar", json={"email": "NOVA@teste.br", "senha": "senha-boa-123"})
    assert r.status_code == 200
    r = cliente.post("/v1/auth/entrar", json={"email": "nova@teste.br", "senha": "errada-123"})
    assert r.status_code == 401 and r.json()["codigo"] == "credenciais_invalidas"


def test_cadastro_exige_aceite_e_senha(cliente):
    r = cliente.post("/v1/auth/cadastro",
                     json={"email": "a@b.br", "senha": "senha-boa-1", "aceite_termos": False})
    assert r.json()["codigo"] == "aceite_obrigatorio"
    r = cliente.post("/v1/auth/cadastro",
                     json={"email": "a@b.br", "senha": "curta", "aceite_termos": True})
    assert r.status_code == 422 and r.json()["codigo"] == "dados_invalidos"


def test_renovacao_com_rotacao_e_reuso(cliente, sessao):
    t1 = cadastrar(cliente).json()
    t2 = cliente.post("/v1/auth/renovar", json={"token_renovacao": t1["token_renovacao"]}).json()
    assert t2["token_renovacao"] != t1["token_renovacao"]
    # Reusar o token já rotacionado revoga tudo.
    r = cliente.post("/v1/auth/renovar", json={"token_renovacao": t1["token_renovacao"]})
    assert r.status_code == 401
    r = cliente.post("/v1/auth/renovar", json={"token_renovacao": t2["token_renovacao"]})
    assert r.status_code == 401
    assert all(t.revogado for t in sessao.query(TokenRenovacao).all())


def test_token_invalido_e_expirado(cliente):
    r = cliente.get("/v1/eu", headers={"Authorization": "Bearer lixo"})
    assert r.status_code == 401 and r.json()["codigo"] == "nao_autenticado"
    assert cliente.get("/v1/eu").status_code == 401


def test_recuperacao_de_senha(cliente):
    cadastrar(cliente)
    email = obter_email()
    email.enviados.clear()
    assert cliente.post("/v1/auth/recuperar", json={"email": "ninguem@x.br"}).status_code == 202
    assert email.enviados == []
    cliente.post("/v1/auth/recuperar", json={"email": "nova@teste.br"})
    link = email.enviados[-1][2]
    token = link.split("token=")[1].split()[0]
    assert cliente.post("/v1/auth/redefinir",
                        json={"token": token, "senha": "outra-senha-9"}).status_code == 200
    assert cliente.post("/v1/auth/redefinir",
                        json={"token": token, "senha": "outra-senha-9"}).status_code == 400
    r = cliente.post("/v1/auth/entrar", json={"email": "nova@teste.br", "senha": "outra-senha-9"})
    assert r.status_code == 200


def test_login_social_sem_configuracao(cliente):
    r = cliente.post("/v1/auth/google", json={"id_token": "x"})
    assert r.status_code == 503 and r.json()["codigo"] == "login_social_indisponivel"


def test_leitores_limite_do_plano(cliente, usuario, sessao):
    h = cabecalho(usuario)
    r = cliente.post("/v1/perfis", json={"apelido": "Lia", "ano_nascimento": 2014}, headers=h)
    assert r.status_code == 201
    r = cliente.post("/v1/perfis", json={"apelido": "Téo", "ano_nascimento": 2016}, headers=h)
    assert r.status_code == 402 and r.json()["codigo"] == "plano_necessario"
    sessao.add(Assinatura(usuario_id=usuario.id, plano="familia", origem="falso"))
    sessao.commit()
    r = cliente.post("/v1/perfis", json={"apelido": "Téo", "ano_nascimento": 2016}, headers=h)
    assert r.status_code == 201
    assert len(cliente.get("/v1/perfis", headers=h).json()) == 2
    outro = criar_usuario(sessao, "outro@teste.br")
    pid = r.json()["id"]
    assert cliente.delete(f"/v1/perfis/{pid}", headers=cabecalho(outro)).status_code == 404


def test_privacidade_consentimento_exportacao_e_exclusao(cliente, usuario, sessao):
    h = cabecalho(usuario)
    r = cliente.patch("/v1/eu", json={"contribuir_imagens": True}, headers=h).json()
    assert r["contribuir_imagens"] is True
    exp = cliente.get("/v1/eu/exportacao", headers=h).json()
    assert any(c["documento"] == "imagens" for c in exp["consentimentos"])
    assert cliente.delete("/v1/eu", headers=h).status_code == 204
    assert cliente.get("/v1/eu", headers=h).status_code == 401


def test_listas_padrao_itens_e_limite(cliente, usuario, demo):
    h = cabecalho(usuario)
    listas = cliente.get("/v1/listas", headers=h).json()
    assert [lista["nome"] for lista in listas] == ["Quero ler", "Aprovados"]
    obra = demo["O Jardim de Vidro"]
    lid = listas[0]["id"]
    assert cliente.post(f"/v1/listas/{lid}/itens", json={"obra_id": str(obra.id)},
                        headers=h).json()["quantidade"] == 1
    # Repetir não duplica.
    cliente.post(f"/v1/listas/{lid}/itens", json={"obra_id": str(obra.id)}, headers=h)
    detalhe = cliente.get(f"/v1/listas/{lid}", headers=h).json()
    assert len(detalhe["itens"]) == 1 and detalhe["itens"][0]["obra"]["faixa_final"] == "14+"
    assert "luto" in detalhe["itens"][0]["obra"]["alertas"]
    assert cliente.post("/v1/listas", json={"nome": "Férias"}, headers=h).status_code == 201
    r = cliente.post("/v1/listas", json={"nome": "Outra"}, headers=h)
    assert r.status_code == 402
    cliente.delete(f"/v1/listas/{lid}/itens/{obra.id}", headers=h)
    assert cliente.get(f"/v1/listas/{lid}", headers=h).json()["itens"] == []


def test_lista_de_outra_pessoa_nao_aparece(cliente, usuario, sessao):
    lid = cliente.get("/v1/listas", headers=cabecalho(usuario)).json()[0]["id"]
    outro = criar_usuario(sessao, "outro@teste.br")
    assert cliente.get(f"/v1/listas/{lid}", headers=cabecalho(outro)).status_code == 404


def test_contestacao_coloca_ficha_em_revisao(cliente, usuario, demo, sessao):
    obra = demo["O Jardim de Vidro"]
    h = cabecalho(usuario)
    r = cliente.post(f"/v1/obras/{obra.id}/contestacoes",
                     json={"campo": "A1", "texto": "A briga é só mencionada, não descrita."},
                     headers=h)
    assert r.status_code == 201
    assert sessao.query(Ficha).filter_by(obra_id=obra.id).one().status == "em_revisao"
    ficha = cliente.get(f"/v1/obras/{obra.id}/ficha", headers=h).json()["ficha"]
    assert ficha["status"] == "em_revisao"
    assert cliente.get("/v1/eu/contestacoes", headers=h).json()[0]["status"] == "aberta"
    r = cliente.post(f"/v1/obras/{obra.id}/contestacoes", json={"campo": "xyz", "texto": "1234567890"},
                     headers=h)
    assert r.json()["codigo"] == "campo_invalido"


def test_pdf_so_em_plano_pago(cliente, usuario, demo, sessao):
    obra = demo["Ruído Branco em Agosto"]
    h = cabecalho(usuario)
    r = cliente.get(f"/v1/obras/{obra.id}/ficha/pdf", headers=h)
    assert r.status_code == 402 and r.json()["codigo"] == "plano_necessario"
    sessao.add(Assinatura(usuario_id=usuario.id, plano="familia", origem="falso"))
    sessao.commit()
    r = cliente.get(f"/v1/obras/{obra.id}/ficha/pdf", headers=h)
    assert r.status_code == 200 and r.content.startswith(b"%PDF")
