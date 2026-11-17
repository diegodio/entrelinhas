"""Modelo de dados (seção 4.2)."""

from __future__ import annotations

import uuid
from datetime import UTC, date, datetime

from pgvector.sqlalchemy import Vector
from sqlalchemy import (
    Boolean,
    DateTime,
    Float,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import ARRAY, JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db import Base


def agora() -> datetime:
    return datetime.now(UTC)


def _id() -> Mapped[uuid.UUID]:
    return mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)


def _criado() -> Mapped[datetime]:
    return mapped_column(DateTime(timezone=True), default=agora, nullable=False)


# --------------------------------------------------------------------- pessoas


class Usuario(Base):
    __tablename__ = "usuarios"
    id: Mapped[uuid.UUID] = _id()
    email: Mapped[str] = mapped_column(String(320), unique=True, index=True)
    hash_senha: Mapped[str | None] = mapped_column(String(255))
    nome: Mapped[str] = mapped_column(String(120), default="")
    provedores_sociais: Mapped[dict] = mapped_column(JSONB, default=dict)  # {"google": sub}
    papel: Mapped[str] = mapped_column(String(20), default="usuario")  # usuario|revisor|admin
    contribuir_imagens: Mapped[bool] = mapped_column(Boolean, default=False)
    criado_em: Mapped[datetime] = _criado()

    perfis: Mapped[list[PerfilLeitor]] = relationship(
        back_populates="usuario", cascade="all, delete-orphan"
    )


class TokenRenovacao(Base):
    __tablename__ = "tokens_renovacao"
    id: Mapped[uuid.UUID] = _id()
    usuario_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("usuarios.id", ondelete="CASCADE"))
    hash_token: Mapped[str] = mapped_column(String(128), unique=True, index=True)
    expira_em: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    revogado: Mapped[bool] = mapped_column(Boolean, default=False)
    criado_em: Mapped[datetime] = _criado()


class TokenRecuperacao(Base):
    __tablename__ = "tokens_recuperacao"
    id: Mapped[uuid.UUID] = _id()
    usuario_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("usuarios.id", ondelete="CASCADE"))
    hash_token: Mapped[str] = mapped_column(String(128), unique=True, index=True)
    expira_em: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    usado: Mapped[bool] = mapped_column(Boolean, default=False)


class Consentimento(Base):
    __tablename__ = "consentimentos"
    id: Mapped[uuid.UUID] = _id()
    usuario_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("usuarios.id", ondelete="CASCADE"))
    documento: Mapped[str] = mapped_column(String(40))  # termos | privacidade | imagens
    versao: Mapped[str] = mapped_column(String(20))
    aceito: Mapped[bool] = mapped_column(Boolean, default=True)
    criado_em: Mapped[datetime] = _criado()


class PerfilLeitor(Base):
    """O "filho" do responsável. Só apelido, ano de nascimento e ícone (seção 4.9)."""

    __tablename__ = "perfis_leitor"
    id: Mapped[uuid.UUID] = _id()
    usuario_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("usuarios.id", ondelete="CASCADE"))
    apelido: Mapped[str] = mapped_column(String(40))
    ano_nascimento: Mapped[int] = mapped_column(Integer)
    icone: Mapped[str] = mapped_column(String(40), default="livro")
    criado_em: Mapped[datetime] = _criado()

    usuario: Mapped[Usuario] = relationship(back_populates="perfis")


class Organizacao(Base):
    __tablename__ = "organizacoes"
    id: Mapped[uuid.UUID] = _id()
    nome: Mapped[str] = mapped_column(String(160))
    tipo: Mapped[str] = mapped_column(String(20), default="escola")  # escola | biblioteca | rede
    criado_em: Mapped[datetime] = _criado()


class MembroOrganizacao(Base):
    __tablename__ = "membros_organizacao"
    __table_args__ = (UniqueConstraint("organizacao_id", "usuario_id"),)
    id: Mapped[uuid.UUID] = _id()
    organizacao_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("organizacoes.id", ondelete="CASCADE")
    )
    usuario_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("usuarios.id", ondelete="CASCADE"))
    papel: Mapped[str] = mapped_column(String(20))  # gestor | bibliotecario | professor
    criado_em: Mapped[datetime] = _criado()


# --------------------------------------------------------------------- acervo


