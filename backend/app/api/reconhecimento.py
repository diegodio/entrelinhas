"""POST /v1/reconhecimento: identifica o livro a partir de uma imagem (seção 4.5)."""

from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, File, Form, UploadFile
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.db import obter_sessao
from app.deps import obter_cascata
from app.erros import ErroApi, nao_encontrado
from app.modelos import AmostraReconhecimento, Usuario
from app.provedores.metadados import Cascata
from app.provedores.modelo_capa import ModeloDeCapa, obter_modelo_capa
from app.provedores.ocr import MotorOcr, obter_ocr
from app.reconhecimento.imagem import carregar
from app.reconhecimento.servico import reconhecer
from app.seguranca import usuario_obrigatorio, usuario_opcional
from app.servicos import armazenamento
from app.servicos import configuracao as cfg_servico
from app.servicos import obras as obras_servico

rotas = APIRouter(prefix="/v1/reconhecimento", tags=["reconhecimento"])

TIPOS_ACEITOS = {"image/jpeg", "image/png", "image/webp"}
TAMANHO_MAXIMO = 8 * 1024 * 1024
DICAS = {"capa", "codigo_de_barras", "desconhecido"}


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
    imagem: UploadFile = File(...),
    dica: str = Form("desconhecido"),
    isbn: str | None = Form(None),
    sessao: Session = Depends(obter_sessao),
    usuario: Usuario | None = Depends(usuario_opcional),
    cascata: Cascata | None = Depends(obter_cascata),
    ocr: MotorOcr = Depends(obter_ocr),
    modelo: ModeloDeCapa = Depends(obter_modelo_capa),
):
    if dica not in DICAS:
        dica = "desconhecido"
    if imagem.content_type not in TIPOS_ACEITOS:
        raise ErroApi(415, "tipo_invalido", "Envie uma foto em JPEG, PNG ou WebP.")
    dados = await imagem.read(TAMANHO_MAXIMO + 1)
    if len(dados) > TAMANHO_MAXIMO:
        raise ErroApi(413, "imagem_grande", "A foto é grande demais. Tente de novo.")
    try:
        img = carregar(dados)
    except Exception as e:
        raise ErroApi(400, "imagem_invalida", "Não conseguimos abrir esta imagem.") from e

    cfg = cfg_servico.carregar(sessao)["limites"]["reconhecimento"]
    r = reconhecer(sessao, img, dica, isbn, ocr, modelo, cascata, cfg)

    resposta = {
        "status": r.status,
        "obra": _obra_json(sessao, r.obra_id) if r.obra_id else None,
        "candidatos": [
            {
                "obra": _obra_json(sessao, c.obra_id),
                "pontuacao": round(c.pontuacao, 3),
                "sinais": c.sinais,
            }
            for c in r.candidatos
        ]
        if r.status == "candidatos"
        else [],
        "sinais": {"isbn": r.isbn, "texto_ocr": r.texto_ocr, "tempo_ms": r.tempo_ms},
        "amostra_id": None,
    }
    # Só com consentimento explícito: imagem e resultado viram amostra de treino.
    if usuario is not None and usuario.contribuir_imagens:
        amostra_id = uuid.uuid4()
        caminho = armazenamento.obter().salvar(
            f"amostras/{usuario.id}/{amostra_id}.jpg", dados, imagem.content_type
        )
        sessao.add(
            AmostraReconhecimento(
                id=amostra_id,
                usuario_id=usuario.id,
                caminho_imagem=caminho,
                resultado={k: resposta[k] for k in ("status", "sinais")}
                | {"obra_id": str(r.obra_id) if r.obra_id else None},
            )
        )
        sessao.commit()
        resposta["amostra_id"] = str(amostra_id)
    return resposta


class Correcao(BaseModel):
    obra_id: str


@rotas.post("/{amostra_id}/correcao", status_code=204)
def corrigir(
    amostra_id: str,
    dados: Correcao,
    sessao: Session = Depends(obter_sessao),
    usuario: Usuario = Depends(usuario_obrigatorio),
):
    """Registra qual era o livro certo ("Não é este" seguido da escolha)."""
    try:
        amostra = sessao.get(AmostraReconhecimento, uuid.UUID(amostra_id))
    except ValueError:
        amostra = None
    if amostra is None or amostra.usuario_id != usuario.id:
        raise nao_encontrado("Amostra")
    obra = obras_servico.obter(sessao, dados.obra_id)
    if obra is None:
        raise nao_encontrado("Obra")
    amostra.obra_corrigida_id = obra.id
    sessao.commit()
