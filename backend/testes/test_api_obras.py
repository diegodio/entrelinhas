from app.deps import obter_cascata
from app.main import app
from app.provedores.metadados import Cascata, FonteIndisponivel, MetadadosObra
from app.servicos import configuracao as cfg_servico

from .conftest import cabecalho, criar_usuario


class FonteFalsa:
    nome = "google_books"

    def __init__(self, livros=None, falhar=False):
        self.livros = livros or {}
        self.falhar = falhar

    def por_isbn(self, isbn13):
        if self.falhar:
            raise FonteIndisponivel(self.nome)
        return self.livros.get(isbn13)

    def buscar(self, termo, limite=10):
        if self.falhar:
            raise FonteIndisponivel(self.nome)
        return [m for m in self.livros.values() if termo.lower() in m.titulo.lower()]


def usar_fontes(*fontes):
    app.dependency_overrides[obter_cascata] = lambda: Cascata(list(fontes))


def test_busca_local_por_titulo_e_autor(cliente, demo):
    r = cliente.get("/v1/obras", params={"busca": "jardim"}).json()
    assert [o["titulo"] for o in r["resultados"]] == ["O Jardim de Vidro"]
    r = cliente.get("/v1/obras", params={"busca": "Alcantara"}).json()  # sem acento: trigramas
    assert r["resultados"] and r["resultados"][0]["titulo"] == "O Jardim de Vidro"


def test_busca_curta_e_isbn_invalido(cliente):
    r = cliente.get("/v1/obras", params={"busca": "ab"})
    assert r.status_code == 400 and r.json()["codigo"] == "busca_curta"
    r = cliente.get("/v1/obras", params={"busca": "9780306406158"})
    assert r.status_code == 400 and r.json()["codigo"] == "isbn_invalido"


def test_isbn_pela_cascata_cria_obra_e_edicao(cliente, sessao):
    usar_fontes(
        FonteFalsa(
            {
                "9780306406157": MetadadosObra(
                    titulo="Livro Externo",
                    autores=["Autora X"],
                    paginas=200,
                    isbn13="9780306406157",
                    fonte="google_books",
                )
            }
        )
    )
    r = cliente.get("/v1/obras", params={"busca": "0-306-40615-2"}).json()
    assert r["isbn"] == "9780306406157"
    assert r["resultados"][0]["status_ficha"] == "sem_ficha"
    obra_id = r["resultados"][0]["id"]
    # Segunda consulta vem da base própria, sem duplicar.
    r2 = cliente.get("/v1/obras/isbn/9780306406157").json()
    assert r2["id"] == obra_id and r2["edicoes"][0]["isbn10"] == "0306406152"


def test_isbn_nao_reconhecido(cliente):
    usar_fontes(FonteFalsa({}))
    r = cliente.get("/v1/obras/isbn/9780306406157")
    assert r.status_code == 404 and r.json()["codigo"] == "obra_nao_encontrada"


def test_fontes_externas_indisponiveis(cliente, demo):
    usar_fontes(FonteFalsa(falhar=True))
    r = cliente.get("/v1/obras", params={"busca": "inexistente qualquer"}).json()
    assert r["fontes_externas_indisponiveis"] is True
    assert r["resultados"] == []


def test_resumo_publico_nao_exige_conta(cliente, demo):
    obra = demo["O Jardim de Vidro"]
    r = cliente.get(f"/v1/obras/{obra.id}/ficha/resumo").json()
    assert r["resumo"]["faixa_final"] == "14+"
    assert r["resumo"]["texto_recomendacao"] == (
        "Recomendada com mediação de adulto a partir de 14 anos."
    )


def test_ficha_completa_exige_conta(cliente, demo):
    obra = demo["O Jardim de Vidro"]
    r = cliente.get(f"/v1/obras/{obra.id}/ficha")
    assert r.status_code == 401
    assert r.json()["detalhes"]["resumo"]["faixa_final"] == "14+"


def test_ficha_sem_ficha(cliente, demo, usuario):
    obra = demo["O Último Farol"]
    r = cliente.get(f"/v1/obras/{obra.id}/ficha", headers=cabecalho(usuario)).json()
    assert r == {"status_ficha": "sem_ficha", "ficha": None, "uso": None}