class Obra(Base):
    __tablename__ = "obras"
    __table_args__ = (
        Index(
            "ix_obras_titulo_trgm",
            "titulo",
            postgresql_using="gin",
            postgresql_ops={"titulo": "gin_trgm_ops"},
        ),
        Index(
            "ix_obras_autores_txt_trgm",
            "autores_texto",
            postgresql_using="gin",
            postgresql_ops={"autores_texto": "gin_trgm_ops"},
        ),
    )
    id: Mapped[uuid.UUID] = _id()
    titulo: Mapped[str] = mapped_column(String(400))
    subtitulo: Mapped[str | None] = mapped_column(String(400))
    autores: Mapped[list[str]] = mapped_column(ARRAY(String), default=list)
    autores_texto: Mapped[str] = mapped_column(Text, default="")  # para busca difusa
    sinopse: Mapped[str | None] = mapped_column(Text)
    idioma: Mapped[str | None] = mapped_column(String(10))
    genero: Mapped[str | None] = mapped_column(String(120))
    paginas: Mapped[int | None] = mapped_column(Integer)
    fonte_metadados: Mapped[str] = mapped_column(String(40), default="base_entrelinhas")
    demonstracao: Mapped[bool] = mapped_column(Boolean, default=False)
    criado_em: Mapped[datetime] = _criado()

    edicoes: Mapped[list[Edicao]] = relationship(back_populates="obra", cascade="all")
    ficha: Mapped[Ficha | None] = relationship(back_populates="obra", uselist=False)


class Edicao(Base):
    __tablename__ = "edicoes"
    id: Mapped[uuid.UUID] = _id()
    obra_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("obras.id", ondelete="CASCADE"))
    isbn13: Mapped[str | None] = mapped_column(String(13), unique=True, index=True)
    isbn10: Mapped[str | None] = mapped_column(String(10), index=True)
    editora: Mapped[str | None] = mapped_column(String(200))
    ano: Mapped[int | None] = mapped_column(Integer)
    capa_url: Mapped[str | None] = mapped_column(Text)
    criado_em: Mapped[datetime] = _criado()

    obra: Mapped[Obra] = relationship(back_populates="edicoes")


class Capa(Base):
    """Vetor da capa de uma edição. Vetores de modelos diferentes nunca se comparam."""

    __tablename__ = "capas"
    __table_args__ = (UniqueConstraint("edicao_id", "modelo", "versao_modelo"),)
    id: Mapped[uuid.UUID] = _id()
    edicao_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("edicoes.id", ondelete="CASCADE"))
    url_origem: Mapped[str] = mapped_column(Text)
    # Dimensão livre: a coluna aceita vetores de qualquer modelo; a busca filtra pelo modelo.
    vetor: Mapped[list[float]] = mapped_column(Vector())
    modelo: Mapped[str] = mapped_column(String(120))
    versao_modelo: Mapped[str] = mapped_column(String(40))
    criado_em: Mapped[datetime] = _criado()


class Ficha(Base):
    __tablename__ = "fichas"
    id: Mapped[uuid.UUID] = _id()
    obra_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("obras.id", ondelete="CASCADE"), unique=True
    )
    slug: Mapped[str] = mapped_column(String(160), unique=True, index=True)
    dados: Mapped[dict | None] = mapped_column(JSONB)
    status: Mapped[str] = mapped_column(String(20), index=True)
    faixa_final: Mapped[str | None] = mapped_column(String(10), index=True)
    fonte_da_analise: Mapped[str | None] = mapped_column(String(40))
    confianca: Mapped[float | None] = mapped_column(Float)
    revisada_por_humano: Mapped[bool] = mapped_column(Boolean, default=False, index=True)
    versao_rubrica: Mapped[str] = mapped_column(String(10), default="1.0")
    versao_ficha: Mapped[int] = mapped_column(Integer, default=0)
    erro: Mapped[str | None] = mapped_column(Text)
    atualizada_em: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=agora)

    obra: Mapped[Obra] = relationship(back_populates="ficha")


class FichaVersao(Base):
    """Histórico imutável."""

    __tablename__ = "fichas_versoes"
    id: Mapped[uuid.UUID] = _id()
    ficha_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("fichas.id", ondelete="CASCADE"))
    versao: Mapped[int] = mapped_column(Integer)
    dados: Mapped[dict] = mapped_column(JSONB)
    autor_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("usuarios.id"))
    autor_papel: Mapped[str] = mapped_column(String(20))  # sistema | revisor | admin
    motivo: Mapped[str] = mapped_column(Text)
    criado_em: Mapped[datetime] = _criado()


class FonteFicha(Base):
    __tablename__ = "fontes_da_ficha"
    id: Mapped[uuid.UUID] = _id()
    ficha_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("fichas.id", ondelete="CASCADE"))
    tipo: Mapped[str] = mapped_column(String(40))  # sinopse | resenha | metadado | texto
    url: Mapped[str | None] = mapped_column(Text)
    descricao: Mapped[str | None] = mapped_column(Text)


# ------------------------------------------------------------------ uso


class Consulta(Base):
    __tablename__ = "consultas"
    __table_args__ = (Index("ix_consultas_usuario_data", "usuario_id", "criado_em"),)
    id: Mapped[uuid.UUID] = _id()
    usuario_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("usuarios.id", ondelete="CASCADE"))
    obra_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("obras.id", ondelete="CASCADE"))
    conta_no_limite: Mapped[bool] = mapped_column(Boolean, default=True)
    criado_em: Mapped[datetime] = _criado()


