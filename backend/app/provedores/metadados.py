"""Fontes de metadados (seção 4.4, passo 1). A rede é injetável: os testes rodam sem internet.

Cascata: base própria (feita pelo serviço de obras) -> Google Books -> Open Library.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from typing import Protocol

import httpx

from app.core import isbn as isbn_util


@dataclass
class MetadadosObra:
    titulo: str
    autores: list[str] = field(default_factory=list)
    subtitulo: str | None = None
    sinopse: str | None = None
    idioma: str | None = None
    genero: str | None = None
    paginas: int | None = None
    editora: str | None = None
    ano: int | None = None
    isbn13: str | None = None
    isbn10: str | None = None
    capa_url: str | None = None
    fonte: str = ""
    url_fonte: str | None = None


class FonteIndisponivel(Exception):
    """Falha de rede ou resposta inesperada de uma fonte externa."""


class FonteDeMetadados(Protocol):
    nome: str

    def por_isbn(self, isbn13: str) -> MetadadosObra | None: ...

    def buscar(self, termo: str, limite: int = 10) -> list[MetadadosObra]: ...


def _ano(texto: str | None) -> int | None:
    m = re.search(r"(1[5-9]\d\d|20\d\d)", texto or "")
    return int(m.group(1)) if m else None


def _https(url: str | None) -> str | None:
    return url.replace("http://", "https://", 1) if url else None


class GoogleBooks:
    nome = "google_books"
    URL = "https://www.googleapis.com/books/v1/volumes"

    def __init__(self, cliente: httpx.Client, chave: str = ""):
        self.cliente = cliente
        self.chave = chave

    def _get(self, params: dict) -> dict:
        if self.chave:
            params["key"] = self.chave
        try:
            r = self.cliente.get(self.URL, params=params, timeout=6)
            r.raise_for_status()
            return r.json()
        except (httpx.HTTPError, ValueError) as e:
            raise FonteIndisponivel(self.nome) from e

    def _converter(self, item: dict) -> MetadadosObra | None:
        v = item.get("volumeInfo") or {}
        if not v.get("title"):
            return None
        ids = {i.get("type"): i.get("identifier") for i in v.get("industryIdentifiers", [])}
        i13 = isbn_util.validar(ids.get("ISBN_13") or ids.get("ISBN_10") or "")
        imagens = v.get("imageLinks") or {}
        return MetadadosObra(
            titulo=v["title"],
            subtitulo=v.get("subtitle"),
            autores=list(v.get("authors") or []),
            sinopse=re.sub(r"<[^>]+>", "", v.get("description") or "") or None,
            idioma=v.get("language"),
            genero=(v.get("categories") or [None])[0],
            paginas=v.get("pageCount") or None,
            editora=v.get("publisher"),
            ano=_ano(v.get("publishedDate")),
            isbn13=i13,
            isbn10=isbn_util.para_10(i13) if i13 else None,
            capa_url=_https(imagens.get("thumbnail") or imagens.get("smallThumbnail")),
            fonte=self.nome,
            url_fonte=v.get("infoLink"),
        )

    def por_isbn(self, isbn13: str) -> MetadadosObra | None:
        dados = self._get({"q": f"isbn:{isbn13}", "maxResults": 1})
        for item in dados.get("items") or []:
            m = self._converter(item)
            if m:
                m.isbn13 = m.isbn13 or isbn13
                return m
        return None

    def buscar(self, termo: str, limite: int = 10) -> list[MetadadosObra]:
        dados = self._get({"q": termo, "maxResults": min(limite, 20), "printType": "books"})
        return [m for m in (self._converter(i) for i in dados.get("items") or []) if m]


class OpenLibrary:
    nome = "open_library"

    def __init__(self, cliente: httpx.Client):
        self.cliente = cliente

    def _get(self, url: str, params: dict | None = None) -> dict:
        try:
            r = self.cliente.get(url, params=params, timeout=6)
            r.raise_for_status()
            return r.json()
        except (httpx.HTTPError, ValueError) as e:
            raise FonteIndisponivel(self.nome) from e

    def por_isbn(self, isbn13: str) -> MetadadosObra | None:
        dados = self._get(
            "https://openlibrary.org/api/books",
            {"bibkeys": f"ISBN:{isbn13}", "format": "json", "jscmd": "data"},
        )
        livro = dados.get(f"ISBN:{isbn13}")
        if not livro or not livro.get("title"):
            return None
        capa = (livro.get("cover") or {}).get("large") or (livro.get("cover") or {}).get("medium")
        sinopse = livro.get("notes") if isinstance(livro.get("notes"), str) else None
        return MetadadosObra(
            titulo=livro["title"],
            subtitulo=livro.get("subtitle"),
            autores=[a.get("name") for a in livro.get("authors", []) if a.get("name")],
            sinopse=sinopse,
            paginas=livro.get("number_of_pages"),
            editora=((livro.get("publishers") or [{}])[0]).get("name"),
            ano=_ano(livro.get("publish_date")),
            isbn13=isbn13,
            isbn10=isbn_util.para_10(isbn13),
            capa_url=_https(capa),
            fonte=self.nome,
            url_fonte=livro.get("url"),
        )

    def buscar(self, termo: str, limite: int = 10) -> list[MetadadosObra]:
        dados = self._get(
            "https://openlibrary.org/search.json",
            {
                "q": termo,
                "limit": min(limite, 20),
                "fields": "title,author_name,isbn,number_of_pages_median,cover_i,first_publish_year,"
                "publisher,language,subtitle,key",
            },
        )
        resultado = []
        for d in dados.get("docs") or []:
            i13 = next(
                (isbn_util.validar(i) for i in d.get("isbn") or [] if isbn_util.validar(i)), None
            )
            resultado.append(
                MetadadosObra(
                    titulo=d.get("title") or "",
                    subtitulo=d.get("subtitle"),
                    autores=list(d.get("author_name") or []),
                    paginas=d.get("number_of_pages_median"),
                    editora=(d.get("publisher") or [None])[0],
                    ano=d.get("first_publish_year"),
                    isbn13=i13,
                    isbn10=isbn_util.para_10(i13) if i13 else None,
                    capa_url=(
                        f"https://covers.openlibrary.org/b/id/{d['cover_i']}-L.jpg"
                        if d.get("cover_i")
                        else None
                    ),
                    fonte=self.nome,
                    url_fonte=f"https://openlibrary.org{d['key']}" if d.get("key") else None,
                )
            )
        return [m for m in resultado if m.titulo]


class Cascata:
    """Consulta as fontes em ordem. Registra quais falharam por rede."""

    def __init__(self, fontes: list[FonteDeMetadados]):
        self.fontes = fontes
        self.falhas: list[str] = []

    def por_isbn(self, isbn13: str) -> MetadadosObra | None:
        self.falhas = []
        melhor: MetadadosObra | None = None
        for fonte in self.fontes:
            try:
                achado = fonte.por_isbn(isbn13)
            except FonteIndisponivel:
                self.falhas.append(fonte.nome)
                continue
            if achado is None:
                continue
            if melhor is None:
                melhor = achado
            else:  # completa campos que a primeira fonte não trouxe
                for campo in ("sinopse", "paginas", "capa_url", "editora", "ano", "genero"):
                    if getattr(melhor, campo) in (None, "") and getattr(achado, campo):
                        setattr(melhor, campo, getattr(achado, campo))
            if melhor.sinopse and melhor.paginas and melhor.capa_url:
                break
        return melhor

    def buscar(self, termo: str, limite: int = 10) -> list[MetadadosObra]:
        self.falhas = []
        resultados: list[MetadadosObra] = []
        vistos: set[str] = set()
        for fonte in self.fontes:
            try:
                achados = fonte.buscar(termo, limite)
            except FonteIndisponivel:
                self.falhas.append(fonte.nome)
                continue
            for m in achados:
                chave = m.isbn13 or f"{m.titulo.lower()}|{','.join(m.autores).lower()}"
                if chave not in vistos:
                    vistos.add(chave)
                    resultados.append(m)
            if len(resultados) >= limite:
                break
        return resultados[:limite]


def cascata_padrao(
    nomes: str, cliente: httpx.Client | None = None, chave_google: str = ""
) -> Cascata:
    cliente = cliente or httpx.Client(headers={"User-Agent": "Entrelinhas/0.1"})
    fontes: list[FonteDeMetadados] = []
    for nome in [n.strip() for n in nomes.split(",") if n.strip()]:
        if nome == "google_books":
            fontes.append(GoogleBooks(cliente, chave_google))
        elif nome == "open_library":
            fontes.append(OpenLibrary(cliente))
    return Cascata(fontes)
