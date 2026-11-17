"""Busca, cadastro e serialização de obras."""

from __future__ import annotations

import re
import unicodedata
import uuid

from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session, selectinload

from app.config import configuracoes
from app.core import isbn as isbn_util
from app.erros import ErroApi
from app.modelos import Edicao, Ficha, Obra
from app.provedores.metadados import Cascata, MetadadosObra

TAMANHO_MINIMO_BUSCA = 3


def slugificar(texto: str) -> str:
    base = unicodedata.normalize("NFKD", texto).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "-", base.lower()).strip("-")[:100] or "obra"


def status_ficha(obra: Obra) -> str:
    if obra.ficha is None:
        return "sem_ficha"
    return obra.ficha.status


def url_absoluta(url: str | None) -> str | None:
    """Capas servidas pelo próprio backend são guardadas com caminho relativo."""
    if url and url.startswith("/"):
        return configuracoes().url_publica_api.rstrip("/") + url
    return url


def capa_principal(obra: Obra) -> str | None:
    for e in obra.edicoes:
        if e.capa_url:
            return url_absoluta(e.capa_url)
    return None


def resumo(obra: Obra, origem: str | None = None) -> dict:
    ficha = obra.ficha
    visivel = ficha is not None and ficha.status in ("publicada", "em_revisao")
    edicao = next((e for e in obra.edicoes if e.isbn13), None)
    return {
        "id": str(obra.id),
        "titulo": obra.titulo,
        "subtitulo": obra.subtitulo,
        "autores": obra.autores,
        "capa_url": capa_principal(obra),
        "isbn13": edicao.isbn13 if edicao else None,
        "faixa_final": ficha.faixa_final if visivel else None,
        "status_ficha": status_ficha(obra),
        "origem": origem or obra.fonte_metadados,
        "demonstracao": obra.demonstracao,
    }


def detalhe(obra: Obra) -> dict:
    return {
        **resumo(obra),
        "sinopse": obra.sinopse,
        "genero": obra.genero,
        "paginas": obra.paginas,
        "idioma": obra.idioma,
        "edicoes": [
            {
                "id": str(e.id),
                "isbn13": e.isbn13,
                "isbn10": e.isbn10,
                "editora": e.editora,
                "ano": e.ano,
                "capa_url": url_absoluta(e.capa_url),
            }
            for e in obra.edicoes
        ],
    }


def _consulta_obras(sessao: Session):
    return select(Obra).options(selectinload(Obra.edicoes), selectinload(Obra.ficha))


def obter(sessao: Session, obra_id: uuid.UUID | str) -> Obra | None:
    try:
        oid = uuid.UUID(str(obra_id))
    except ValueError:
        return None
    return sessao.scalars(_consulta_obras(sessao).where(Obra.id == oid)).first()


def por_isbn_local(sessao: Session, isbn13: str) -> Obra | None:
    return sessao.scalars(
        _consulta_obras(sessao).join(Edicao).where(Edicao.isbn13 == isbn13)
    ).first()


def criar_de_metadados(sessao: Session, m: MetadadosObra) -> Obra:
    """Cria obra e edição. Se o ISBN já existe, devolve a obra existente."""
    if m.isbn13:
        existente = por_isbn_local(sessao, m.isbn13)
        if existente:
            return existente
    obra = Obra(
        titulo=m.titulo.strip()[:400],
        subtitulo=m.subtitulo,
        autores=m.autores,
        autores_texto=", ".join(m.autores),
        sinopse=m.sinopse,
        idioma=m.idioma,
        genero=m.genero,
        paginas=m.paginas if m.paginas and m.paginas > 0 else None,
        fonte_metadados=m.fonte or "base_entrelinhas",
    )
    obra.edicoes.append(
        Edicao(
            isbn13=m.isbn13,
            isbn10=m.isbn10 or (isbn_util.para_10(m.isbn13) if m.isbn13 else None),
            editora=m.editora,
            ano=m.ano,
            capa_url=m.capa_url,
        )
    )
    sessao.add(obra)
    sessao.commit()
    return obter(sessao, obra.id)


def buscar_por_isbn(
    sessao: Session, texto: str, cascata: Cascata | None
) -> tuple[Obra | None, bool]:
    """Devolve (obra ou None, fontes_externas_indisponiveis)."""
    isbn13 = isbn_util.validar(texto)
    if not isbn13:
        raise ErroApi(400, "isbn_invalido", "Este número não é um ISBN válido. Confira os dígitos.")
    local = por_isbn_local(sessao, isbn13)
    if local or cascata is None:
        return local, False
    achado = cascata.por_isbn(isbn13)
    indisponivel = bool(cascata.falhas) and achado is None
    if achado is None:
        return None, indisponivel
    achado.isbn13 = isbn13
    return criar_de_metadados(sessao, achado), False


def buscar(sessao: Session, termo: str, cascata: Cascata | None, limite: int = 20) -> dict:
    termo = (termo or "").strip()
    if isbn_util.parece_isbn(termo):
        obra, indisponivel = buscar_por_isbn(sessao, termo, cascata)
        return {
            "resultados": [resumo(obra)] if obra else [],
            "isbn": isbn_util.validar(termo),
            "fontes_externas_indisponiveis": indisponivel,
        }
    if len(termo) < TAMANHO_MINIMO_BUSCA:
        raise ErroApi(400, "busca_curta", "Digite ao menos 3 letras para buscar.")

    similaridade = func.greatest(
        func.similarity(Obra.titulo, termo), func.similarity(Obra.autores_texto, termo)
    )
    padrao = f"%{termo}%"
    locais = list(
        sessao.scalars(
            _consulta_obras(sessao)
            .where(
                or_(
                    Obra.titulo.op("%")(termo),
                    Obra.autores_texto.op("%")(termo),
                    Obra.titulo.ilike(padrao),
                    Obra.autores_texto.ilike(padrao),
                )
            )
            .order_by(similaridade.desc())
            .limit(limite)
        )
    )
    resultados = [resumo(o, "base_entrelinhas") for o in locais]
    indisponivel = False
    if cascata is not None and len(locais) < 5:
        externos = cascata.buscar(termo, limite=10)
        indisponivel = bool(cascata.falhas) and not externos
        ids = {r["id"] for r in resultados}
        for m in externos:
            if not m.isbn13:  # só entram no catálogo edições identificáveis
                continue
            obra = criar_de_metadados(sessao, m)
            if str(obra.id) not in ids:
                ids.add(str(obra.id))
                resultados.append(resumo(obra, m.fonte))
    return {
        "resultados": resultados[:limite],
        "isbn": None,
        "fontes_externas_indisponiveis": indisponivel,
    }


def ficha_da_obra(sessao: Session, obra_id) -> Ficha | None:
    return sessao.scalars(select(Ficha).where(Ficha.obra_id == obra_id)).first()
