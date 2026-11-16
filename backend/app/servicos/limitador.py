"""Limite de requisições por IP (janela fixa de um minuto). Redis quando houver; memória senão."""

from __future__ import annotations

import time
from collections import defaultdict
from threading import Lock

from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import JSONResponse

from app.config import configuracoes


class _Contador:
    def __init__(self, redis_url: str | None):
        self._lock = Lock()
        self._memoria: dict[str, int] = defaultdict(int)
        self._janela = 0
        self._redis = None
        if redis_url:
            try:
                import redis

                self._redis = redis.Redis.from_url(redis_url, socket_timeout=0.2)
                self._redis.ping()
            except Exception:  # sem Redis, cai para memória
                self._redis = None

    def incrementar(self, chave: str) -> int:
        janela = int(time.time() // 60)
        if self._redis is not None:
            try:
                nome = f"lim:{janela}:{chave}"
                with self._redis.pipeline() as p:
                    p.incr(nome)
                    p.expire(nome, 120)
                    return int(p.execute()[0])
            except Exception:
                pass
        with self._lock:
            if janela != self._janela:
                self._memoria.clear()
                self._janela = janela
            self._memoria[chave] += 1
            return self._memoria[chave]


class LimitadorMiddleware(BaseHTTPMiddleware):
    def __init__(self, app):
        super().__init__(app)
        cfg = configuracoes()
        self.contador = _Contador(cfg.redis_url)
        self.limite_geral = cfg.limite_requisicoes_por_minuto
        self.limite_reconhecimento = cfg.limite_reconhecimento_por_minuto

    async def dispatch(self, request: Request, call_next):
        caminho = request.url.path
        if not caminho.startswith("/v1/") or configuracoes().ambiente == "teste":
            return await call_next(request)
        ip = request.headers.get("x-forwarded-for", "").split(",")[0].strip() or (
            request.client.host if request.client else "?"
        )
        grupo, limite = (
            ("rec", self.limite_reconhecimento)
            if caminho.startswith("/v1/reconhecimento")
            else ("geral", self.limite_geral)
        )
        if self.contador.incrementar(f"{grupo}:{ip}") > limite:
            return JSONResponse(
                {
                    "codigo": "muitas_requisicoes",
                    "mensagem": "Muitas requisições em pouco tempo. Aguarde um minuto.",
                    "detalhes": {},
                },
                status_code=429,
            )
        return await call_next(request)
