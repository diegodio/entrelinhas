"""Listas pessoais. Listas de organização (acervo, turma) usam as mesmas rotas de itens."""

from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.db import obter_sessao
from app.erros import ErroApi, nao_encontrado
from app.modelos import ItemLista, Lista, MembroOrganizacao, PerfilLeitor, Usuario
from app.seguranca import usuario_obrigatorio
from app.servicos import configuracao as cfg_servico
from app.servicos import obras as obras_servico
from app.servicos import planos

rotas = APIRouter(prefix="/v1/listas", tags=["listas"])

LISTAS_PADRAO = ("Quero ler", "Aprovados")
PAPEIS_EDICAO_ORG = ("gestor", "bibliotecario")


def papel_na_org(sessao: Session, usuario: Usuario, organizacao_id) -> str | None:
    return sessao.scalar(
        select(MembroOrganizacao.papel).where(
            MembroOrganizacao.organizacao_id == organizacao_id,
            MembroOrganizacao.usuario_id == usuario.id,
        )
    )


def obter_lista(sessao: Session, usuario: Usuario, lista_id: str, editar: bool = False) -> Lista:
    try:
        lid = uuid.UUID(lista_id)
    except ValueError as e:
        raise nao_encontrado("Lista") from e
    lista = sessao.get(Lista, lid)
    if lista is None:
        raise nao_encontrado("Lista")
    if lista.usuario_id is not None:
        if lista.usuario_id != usuario.id:
            raise nao_encontrado("Lista")
        return lista
    papel = papel_na_org(sessao, usuario, lista.organizacao_id)
    if papel is None:
        raise nao_encontrado("Lista")
    if editar and papel not in PAPEIS_EDICAO_ORG and not (lista.tipo == "turma"):
        raise ErroApi(403, "proibido", "Seu papel na instituição não permite editar esta lista.")
    return lista


def resumo_lista(sessao: Session, lista: Lista) -> dict:
    total = sessao.scalar(select(func.count(ItemLista.id)).where(ItemLista.lista_id == lista.id))
    return {
        "id": str(lista.id),
        "nome": lista.nome,
        "tipo": lista.tipo,
        "quantidade": total or 0,
        "idade_referencia": lista.idade_referencia,
        "ano_escolar": lista.ano_escolar,
        "organizacao_id": str(lista.organizacao_id) if lista.organizacao_id else None,
    }


def detalhe_lista(sessao: Session, lista: Lista) -> dict:
    itens = []
    for item in sorted(lista.itens, key=lambda i: i.criado_em, reverse=True):
        obra = obras_servico.obter(sessao, item.obra_id)
        if obra is None:
            continue
        resumo = obras_servico.resumo(obra)
        ficha = obra.ficha
        if ficha is not None and ficha.dados and ficha.status in ("publicada", "em_revisao"):
            resumo["alertas"] = ficha.dados["camada_b"]["flags"]
            resumo["rotulo_nivel_leitura"] = ficha.dados["camada_c"]["rotulo_nivel_leitura"]
        itens.append({"obra": resumo, "perfil_id": str(item.perfil_id) if item.perfil_id else None})
    return {**resumo_lista(sessao, lista), "itens": itens}


@rotas.get("")
def minhas_listas(usuario: Usuario = Depends(usuario_obrigatorio),
                  sessao: Session = Depends(obter_sessao)):
    listas = sessao.scalars(
        select(Lista).where(Lista.usuario_id == usuario.id).order_by(Lista.criado_em)
    ).all()
    if not listas:
        for nome in LISTAS_PADRAO:
            sessao.add(Lista(usuario_id=usuario.id, nome=nome, tipo="pessoal"))
        sessao.commit()
        listas = sessao.scalars(
            select(Lista).where(Lista.usuario_id == usuario.id).order_by(Lista.criado_em)
        ).all()
    return [resumo_lista(sessao, lista) for lista in listas]


class NovaLista(BaseModel):
    nome: str = Field(min_length=1, max_length=120)


@rotas.post("", status_code=201)
def criar(dados: NovaLista, usuario: Usuario = Depends(usuario_obrigatorio),
          sessao: Session = Depends(obter_sessao)):
    if planos.plano_do_usuario(sessao, usuario)["plano"] == "gratuito":
        limite = cfg_servico.carregar(sessao)["limites"]["listas_plano_gratuito"]
        total = sessao.query(Lista).filter_by(usuario_id=usuario.id).count()
        if total >= limite:
            raise ErroApi(402, "plano_necessario",
                          "O plano gratuito tem um número limitado de listas.")
    lista = Lista(usuario_id=usuario.id, nome=dados.nome.strip(), tipo="pessoal")
    sessao.add(lista)
    sessao.commit()
    return resumo_lista(sessao, lista)


@rotas.get("/{lista_id}")
def ver(lista_id: str, usuario: Usuario = Depends(usuario_obrigatorio),
        sessao: Session = Depends(obter_sessao)):
    return detalhe_lista(sessao, obter_lista(sessao, usuario, lista_id))


@rotas.delete("/{lista_id}", status_code=204)
def excluir(lista_id: str, usuario: Usuario = Depends(usuario_obrigatorio),
            sessao: Session = Depends(obter_sessao)):
    lista = obter_lista(sessao, usuario, lista_id, editar=True)
    sessao.delete(lista)
    sessao.commit()


class NovoItem(BaseModel):
    obra_id: str
    perfil_id: str | None = None


@rotas.post("/{lista_id}/itens", status_code=201)
def adicionar(lista_id: str, dados: NovoItem, usuario: Usuario = Depends(usuario_obrigatorio),
              sessao: Session = Depends(obter_sessao)):
    lista = obter_lista(sessao, usuario, lista_id, editar=True)
    obra = obras_servico.obter(sessao, dados.obra_id)
    if obra is None:
        raise nao_encontrado("Obra")
    perfil_id = None
    if dados.perfil_id:
        try:
            perfil = sessao.get(PerfilLeitor, uuid.UUID(dados.perfil_id))
        except ValueError:
            perfil = None
        if perfil is not None and perfil.usuario_id == usuario.id:
            perfil_id = perfil.id
    existente = sessao.scalars(
        select(ItemLista).where(ItemLista.lista_id == lista.id, ItemLista.obra_id == obra.id)
    ).first()
    if existente is None:
        sessao.add(ItemLista(lista_id=lista.id, obra_id=obra.id, perfil_id=perfil_id))
    else:
        existente.perfil_id = perfil_id or existente.perfil_id
    sessao.commit()
    return resumo_lista(sessao, lista)


@rotas.delete("/{lista_id}/itens/{obra_id}", status_code=204)
def remover(lista_id: str, obra_id: str, usuario: Usuario = Depends(usuario_obrigatorio),
            sessao: Session = Depends(obter_sessao)):
    lista = obter_lista(sessao, usuario, lista_id, editar=True)
    try:
        oid = uuid.UUID(obra_id)
    except ValueError as e:
        raise nao_encontrado("Item") from e
    item = sessao.scalars(
        select(ItemLista).where(ItemLista.lista_id == lista.id, ItemLista.obra_id == oid)
    ).first()
    if item is not None:
        sessao.delete(item)
        sessao.commit()
