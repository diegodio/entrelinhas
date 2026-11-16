from __future__ import annotations

from collections.abc import Iterator
from functools import lru_cache

from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from app.config import configuracoes


class Base(DeclarativeBase):
    pass


@lru_cache
def motor() -> Engine:
    return create_engine(configuracoes().database_url, pool_pre_ping=True, future=True)


@lru_cache
def fabrica_sessao() -> sessionmaker[Session]:
    return sessionmaker(bind=motor(), expire_on_commit=False, future=True)


def obter_sessao() -> Iterator[Session]:
    sessao = fabrica_sessao()()
    try:
        yield sessao
    finally:
        sessao.close()
