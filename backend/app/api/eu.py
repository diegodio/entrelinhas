"""Conta da pessoa: dados, privacidade (LGPD), leitores e histórico."""

from __future__ import annotations

import uuid
from datetime import UTC, datetime

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy import delete, select
from sqlalchemy.orm import Session

from app.api.auth import VERSAO_TERMOS
from app.db import obter_sessao
from app.erros import ErroApi, nao_encontrado
from app.modelos import (
    AmostraReconhecimento,
    Consentimento,
    Consulta,
    Contestacao,
    Lista,
    MembroOrganizacao,
    Obra,
    Organizacao,
    PerfilLeitor,
    Usuario,
)
from app.seguranca import usuario_obrigatorio
from app.servicos import armazenamento, planos

rotas = APIRouter(prefix="/v1", tags=["conta"])


def organizacoes_do_usuario(sessao: Session, usuario: Usuario) -> list[dict]:
    linhas = sessao.execute(
        select(MembroOrganizacao, Organizacao)
        .join(Organizacao, Organizacao.id == MembroOrganizacao.organizacao_id)
        .where(MembroOrganizacao.usuario_id == usuario.id)
    ).all()
    return [
        {"organizacao_id": str(o.id), "nome": o.nome, "papel": m.papel} for m, o in linhas
    ]


def usuario_json(sessao: Session, usuario: Usuario) -> dict:
    return {
        "id": str(usuario.id),
        "email": usuario.email,
        "nome": usuario.nome,
        "papel": usuario.papel,
        "contribuir_imagens": usuario.contribuir_imagens,
        "organizacoes": organizacoes_do_usuario(sessao, usuario),
        "uso": planos.uso(sessao, usuario),
    }


@rotas.get("/eu")
def eu(usuario: Usuario = Depends(usuario_obrigatorio), sessao: Session = Depends(obter_sessao)):
    return usuario_json(sessao, usuario)


class AtualizacaoConta(BaseModel):
    nome: str | None = Field(default=None, max_length=120)
    contribuir_imagens: bool | None = None


@rotas.patch("/eu")
def atualizar(
    dados: AtualizacaoConta,
    usuario: Usuario = Depends(usuario_obrigatorio),
    sessao: Session = Depends(obter_sessao),
):
    if dados.nome is not None:
        usuario.nome = dados.nome.strip()
    if dados.contribuir_imagens is not None and dados.contribuir_imagens != usuario.contribuir_imagens:
        usuario.contribuir_imagens = dados.contribuir_imagens
        # Cada mudança do consentimento fica registrada, com data e versão do texto.
        sessao.add(Consentimento(usuario_id=usuario.id, documento="imagens",
                                 versao=VERSAO_TERMOS, aceito=dados.contribuir_imagens))
    sessao.commit()
    return usuario_json(sessao, usuario)


@rotas.delete("/eu", status_code=204)
def excluir_conta(usuario: Usuario = Depends(usuario_obrigatorio),
                  sessao: Session = Depends(obter_sessao)):
    """Apaga perfis, listas, histórico, contestações e amostras (com os arquivos de imagem)."""
    for amostra in sessao.scalars(
        select(AmostraReconhecimento).where(AmostraReconhecimento.usuario_id == usuario.id)
    ):
        armazenamento.obter().apagar(amostra.caminho_imagem)
    sessao.execute(delete(Usuario).where(Usuario.id == usuario.id))
    sessao.commit()


@rotas.get("/eu/exportacao")
def exportar(usuario: Usuario = Depends(usuario_obrigatorio),
             sessao: Session = Depends(obter_sessao)):
    def _data(d):
        return d.isoformat() if d else None

    listas = sessao.scalars(select(Lista).where(Lista.usuario_id == usuario.id)).all()
    return {
        "gerado_em": datetime.now(UTC).isoformat(),
        "conta": {"email": usuario.email, "nome": usuario.nome, "criado_em": _data(usuario.criado_em),
                  "contribuir_imagens": usuario.contribuir_imagens},
        "consentimentos": [
            {"documento": c.documento, "versao": c.versao, "aceito": c.aceito,
             "em": _data(c.criado_em)}
            for c in sessao.scalars(select(Consentimento).where(Consentimento.usuario_id == usuario.id))
        ],
        "leitores": [
            {"apelido": p.apelido, "ano_nascimento": p.ano_nascimento, "icone": p.icone}
            for p in sessao.scalars(select(PerfilLeitor).where(PerfilLeitor.usuario_id == usuario.id))
        ],
        "listas": [
            {"nome": lista.nome, "obras": [
                sessao.get(Obra, i.obra_id).titulo for i in lista.itens
            ]}
            for lista in listas
        ],
        "consultas": [
            {"obra": sessao.get(Obra, c.obra_id).titulo, "em": _data(c.criado_em)}
            for c in sessao.scalars(select(Consulta).where(Consulta.usuario_id == usuario.id))
        ],
        "contestacoes": [
            {"campo": c.campo, "texto": c.texto, "status": c.status, "em": _data(c.criado_em)}
            for c in sessao.scalars(select(Contestacao).where(Contestacao.usuario_id == usuario.id))
        ],
        "amostras_reconhecimento": sessao.query(AmostraReconhecimento)
        .filter_by(usuario_id=usuario.id)
        .count(),
    }