class Lista(Base):
    __tablename__ = "listas"
    id: Mapped[uuid.UUID] = _id()
    usuario_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("usuarios.id", ondelete="CASCADE")
    )
    organizacao_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("organizacoes.id", ondelete="CASCADE")
    )
    nome: Mapped[str] = mapped_column(String(120))
    tipo: Mapped[str] = mapped_column(String(20), default="pessoal")  # pessoal | acervo | turma
    idade_referencia: Mapped[int | None] = mapped_column(Integer)
    ano_escolar: Mapped[str | None] = mapped_column(String(40))
    criado_em: Mapped[datetime] = _criado()

    itens: Mapped[list[ItemLista]] = relationship(
        back_populates="lista", cascade="all, delete-orphan"
    )


class ItemLista(Base):
    __tablename__ = "itens_lista"
    __table_args__ = (UniqueConstraint("lista_id", "obra_id"),)
    id: Mapped[uuid.UUID] = _id()
    lista_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("listas.id", ondelete="CASCADE"))
    obra_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("obras.id", ondelete="CASCADE"))
    perfil_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("perfis_leitor.id", ondelete="SET NULL")
    )
    criado_em: Mapped[datetime] = _criado()

    lista: Mapped[Lista] = relationship(back_populates="itens")


class Contestacao(Base):
    __tablename__ = "contestacoes"
    id: Mapped[uuid.UUID] = _id()
    usuario_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("usuarios.id", ondelete="CASCADE"))
    ficha_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("fichas.id", ondelete="CASCADE"))
    campo: Mapped[str] = mapped_column(String(60))  # A1..A6, camada_b, camada_c, valor_formativo...
    texto: Mapped[str] = mapped_column(Text)
    status: Mapped[str] = mapped_column(String(20), default="aberta")  # aberta|aceita|recusada
    resposta: Mapped[str | None] = mapped_column(Text)
    respondida_em: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    criado_em: Mapped[datetime] = _criado()


class Assinatura(Base):
    __tablename__ = "assinaturas"
    id: Mapped[uuid.UUID] = _id()
    usuario_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("usuarios.id", ondelete="CASCADE")
    )
    organizacao_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("organizacoes.id", ondelete="CASCADE")
    )
    plano: Mapped[str] = mapped_column(String(20))  # familia | escola
    origem: Mapped[str] = mapped_column(String(20))  # app_store | google_play | stripe | falso
    id_externo: Mapped[str | None] = mapped_column(String(200), index=True)
    estado: Mapped[str] = mapped_column(String(20), default="ativa")  # ativa|cancelada|expirada
    valida_ate: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    criado_em: Mapped[datetime] = _criado()


class Tarefa(Base):
    __tablename__ = "tarefas"
    id: Mapped[uuid.UUID] = _id()
    tipo: Mapped[str] = mapped_column(String(40))  # analise | importacao
    estado: Mapped[str] = mapped_column(String(20), default="pendente")  # pendente|rodando|ok|erro
    parametros: Mapped[dict] = mapped_column(JSONB, default=dict)
    resultado: Mapped[dict | None] = mapped_column(JSONB)
    erro: Mapped[str | None] = mapped_column(Text)
    criado_em: Mapped[datetime] = _criado()
    atualizada_em: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=agora)


class AmostraReconhecimento(Base):
    """Só gravada com consentimento explícito do usuário (seção 4.9)."""

    __tablename__ = "amostras_reconhecimento"
    id: Mapped[uuid.UUID] = _id()
    usuario_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("usuarios.id", ondelete="CASCADE"))
    caminho_imagem: Mapped[str] = mapped_column(Text)
    resultado: Mapped[dict] = mapped_column(JSONB)
    obra_corrigida_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("obras.id", ondelete="SET NULL")
    )
    criado_em: Mapped[datetime] = _criado()


class Configuracao(Base):
    __tablename__ = "configuracao"
    chave: Mapped[str] = mapped_column(String(80), primary_key=True)
    valor: Mapped[dict | list | str | int | float | bool] = mapped_column(JSONB)
    descricao: Mapped[str] = mapped_column(Text, default="")


def inicio_do_mes(hoje: date | None = None) -> datetime:
    hoje = hoje or agora().date()
    return datetime(hoje.year, hoje.month, 1, tzinfo=UTC)


__all__ = [
    "AmostraReconhecimento",
    "Assinatura",
    "Capa",
    "Configuracao",
    "Consentimento",
    "Consulta",
    "Contestacao",
    "Edicao",
    "Ficha",
    "FichaVersao",
    "FonteFicha",
    "ItemLista",
    "Lista",
    "MembroOrganizacao",
    "Obra",
    "Organizacao",
    "PerfilLeitor",
    "Tarefa",
    "TokenRecuperacao",
    "TokenRenovacao",
    "Usuario",
    "agora",
    "inicio_do_mes",
]
