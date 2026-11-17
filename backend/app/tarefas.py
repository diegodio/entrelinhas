"""Tarefas assíncronas: análise de obra e importação em lote.

Modos (TAREFAS_MODO): "fila" usa Redis + RQ (rode `rq worker entrelinhas`); "thread" roda
em segundo plano no próprio processo (desenvolvimento sem Redis); "sincrono" executa na
hora (testes).
"""

from __future__ import annotations

import logging
import threading
import uuid

from sqlalchemy.orm import Session

from app.config import configuracoes
from app.db import fabrica_sessao
from app.modelos import Ficha, Obra, Tarefa, agora

log = logging.getLogger("entrelinhas.tarefas")
FILA = "entrelinhas"


def _despachar(tarefa_id: str) -> None:
    modo = configuracoes().tarefas_modo
    if modo == "fila":
        from redis import Redis
        from rq import Queue

        Queue(FILA, connection=Redis.from_url(configuracoes().redis_url or "redis://")).enqueue(
            executar, tarefa_id, job_timeout=900
        )
    elif modo == "thread":
        threading.Thread(target=executar, args=(tarefa_id,), daemon=True).start()
    else:
        executar(tarefa_id)


def criar(sessao: Session, tipo: str, parametros: dict) -> Tarefa:
    tarefa = Tarefa(tipo=tipo, parametros=parametros)
    sessao.add(tarefa)
    sessao.commit()
    return tarefa


def enfileirar_analise(
    sessao: Session, obra: Obra, texto: str | None = None, fonte_texto: str = "texto_integral"
) -> Tarefa:
    """Marca a obra como em análise e despacha. A tela atualiza sozinha enquanto isso."""
    from app.servicos import fichas as fichas_servico

    ficha = obra.ficha
    if ficha is None:
        ficha = Ficha(
            obra_id=obra.id, slug=fichas_servico.novo_slug(sessao, obra), status="em_analise"
        )
        sessao.add(ficha)
    elif ficha.status in ("indisponivel", "em_analise"):
        ficha.status = "em_analise"
    sessao.commit()
    parametros = {"obra_id": str(obra.id)}
    if texto:
        parametros |= {"texto": texto, "fonte_texto": fonte_texto}
    tarefa = criar(sessao, "analise", parametros)
    _despachar(str(tarefa.id))
    return tarefa


def enfileirar_importacao(
    sessao: Session, organizacao_id: str, lista_id: str, isbns: list[str], usuario_id: str
) -> Tarefa:
    tarefa = criar(
        sessao,
        "importacao",
        {
            "organizacao_id": organizacao_id,
            "lista_id": lista_id,
            "isbns": isbns,
            "usuario_id": usuario_id,
        },
    )
    _despachar(str(tarefa.id))
    return tarefa


def executar(tarefa_id: str) -> None:
    with fabrica_sessao()() as sessao:
        tarefa = sessao.get(Tarefa, uuid.UUID(tarefa_id))
        if tarefa is None:
            return
        tarefa.estado = "rodando"
        tarefa.atualizada_em = agora()
        sessao.commit()
        try:
            if tarefa.tipo == "analise":
                resultado = _executar_analise(sessao, tarefa.parametros)
            elif tarefa.tipo == "importacao":
                from app.servicos.importacao import executar_importacao

                resultado = executar_importacao(sessao, tarefa)
            else:
                raise ValueError(f"Tipo de tarefa desconhecido: {tarefa.tipo}")
            tarefa.estado, tarefa.resultado, tarefa.erro = "ok", resultado, None
        except Exception as e:  # a tarefa registra qualquer falha; nada fica pela metade
            log.exception("Tarefa %s falhou", tarefa_id)
            sessao.rollback()
            tarefa = sessao.get(Tarefa, uuid.UUID(tarefa_id))
            tarefa.estado, tarefa.erro = "erro", str(e)[:2000]
            if tarefa.tipo == "analise":
                _marcar_indisponivel(sessao, tarefa.parametros["obra_id"], str(e))
        tarefa.atualizada_em = agora()
        sessao.commit()


def _executar_analise(sessao: Session, parametros: dict) -> dict:
    from app.deps import obter_cascata, obter_fontes_resenhas
    from app.motor.pipeline import analisar
    from app.provedores.llm import obter_llm
    from app.servicos import obras as obras_servico

    obra = obras_servico.obter(sessao, parametros["obra_id"])
    if obra is None:
        raise ValueError("Obra não encontrada.")
    ficha = analisar(
        sessao,
        obra,
        obter_llm(),
        obter_cascata(),
        obter_fontes_resenhas(),
        texto_obra=parametros.get("texto"),
        fonte_texto=parametros.get("fonte_texto", "texto_integral"),
    )
    return {"ficha_id": str(ficha.id), "faixa_final": ficha.faixa_final}


def _marcar_indisponivel(sessao: Session, obra_id: str, erro: str) -> None:
    ficha = sessao.query(Ficha).filter_by(obra_id=uuid.UUID(obra_id)).first()
    if ficha is None:
        return
    if ficha.dados and ficha.versao_ficha > 0:
        # Já havia ficha publicada: ela continua valendo.
        ficha.status = ficha.dados.get("status", "publicada")
    else:
        ficha.status = "indisponivel"
    ficha.erro = erro[:2000]
    sessao.commit()
