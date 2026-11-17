"""Escolas e bibliotecas: membros, listas de acervo e de turma, importação e relatórios."""

from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, File, Form, Query, UploadFile
from fastapi.responses import Response
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy import select
from sqlalchemy.orm import Session

from app import tarefas
from app.api.listas import detalhe_lista, resumo_lista
from app.db import obter_sessao
from app.erros import ErroApi, nao_encontrado
from app.modelos import Assinatura, Lista, MembroOrganizacao, Organizacao, Tarefa, Usuario
from app.seguranca import usuario_obrigatorio
from app.servicos import importacao, relatorios

rotas = APIRouter(prefix="/v1/organizacoes", tags=["organizações"])
PAPEIS = ("gestor", "bibliotecario", "professor")


def _org(sessao: Session, usuario: Usuario, org_id: str, papeis=PAPEIS) -> tuple[Organizacao, str]:
    try:
        oid = uuid.UUID(org_id)
    except ValueError as e:
        raise nao_encontrado("Instituição") from e
    org = sessao.get(Organizacao, oid)
    papel = sessao.scalar(
        select(MembroOrganizacao.papel).where(
            MembroOrganizacao.organizacao_id == oid, MembroOrganizacao.usuario_id == usuario.id
        )
    )
    if org is None or papel is None:
        raise nao_encontrado("Instituição")
    if papel not in papeis:
        raise ErroApi(403, "proibido", "Seu papel na instituição não permite esta ação.")
    return org, papel


def _exigir_plano_escola(sessao: Session, org: Organizacao) -> None:
    from app.servicos.planos import _ativa

    assinaturas = sessao.scalars(select(Assinatura).where(Assinatura.organizacao_id == org.id))
    if not any(_ativa(a) for a in assinaturas):
        raise ErroApi(
            402, "plano_necessario", "Importação e relatórios fazem parte do plano Escola."
        )


def _lista_da_org(sessao: Session, org: Organizacao, lista_id: str) -> Lista:
    try:
        lista = sessao.get(Lista, uuid.UUID(lista_id))
    except ValueError:
        lista = None
    if lista is None or lista.organizacao_id != org.id:
        raise nao_encontrado("Lista")
    return lista


class NovaOrganizacao(BaseModel):
    nome: str = Field(min_length=2, max_length=160)
    tipo: str = Field(default="escola", pattern="^(escola|biblioteca|rede)$")


@rotas.post("", status_code=201)
def criar(
    dados: NovaOrganizacao,
    usuario: Usuario = Depends(usuario_obrigatorio),
    sessao: Session = Depends(obter_sessao),
):
    org = Organizacao(nome=dados.nome.strip(), tipo=dados.tipo)
    sessao.add(org)
    sessao.flush()
    sessao.add(MembroOrganizacao(organizacao_id=org.id, usuario_id=usuario.id, papel="gestor"))
    sessao.commit()
    return {"id": str(org.id), "nome": org.nome, "tipo": org.tipo, "papel": "gestor"}


@rotas.get("/{org_id}")
def ver(
    org_id: str,
    usuario: Usuario = Depends(usuario_obrigatorio),
    sessao: Session = Depends(obter_sessao),
):
    from app.servicos.planos import _ativa

    org, papel = _org(sessao, usuario, org_id)
    membros = sessao.execute(
        select(MembroOrganizacao, Usuario)
        .join(Usuario, Usuario.id == MembroOrganizacao.usuario_id)
        .where(MembroOrganizacao.organizacao_id == org.id)
    ).all()
    listas = sessao.scalars(
        select(Lista).where(Lista.organizacao_id == org.id).order_by(Lista.criado_em)
    ).all()
    plano_ativo = any(
        _ativa(a)
        for a in sessao.scalars(select(Assinatura).where(Assinatura.organizacao_id == org.id))
    )
    return {
        "id": str(org.id),
        "nome": org.nome,
        "tipo": org.tipo,
        "meu_papel": papel,
        "plano_escola_ativo": plano_ativo,
        "membros": [
            {"usuario_id": str(u.id), "nome": u.nome, "email": u.email, "papel": m.papel}
            for m, u in membros
        ],
        "listas": [resumo_lista(sessao, lista) for lista in listas],
    }


class NovoMembro(BaseModel):
    email: EmailStr
    papel: str = Field(pattern="^(gestor|bibliotecario|professor)$")


@rotas.post("/{org_id}/membros", status_code=201)
def adicionar_membro(
    org_id: str,
    dados: NovoMembro,
    usuario: Usuario = Depends(usuario_obrigatorio),
    sessao: Session = Depends(obter_sessao),
):
    org, _ = _org(sessao, usuario, org_id, papeis=("gestor",))
    pessoa = sessao.scalars(select(Usuario).where(Usuario.email == dados.email.lower())).first()
    if pessoa is None:
        raise ErroApi(
            404,
            "usuario_nao_encontrado",
            "Não há conta com este e-mail. Peça para a pessoa criar uma conta primeiro.",
        )
    membro = sessao.scalars(
        select(MembroOrganizacao).where(
            MembroOrganizacao.organizacao_id == org.id, MembroOrganizacao.usuario_id == pessoa.id
        )
    ).first()
    if membro is None:
        sessao.add(
            MembroOrganizacao(organizacao_id=org.id, usuario_id=pessoa.id, papel=dados.papel)
        )
    else:
        membro.papel = dados.papel
    sessao.commit()
    return {"usuario_id": str(pessoa.id), "papel": dados.papel}


