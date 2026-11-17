"""Revisão editorial e contestações (seção 4.10). Papéis: revisor e admin.

O revisor ajusta níveis, alertas, perfil e textos, com motivo obrigatório. A faixa é
recalculada pelo mesmo código da seção 3.1: o revisor nunca digita faixa.
"""

from __future__ import annotations

import copy
import uuid
from datetime import UTC, datetime

from fastapi import APIRouter, Depends, File, Form, UploadFile
from pydantic import BaseModel, Field
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app import tarefas
from app.core.ficha import ficha_para_saida, montar_ficha
from app.db import obter_sessao
from app.erros import ErroApi, nao_encontrado
from app.modelos import Consulta, Contestacao, Ficha, FichaVersao, Obra, Usuario
from app.motor.validador import SaidaModeloInvalida, validar_saida_modelo
from app.provedores.email import ProvedorEmail, obter_email
from app.seguranca import exigir_papel
from app.servicos import configuracao as cfg_servico
from app.servicos import fichas as fichas_servico
from app.servicos import obras as obras_servico

rotas = APIRouter(prefix="/v1", tags=["revisão"])
revisor = exigir_papel("revisor", "admin")
admin = exigir_papel("admin")


def _abertas(sessao: Session, ficha_id) -> int:
    return (
        sessao.scalar(
            select(func.count(Contestacao.id)).where(
                Contestacao.ficha_id == ficha_id, Contestacao.status == "aberta"
            )
        )
        or 0
    )


@rotas.get("/revisao/fila")
def fila(_: Usuario = Depends(revisor), sessao: Session = Depends(obter_sessao)):
    """Não revisadas e contestadas: mais consultadas primeiro, depois menor confiança."""
    consultas = (
        select(Consulta.obra_id, func.count(Consulta.id).label("n"))
        .group_by(Consulta.obra_id)
        .subquery()
    )
    linhas = sessao.execute(
        select(Ficha, Obra, func.coalesce(consultas.c.n, 0))
        .join(Obra, Obra.id == Ficha.obra_id)
        .outerjoin(consultas, consultas.c.obra_id == Ficha.obra_id)
        .where(Ficha.status.in_(fichas_servico.STATUS_VISIVEIS))
        .where((Ficha.revisada_por_humano.is_(False)) | (Ficha.status == "em_revisao"))
        .order_by(func.coalesce(consultas.c.n, 0).desc(), Ficha.confianca.asc())
        .limit(200)
    ).all()
    return [
        {
            "obra_id": str(o.id),
            "titulo": o.titulo,
            "autores": o.autores,
            "faixa_final": f.faixa_final,
            "confianca": f.confianca,
            "status": f.status,
            "fonte_da_analise": f.fonte_da_analise,
            "consultas": n,
            "contestacoes_abertas": _abertas(sessao, f.id),
            "demonstracao": o.demonstracao,
        }
        for f, o, n in linhas
    ]


def _ficha(sessao: Session, obra_id: str) -> tuple[Obra, Ficha]:
    obra = obras_servico.obter(sessao, obra_id)
    if obra is None or obra.ficha is None or not obra.ficha.dados:
        raise nao_encontrado("Ficha")
    return obra, obra.ficha


@rotas.get("/revisao/fichas/{obra_id}")
def ver(obra_id: str, _: Usuario = Depends(revisor), sessao: Session = Depends(obter_sessao)):
    obra, ficha = _ficha(sessao, obra_id)
    contestacoes = sessao.scalars(
        select(Contestacao)
        .where(Contestacao.ficha_id == ficha.id)
        .order_by(Contestacao.criado_em.desc())
    ).all()
    versoes = sessao.scalars(
        select(FichaVersao)
        .where(FichaVersao.ficha_id == ficha.id)
        .order_by(FichaVersao.versao.desc())
    ).all()
    return {
        "obra": obras_servico.detalhe(obra),
        "ficha": ficha.dados,
        "editavel": ficha_para_saida(ficha.dados),
        "contestacoes": [
            {
                "id": str(c.id),
                "campo": c.campo,
                "texto": c.texto,
                "status": c.status,
                "resposta": c.resposta,
                "criado_em": c.criado_em.isoformat(),
            }
            for c in contestacoes
        ],
        "historico": [
            {
                "versao": v.versao,
                "autor_papel": v.autor_papel,
                "motivo": v.motivo,
                "faixa_final": v.dados.get("faixa_final"),
                "criado_em": v.criado_em.isoformat(),
            }
            for v in versoes
        ],
    }


class Revisao(BaseModel):
    camada_a: dict
    evidencias: list[dict] = Field(default_factory=list)
    camada_b: dict
    camada_c: dict
    motivo: str = Field(min_length=5, max_length=2000)


@rotas.post("/revisao/fichas/{obra_id}/previa")
def previa(
    obra_id: str,
    dados: Revisao,
    _: Usuario = Depends(revisor),
    sessao: Session = Depends(obter_sessao),
):
    """Recalcula a faixa sem publicar (a tela mostra o efeito de cada ajuste)."""
    obra, ficha = _ficha(sessao, obra_id)
    return _montar(sessao, obra, ficha, dados, revisor_publicando=False)


