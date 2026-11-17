"""Aplicação FastAPI do Entrelinhas."""

from __future__ import annotations

from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app import erros
from app.api import auth, eu, listas, obras, publico
from app.config import configuracoes
from app.servicos.limitador import LimitadorMiddleware

PASTA_ESTATICA = Path(__file__).parent / "estatico"


def criar_app() -> FastAPI:
    cfg = configuracoes()
    if cfg.ambiente == "producao" and (
        cfg.jwt_segredo.startswith("troque-este-segredo") or len(cfg.jwt_segredo) < 32
    ):
        raise RuntimeError("Defina JWT_SEGREDO com ao menos 32 caracteres aleatórios em produção.")
    app = FastAPI(
        title="Entrelinhas API",
        version="0.1.0",
        description="Orientação de Leitura para livros. "
        "Orientação editorial independente, sem vínculo com o Ministério da Justiça "
        "ou com o sistema ClassInd.",
    )
    erros.registrar(app)
    app.add_middleware(LimitadorMiddleware)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=cfg.lista_cors,
        allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?"
        if cfg.ambiente != "producao"
        else None,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    for modulo in _modulos_de_rotas():
        app.include_router(modulo.rotas)

    PASTA_ESTATICA.mkdir(exist_ok=True)
    app.mount("/estatico", StaticFiles(directory=PASTA_ESTATICA), name="estatico")
    if cfg.armazenamento == "local":
        pasta = Path(cfg.pasta_arquivos)
        pasta.mkdir(parents=True, exist_ok=True)

    @app.get("/saude", tags=["infra"])
    def saude():
        return {"ok": True}

    return app


def _modulos_de_rotas():
    return [auth, eu, listas, obras, publico]


app = criar_app()