# ---------------------------------------------------------------- leitores

class DadosLeitor(BaseModel):
    apelido: str = Field(min_length=1, max_length=40)
    ano_nascimento: int = Field(ge=1900, le=2100)
    icone: str = Field(default="livro", max_length=40)


def leitor_json(p: PerfilLeitor) -> dict:
    return {"id": str(p.id), "apelido": p.apelido, "ano_nascimento": p.ano_nascimento,
            "icone": p.icone}


def _leitor(sessao: Session, usuario: Usuario, perfil_id: str) -> PerfilLeitor:
    try:
        pid = uuid.UUID(perfil_id)
    except ValueError as e:
        raise nao_encontrado("Leitor") from e
    p = sessao.get(PerfilLeitor, pid)
    if p is None or p.usuario_id != usuario.id:
        raise nao_encontrado("Leitor")
    return p


@rotas.get("/perfis")
def listar_leitores(usuario: Usuario = Depends(usuario_obrigatorio),
                    sessao: Session = Depends(obter_sessao)):
    return [leitor_json(p) for p in sessao.scalars(
        select(PerfilLeitor).where(PerfilLeitor.usuario_id == usuario.id)
        .order_by(PerfilLeitor.criado_em))]


@rotas.post("/perfis", status_code=201)
def criar_leitor(dados: DadosLeitor, usuario: Usuario = Depends(usuario_obrigatorio),
                 sessao: Session = Depends(obter_sessao)):
    limite = planos.limite_de_perfis(sessao, usuario)
    total = sessao.query(PerfilLeitor).filter_by(usuario_id=usuario.id).count()
    if limite is not None and total >= limite:
        raise ErroApi(402, "plano_necessario",
                      "O plano gratuito permite um leitor. Conheça os planos para adicionar mais.")
    if dados.ano_nascimento > datetime.now(UTC).year:
        raise ErroApi(400, "ano_invalido", "Confira o ano de nascimento.")
    p = PerfilLeitor(usuario_id=usuario.id, apelido=dados.apelido.strip(),
                     ano_nascimento=dados.ano_nascimento, icone=dados.icone)
    sessao.add(p)
    sessao.commit()
    return leitor_json(p)


@rotas.put("/perfis/{perfil_id}")
def editar_leitor(perfil_id: str, dados: DadosLeitor,
                  usuario: Usuario = Depends(usuario_obrigatorio),
                  sessao: Session = Depends(obter_sessao)):
    p = _leitor(sessao, usuario, perfil_id)
    p.apelido, p.ano_nascimento, p.icone = dados.apelido.strip(), dados.ano_nascimento, dados.icone
    sessao.commit()
    return leitor_json(p)


@rotas.delete("/perfis/{perfil_id}", status_code=204)
def excluir_leitor(perfil_id: str, usuario: Usuario = Depends(usuario_obrigatorio),
                   sessao: Session = Depends(obter_sessao)):
    p = _leitor(sessao, usuario, perfil_id)
    # Itens de lista ligados ao leitor continuam na lista, sem leitor (FK com SET NULL).
    sessao.delete(p)
    sessao.commit()


@rotas.get("/eu/contestacoes")
def minhas_contestacoes(usuario: Usuario = Depends(usuario_obrigatorio),
                        sessao: Session = Depends(obter_sessao)):
    from app.modelos import Ficha

    resultado = []
    for c in sessao.scalars(select(Contestacao).where(Contestacao.usuario_id == usuario.id)
                            .order_by(Contestacao.criado_em.desc())):
        ficha = sessao.get(Ficha, c.ficha_id)
        obra = sessao.get(Obra, ficha.obra_id)
        resultado.append({"id": str(c.id), "obra_id": str(obra.id), "titulo": obra.titulo,
                          "campo": c.campo, "texto": c.texto, "status": c.status,
                          "resposta": c.resposta,
                          "criado_em": c.criado_em.isoformat()})
    return resultado