def _montar(sessao: Session, obra: Obra, ficha: Ficha, dados: Revisao, revisor_publicando: bool):
    anterior = ficha.dados
    saida = {
        "camada_a": dados.camada_a,
        "evidencias": dados.evidencias,
        "camada_b": dados.camada_b,
        "camada_c": dados.camada_c,
        "confianca": anterior["procedencia"]["confianca"],
        "observacoes": "",
    }
    fonte = anterior["procedencia"]["fonte_da_analise"]
    try:
        validar_saida_modelo(copy.deepcopy(saida), fonte, exigir_confianca=False)
    except SaidaModeloInvalida as e:
        raise ErroApi(
            422, "revisao_invalida", "A revisão tem problemas.", {"erros": e.erros}
        ) from e
    limites = cfg_servico.carregar(sessao)["limites"]
    procedencia = {**anterior["procedencia"]}
    if revisor_publicando:
        procedencia |= {"revisada_por_humano": True, "revisada_em": datetime.now(UTC).isoformat()}
    return montar_ficha(
        obra_id=str(obra.id),
        saida=saida,
        paginas=obra.paginas,
        procedencia=procedencia,
        versao_ficha=ficha.versao_ficha + 1,
        max_trechos=limites["trechos_por_ficha"],
        limite_palavras=limites["palavras_por_trecho"],
    )


@rotas.post("/revisao/fichas/{obra_id}")
def publicar(
    obra_id: str,
    dados: Revisao,
    usuario: Usuario = Depends(revisor),
    sessao: Session = Depends(obter_sessao),
):
    obra, ficha = _ficha(sessao, obra_id)
    nova = _montar(sessao, obra, ficha, dados, revisor_publicando=True)
    status = "em_revisao" if _abertas(sessao, ficha.id) else "publicada"
    # O histórico guarda o PAPEL do revisor, não o nome da pessoa.
    fichas_servico.publicar_versao(
        sessao,
        ficha,
        nova,
        autor_id=usuario.id,
        autor_papel=usuario.papel,
        motivo=dados.motivo.strip(),
        status=status,
    )
    return {
        "faixa_final": nova["faixa_final"],
        "versao_ficha": nova["versao_ficha"],
        "status": status,
    }


class Resposta(BaseModel):
    decisao: str = Field(pattern="^(aceita|recusada)$")
    resposta: str = Field(min_length=5, max_length=4000)


@rotas.post("/revisao/contestacoes/{contestacao_id}")
def responder(
    contestacao_id: str,
    dados: Resposta,
    _: Usuario = Depends(revisor),
    sessao: Session = Depends(obter_sessao),
    email: ProvedorEmail = Depends(obter_email),
):
    try:
        c = sessao.get(Contestacao, uuid.UUID(contestacao_id))
    except ValueError:
        c = None
    if c is None:
        raise nao_encontrado("Contestação")
    c.status, c.resposta, c.respondida_em = dados.decisao, dados.resposta.strip(), datetime.now(UTC)
    sessao.commit()
    ficha = sessao.get(Ficha, c.ficha_id)
    if not _abertas(sessao, ficha.id) and ficha.status == "em_revisao":
        ficha.status = "publicada"
        ficha.dados = {**ficha.dados, "status": "publicada"}
        sessao.commit()
    autor = sessao.get(Usuario, c.usuario_id)
    obra = sessao.get(Obra, ficha.obra_id)
    resultado = (
        "aceita: a ficha foi ajustada"
        if dados.decisao == "aceita"
        else "analisada: a ficha foi mantida"
    )
    email.enviar(
        autor.email,
        f"Entrelinhas: sua contestação sobre {obra.titulo}",
        f"Sua contestação foi {resultado}.\n\nResposta do editor:\n{c.resposta}",
    )
    return {"status": c.status, "ficha_status": ficha.status}


@rotas.post("/admin/obras/{obra_id}/texto", status_code=202)
async def analisar_texto(
    obra_id: str,
    fonte: str = Form("texto_integral"),
    arquivo: UploadFile = File(...),
    _: Usuario = Depends(admin),
    sessao: Session = Depends(obter_sessao),
):
    """Obra em domínio público ou com autorização da editora: análise sobre o texto.
    Sem tela para o usuário comum (seção 4.4)."""
    if fonte not in ("texto_integral", "amostragem"):
        raise ErroApi(400, "fonte_invalida", "Use texto_integral ou amostragem.")
    obra = obras_servico.obter(sessao, obra_id)
    if obra is None:
        raise nao_encontrado("Obra")
    texto = (await arquivo.read(20 * 1024 * 1024)).decode("utf-8", errors="replace")
    if len(texto.split()) < 200:
        raise ErroApi(400, "texto_curto", "O arquivo tem texto de menos para análise.")
    tarefa = tarefas.enfileirar_analise(sessao, obra, texto=texto, fonte_texto=fonte)
    return {"tarefa_id": str(tarefa.id)}
