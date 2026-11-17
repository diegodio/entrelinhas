"""Formato único de erro: {"codigo", "mensagem", "detalhes"}."""

from __future__ import annotations

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException


class ErroApi(Exception):
    def __init__(self, status: int, codigo: str, mensagem: str, detalhes: dict | None = None):
        super().__init__(mensagem)
        self.status = status
        self.codigo = codigo
        self.mensagem = mensagem
        self.detalhes = detalhes or {}


def nao_encontrado(o_que: str = "Recurso") -> ErroApi:
    return ErroApi(404, "nao_encontrado", f"{o_que} não encontrado.")


def proibido(mensagem: str = "Você não tem permissão para isso.") -> ErroApi:
    return ErroApi(403, "proibido", mensagem)


def nao_autenticado() -> ErroApi:
    return ErroApi(401, "nao_autenticado", "Entre na sua conta para continuar.")


def _corpo(codigo: str, mensagem: str, detalhes: dict | None = None) -> dict:
    return {"codigo": codigo, "mensagem": mensagem, "detalhes": detalhes or {}}


def registrar(app: FastAPI) -> None:
    @app.exception_handler(ErroApi)
    async def _erro_api(_: Request, e: ErroApi):
        return JSONResponse(_corpo(e.codigo, e.mensagem, e.detalhes), status_code=e.status)

    @app.exception_handler(RequestValidationError)
    async def _validacao(_: Request, e: RequestValidationError):
        campos = [
            {"campo": ".".join(str(p) for p in err["loc"][1:]), "erro": err["msg"]}
            for err in e.errors()
        ]
        return JSONResponse(
            _corpo("dados_invalidos", "Alguns dados enviados são inválidos.", {"campos": campos}),
            status_code=422,
        )

    @app.exception_handler(StarletteHTTPException)
    async def _http(_: Request, e: StarletteHTTPException):
        codigos = {404: "nao_encontrado", 405: "metodo_nao_permitido", 401: "nao_autenticado"}
        return JSONResponse(
            _corpo(codigos.get(e.status_code, "erro_http"), str(e.detail)),
            status_code=e.status_code,
        )