def test_limite_mensal_e_reabertura(cliente, demo, sessao, usuario):
    cfg_servico.definir(sessao, "limite.consultas_gratis_mes", 2)
    com_ficha = [o for o in demo.values() if o.titulo != "O Último Farol"]
    h = cabecalho(usuario)
    for obra in com_ficha[:2]:
        r = cliente.get(f"/v1/obras/{obra.id}/ficha", headers=h)
        assert r.status_code == 200
    assert r.json()["uso"]["consultas_usadas"] == 2
    # Terceira obra nova: limite. O resumo continua disponível na resposta.
    r = cliente.get(f"/v1/obras/{com_ficha[2].id}/ficha", headers=h)
    assert r.status_code == 402 and r.json()["codigo"] == "limite_atingido"
    assert r.json()["detalhes"]["resumo"]["faixa_final"]
    # Reabrir uma ficha já vista não consome nem é bloqueado.
    r = cliente.get(f"/v1/obras/{com_ficha[0].id}/ficha", headers=h)
    assert r.status_code == 200 and r.json()["uso"]["consultas_usadas"] == 2


def test_plano_pago_sem_limite(cliente, demo, sessao):
    from app.modelos import Assinatura

    u = criar_usuario(sessao, "familia@teste.br")
    sessao.add(Assinatura(usuario_id=u.id, plano="familia", origem="falso"))
    sessao.commit()
    cfg_servico.definir(sessao, "limite.consultas_gratis_mes", 0)
    obra = demo["O Jardim de Vidro"]
    r = cliente.get(f"/v1/obras/{obra.id}/ficha", headers=cabecalho(u))
    assert r.status_code == 200 and r.json()["uso"]["consultas_limite"] is None


def test_regra_a5_na_saida_com_qualquer_flag(cliente, demo, sessao, usuario):
    from app.modelos import Ficha

    obra = demo["Ruído Branco em Agosto"]
    ficha = sessao.query(Ficha).filter_by(obra_id=obra.id).one()
    # Mesmo que um trecho literal tenha ido parar no banco, ele não sai.
    dados = dict(ficha.dados)
    dados["evidencias"] = [{**dados["evidencias"][0], "trecho_literal": "texto proibido"}]
    ficha.dados = dados
    sessao.commit()
    cfg_servico.definir(sessao, "flag.trechos_literais", True)
    r = cliente.get(f"/v1/obras/{obra.id}/ficha", headers=cabecalho(usuario)).json()
    assert r["ficha"]["faixa_final"] == "16+"
    assert all(ev["trecho_literal"] is None for ev in r["ficha"]["evidencias"])
    assert "conduta de risco" in r["ficha"]["aviso_a5"]


def test_configuracao_e_metodologia(cliente):
    c = cliente.get("/v1/configuracao").json()
    assert c["flags"]["trechos_literais"] is False
    assert c["limites"]["consultas_gratis_mes"] == 10
    assert "reconhecimento" not in c["limites"]
    m = cliente.get("/v1/metodologia").json()
    assert len(m["eixos"]) == 6 and m["eixos"][1]["niveis"][3]["faixa"] == "16+"


def test_ficha_publica_compartilhavel(cliente, demo, sessao):
    from app.modelos import Ficha

    ficha = sessao.query(Ficha).filter_by(obra_id=demo["A Ilha dos Relógios"].id).one()
    r = cliente.get(f"/v1/publico/fichas/{ficha.slug}").json()
    assert r["resumo"]["texto_recomendacao"] == "Leitura livre, para todas as idades."
    assert r["resumo"]["revisada_por_humano"] is True
    cfg_servico.definir(sessao, "flag.compartilhar", False)
    assert cliente.get(f"/v1/publico/fichas/{ficha.slug}").status_code == 404


def test_demo_cobre_todos_os_casos(demo, sessao):
    from app.modelos import Ficha

    fichas = {f.obra.titulo: f for f in sessao.query(Ficha).all()}
    faixas = {f.faixa_final for f in fichas.values()}
    assert faixas == {"Livre", "10+", "12+", "14+", "16+", "18+"}
    assert fichas["Cinzas de Porto Alto"].dados["agravante_acumulo_aplicado"] is True
    assert fichas["Ruído Branco em Agosto"].dados["camada_a"]["A5"]["nivel"] == 3
    assert fichas["Vozes do Pátio"].status == "em_revisao"
    assert all(f.obra.demonstracao for f in fichas.values())
