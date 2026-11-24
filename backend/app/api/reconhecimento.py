"""POST /v1/reconhecimento: identifica o livro pelo código de barras de uma foto.

Usado quando o aparelho não leu o código ao vivo (web, galeria ou captura manual). No
celular, o ML Kit costuma ler o ISBN e o app consulta direto GET /v1/obras/isbn/{isbn}.
A foto não é guardada.
"""

from __future__ import annotations

from fastapi import APIRouter, Depends, File, Form, UploadFile
from sqlalchemy.orm import Session

from app.db import obter_sessao
from app.deps import obter_cascata
from app.erros import ErroApi
from app.provedores.metadados import Cascata
from app.reconhecimento.imagem import carregar
from app.reconhecimento.servico import reconhecer
from app.servicos import obras as obras_servico

rotas = APIRouter(prefix="/v1/reconhecimento", tags=["reconhecimento"])

TIPOS_ACEITOS = {"image/jpeg", "image/png", "image/webp"}
TAMANHO_MAXIMO = 8 * 1024 * 1024


def _obra_json(sessao: Session, obra_id) -> dict | None:
    obra = obras_servico.obter(sessao, obra_id)
    if obra is None:
        return None
    r = obras_servico.resumo(obra)
    return {
        k: r[k] for k in ("id", "titulo", "autores", "capa_url", "faixa_final", "demonstracao")
    } | {"status_ficha": r["status_ficha"]}


@rotas.post("")
async def reconhecer_imagem(
    imagem: UploadFile | None = File(None),
    isbn: str | None = Form(None),
    sessao: Session = Depends(obter_sessao),
    cascata: Cascata | None = Depends(obter_cascata),
):
    img = None
    if imagem is not None:
        if imagem.content_type not in TIPOS_ACEITOS:
            raise ErroApi(415, "tipo_invalido", "Envie uma foto em JPEG, PNG ou WebP.")
        dados = await imagem.read(TAMANHO_MAXIMO + 1)
        if len(dados) > TAMANHO_MAXIMO:
            raise ErroApi(413, "imagem_grande", "A foto é grande demais. Tente de novo.")
        try:
            img = carregar(dados)
        except Exception as e:
            raise ErroApi(400, "imagem_invalida", "Não conseguimos abrir esta imagem.") from e
    elif not isbn:
        raise ErroApi(400, "sem_imagem", "Envie a foto do código de barras.")

    r = reconhecer(sessao, img, isbn, cascata)
    return {
        "status": r.status,
        "obra": _obra_json(sessao, r.obra_id) if r.obra_id else None,
        "isbn": r.isbn,
        "tempo_ms": r.tempo_ms,
    }
