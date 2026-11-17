"""Worker da fila. Uso: python -m app.worker  (requer REDIS_URL e TAREFAS_MODO=fila)."""

from redis import Redis
from rq import Queue, Worker

from app.config import configuracoes
from app.tarefas import FILA


def main() -> None:
    conexao = Redis.from_url(configuracoes().redis_url or "redis://localhost:6379")
    Worker([Queue(FILA, connection=conexao)], connection=conexao).work()


if __name__ == "__main__":
    main()
