"""Fixtures. Testes de integração usam um Postgres de teste (TEST_DATABASE_URL), sem rede."""

from __future__ import annotations

import os

os.environ.setdefault(
    "TEST_DATABASE_URL", "postgresql+psycopg://postgres@/entrelinhas_teste?host=/tmp"
)
os.environ["DATABASE_URL"] = os.environ["TEST_DATABASE_URL"]
os.environ["AMBIENTE"] = "teste"
os.environ["FONTES_METADADOS"] = ""
os.environ["PROVEDOR_LLM"] = "falso"
os.environ["MOTOR_OCR"] = "falso"
os.environ["MODELO_CAPA"] = "falso"
os.environ["PROVEDOR_PAGAMENTO"] = "falso"
os.environ["PROVEDOR_EMAIL"] = "console"
os.environ["TAREFAS_MODO"] = "inline"
os.environ["PASTA_ARQUIVOS"] = "/tmp/entrelinhas-teste-arquivos"

import pytest  # noqa: E402
from sqlalchemy import text  # noqa: E402

from app.db import Base, fabrica_sessao, motor  # noqa: E402


def _banco_disponivel() -> bool:
    try:
        with motor().connect() as c:
            c.execute(text("select 1"))
        return True
    except Exception:
        return False


@pytest.fixture(scope="session")
def banco():
    if not _banco_disponivel():
        pytest.skip("Postgres de teste indisponível (defina TEST_DATABASE_URL).")
    from alembic import command
    from alembic.config import Config

    with motor().begin() as c:
        c.execute(text("DROP SCHEMA public CASCADE; CREATE SCHEMA public;"))
    cfg = Config(os.path.join(os.path.dirname(__file__), "..", "alembic.ini"))
    cfg.set_main_option(
        "script_location", os.path.join(os.path.dirname(__file__), "..", "migracoes")
    )
    command.upgrade(cfg, "head")
    yield motor()


@pytest.fixture
def sessao(banco):
    tabelas = ", ".join(t.name for t in reversed(Base.metadata.sorted_tables))
    with banco.begin() as c:
        c.execute(text(f"TRUNCATE {tabelas} RESTART IDENTITY CASCADE"))
    s = fabrica_sessao()()
    from app.servicos import configuracao

    configuracao.semear(s)
    yield s
    s.close()


@pytest.fixture
def cliente(sessao):
    from fastapi.testclient import TestClient

    from app.main import app

    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()


@pytest.fixture
def demo(sessao):
    from app.demo import semear_contas_demo, semear_demo

    semear_contas_demo(sessao)
    return {o.titulo: o for o in semear_demo(sessao)}


def criar_usuario(sessao, email="pessoa@teste.br", papel="usuario", senha="senha-segura-1"):
    from app.modelos import Usuario
    from app.seguranca import hash_senha

    u = Usuario(email=email, hash_senha=hash_senha(senha), nome="Pessoa", papel=papel)
    sessao.add(u)
    sessao.commit()
    return u


def cabecalho(usuario) -> dict:
    from app.seguranca import criar_token_acesso

    return {"Authorization": f"Bearer {criar_token_acesso(usuario)}"}


@pytest.fixture
def usuario(sessao):
    return criar_usuario(sessao)