@rotas.delete("/{org_id}/membros/{usuario_id}", status_code=204)
def remover_membro(
    org_id: str,
    usuario_id: str,
    usuario: Usuario = Depends(usuario_obrigatorio),
    sessao: Session = Depends(obter_sessao),
):
    org, _ = _org(sessao, usuario, org_id, papeis=("gestor",))
    try:
        uid = uuid.UUID(usuario_id)
    except ValueError as e:
        raise nao_encontrado("Membro") from e
    gestores = sessao.scalars(
        select(MembroOrganizacao).where(
            MembroOrganizacao.organizacao_id == org.id, MembroOrganizacao.papel == "gestor"
        )
    ).all()
    if len(gestores) == 1 and gestores[0].usuario_id == uid:
        raise ErroApi(409, "ultimo_gestor", "A instituição precisa de ao menos um gestor.")
    m = sessao.scalars(
        select(MembroOrganizacao).where(
            MembroOrganizacao.organizacao_id == org.id, MembroOrganizacao.usuario_id == uid
        )
    ).first()
    if m is not None:
        sessao.delete(m)
        sessao.commit()


class NovaListaOrg(BaseModel):
    nome: str = Field(min_length=1, max_length=120)
    tipo: str = Field(default="acervo", pattern="^(acervo|turma)$")
    idade_referencia: int | None = Field(default=None, ge=0, le=18)
    ano_escolar: str | None = Field(default=None, max_length=40)


@rotas.post("/{org_id}/listas", status_code=201)
def criar_lista(
    org_id: str,
    dados: NovaListaOrg,
    usuario: Usuario = Depends(usuario_obrigatorio),
    sessao: Session = Depends(obter_sessao),
):
    org, papel = _org(sessao, usuario, org_id)
    if dados.tipo == "acervo" and papel == "professor":
        raise ErroApi(403, "proibido", "Listas de acervo são criadas pela biblioteca ou gestão.")
    lista = Lista(
        organizacao_id=org.id,
        nome=dados.nome.strip(),
        tipo=dados.tipo,
        idade_referencia=dados.idade_referencia,
        ano_escolar=dados.ano_escolar,
    )
    sessao.add(lista)
    sessao.commit()
    return resumo_lista(sessao, lista)


@rotas.get("/{org_id}/listas/{lista_id}")
def ver_lista(
    org_id: str,
    lista_id: str,
    usuario: Usuario = Depends(usuario_obrigatorio),
    sessao: Session = Depends(obter_sessao),
):
    org, _ = _org(sessao, usuario, org_id)
    return detalhe_lista(sessao, _lista_da_org(sessao, org, lista_id))


@rotas.post("/{org_id}/importacoes", status_code=202)
async def importar(
    org_id: str,
    lista_id: str = Form(...),
    arquivo: UploadFile = File(...),
    usuario: Usuario = Depends(usuario_obrigatorio),
    sessao: Session = Depends(obter_sessao),
):
    org, _ = _org(sessao, usuario, org_id, papeis=("gestor", "bibliotecario"))
    _exigir_plano_escola(sessao, org)
    lista = _lista_da_org(sessao, org, lista_id)
    conteudo = await arquivo.read(2 * 1024 * 1024 + 1)
    if len(conteudo) > 2 * 1024 * 1024:
        raise ErroApi(413, "arquivo_grande", "O arquivo passa de 2 MB.")
    try:
        isbns = importacao.ler_csv(conteudo)
    except importacao.CsvInvalido as e:
        raise ErroApi(400, "csv_invalido", str(e)) from e
    tarefa = tarefas.enfileirar_importacao(
        sessao, str(org.id), str(lista.id), isbns, str(usuario.id)
    )
    return {"tarefa_id": str(tarefa.id), "linhas": len(isbns)}


@rotas.get("/{org_id}/importacoes/{tarefa_id}")
def andamento(
    org_id: str,
    tarefa_id: str,
    usuario: Usuario = Depends(usuario_obrigatorio),
    sessao: Session = Depends(obter_sessao),
):
    org, _ = _org(sessao, usuario, org_id)
    try:
        tarefa = sessao.get(Tarefa, uuid.UUID(tarefa_id))
    except ValueError:
        tarefa = None
    if tarefa is None or tarefa.parametros.get("organizacao_id") != str(org.id):
        raise nao_encontrado("Importação")
    sessao.refresh(tarefa)
    return {"estado": tarefa.estado, "resultado": tarefa.resultado, "erro": tarefa.erro}


@rotas.get("/{org_id}/listas/{lista_id}/relatorio")
def relatorio(
    org_id: str,
    lista_id: str,
    formato: str = Query("json", pattern="^(json|csv|pdf)$"),
    usuario: Usuario = Depends(usuario_obrigatorio),
    sessao: Session = Depends(obter_sessao),
):
    org, _ = _org(sessao, usuario, org_id)
    _exigir_plano_escola(sessao, org)
    dados = relatorios.gerar(sessao, _lista_da_org(sessao, org, lista_id))
    if formato == "csv":
        return Response(
            relatorios.para_csv(dados),
            media_type="text/csv; charset=utf-8",
            headers={"Content-Disposition": 'attachment; filename="acervo.csv"'},
        )
    if formato == "pdf":
        return Response(
            relatorios.para_pdf(dados),
            media_type="application/pdf",
            headers={"Content-Disposition": 'attachment; filename="acervo.pdf"'},
        )
    return dados
