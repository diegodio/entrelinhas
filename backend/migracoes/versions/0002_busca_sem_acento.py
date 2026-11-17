"""Função imutável para comparar títulos sem acento e índices de trigramas sobre ela.

Revision ID: 0002_busca_sem_acento
Revises: 723e2d666fea
"""

from alembic import op

revision = "0002_busca_sem_acento"
down_revision = "723e2d666fea"
branch_labels = None
depends_on = None

_DE = "áàâãäéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ"
_PARA = "aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN"


def upgrade() -> None:
    op.execute(
        "CREATE OR REPLACE FUNCTION unaccent_simples(t text) RETURNS text "
        "LANGUAGE sql IMMUTABLE PARALLEL SAFE AS "
        f"$$ SELECT translate(coalesce(t, ''), '{_DE}', '{_PARA}') $$"
    )
    op.execute(
        "CREATE INDEX ix_obras_titulo_sem_acento_trgm ON obras "
        "USING gin (lower(unaccent_simples(titulo)) gin_trgm_ops)"
    )


def downgrade() -> None:
    op.execute("DROP INDEX IF EXISTS ix_obras_titulo_sem_acento_trgm")
    op.execute("DROP FUNCTION IF EXISTS unaccent_simples(text)")
