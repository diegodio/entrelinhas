from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.core import isbn as isbn_util
from app.db import obter_sessao
from app.deps import obter_cascata
from app.erros import ErroApi, nao_encontrado
from app.modelos import Usuario
from app.provedores.metadados import Cascata, MetadadosObra
from app.seguranca import usuario_obrigatorio, usuario_opcional
from app.servicos import configuracao as cfg_servico
from app.servicos import fichas as fichas_servico
from app.servicos import obras as obras_servico
from app.servicos import planos

rotas = APIRouter(prefix="/v1/obras", tags=["obras"])


@rotas.get("")
def buscar(
    busca: str = Query(..., description="Título, autor ou ISBN"),
    sessao: Session = Depends(obter_sessao),
    cascata: Cascata | None = Depends(obter_cascata),
):
    return obras_servico.buscar(sessao, busca, cascata)


@rotas.get("/isbn/{isbn}")
def por_isbn(
    isbn: str,
    sessao: Session = Depends(obter_sessao),
    cascata: Cascata | None = Depends(obter_cascata),
):
    obra, indisponivel = obras_servico.buscar_por_isbn(sessao, isbn, cascata)
    if obra is None:
        raise ErroApi(
            404,
            "obra_nao_encontrada",
            "ISBN válido, mas nenhuma fonte reconheceu a obra. Você pode cadastrá-la manualmente.",
            {"isbn": isbn_util.validar(isbn), "fontes_externas_indisponiveis": indisponivel},
        )
    return obras_servico.detalhe(obra)


@rotas.get("/{obra_id}")
def obter(obra_id: str, sessao: Session = Depends(obter_sessao)):
    obra = obras_servico.obter(sessao, obra_id)
    if obra is None:
        raise nao_encontrado("Obra")
    return obras_servico.detalhe(obra)


class NovaObra(BaseModel):
    isbn: str
    titulo: str = Field(min_length=1, max_length=400)
    autores: list[str] = Field(default_factory=list, max_length=10)
    editora: str | None = None
    ano: int | None = Field(default=None, ge=1400, le=2100)
    paginas: int | None = Field(default=None, ge=1, le=20000)


@rotas.post("", status_code=201)
def cadastrar(
    dados: NovaObra,
    sessao: Session = Depends(obter_sessao),
    _: Usuario = Depends(usuario_obrigatorio),
):
    """Cadastro manual quando nenhuma fonte reconhece o ISBN."""
    i13 = isbn_util.validar(dados.isbn)
    if not i13:
        raise ErroApi(400, "isbn_invalido", "Este número não é um ISBN válido. Confira os dígitos.")
    if obras_servico.por_isbn_local(sessao, i13):
        raise ErroApi(409, "obra_existente", "Já existe uma obra com este ISBN.")
    obra = obras_servico.criar_de_metadados(
        sessao,
        MetadadosObra(
            titulo=dados.titulo,
            autores=[a.strip() for a in dados.autores if a.strip()],
            editora=dados.editora,
            ano=dados.ano,
            paginas=dados.paginas,
            isbn13=i13,
            isbn10=isbn_util.para_10(i13),
            fonte="cadastro_manual",
        ),
    )
    return obras_servico.detalhe(obra)


# ------------------------------------------------------------------ fichas


@rotas.get("/{obra_id}/ficha/resumo")
def resumo_ficha(obra_id: str, sessao: Session = Depends(obter_sessao)):
    """Selo, faixa, recomendação e procedência. Público e não conta consulta."""
    obra = obras_servico.obter(sessao, obra_id)
    if obra is None:
        raise nao_encontrado("Obra")
    ficha = obra.ficha
    if ficha is None or ficha.status not in fichas_servico.STATUS_VISIVEIS:
        return {"status_ficha": obras_servico.status_ficha(obra), "resumo": None}
    return {"status_ficha": ficha.status, "resumo": fichas_servico.resumo_publico(ficha)}


@rotas.get("/{obra_id}/ficha")
def ficha_completa(
    obra_id: str,
    sessao: Session = Depends(obter_sessao),
    usuario: Usuario | None = Depends(usuario_opcional),
):
    """Ficha completa. Exige conta e conta consulta no plano gratuito."""
    obra = obras_servico.obter(sessao, obra_id)
    if obra is None:
        raise nao_encontrado("Obra")
    ficha = obra.ficha
    if ficha is None or ficha.status not in fichas_servico.STATUS_VISIVEIS:
        return {"status_ficha": obras_servico.status_ficha(obra), "ficha": None, "uso": None}
    if usuario is None:
        raise ErroApi(
            401,
            "nao_autenticado",
            "Entre na sua conta para ver a ficha completa.",
            {"resumo": fichas_servico.resumo_publico(ficha)},
        )
    try:
        planos.registrar_consulta(sessao, usuario, obra.id)
    except planos.LimiteAtingido as e:
        raise ErroApi(
            402,
            "limite_atingido",
            "Você usou as fichas gratuitas deste mês.",
            {"resumo": fichas_servico.resumo_publico(ficha), "uso": planos.uso(sessao, usuario)},
        ) from e
    config = cfg_servico.carregar(sessao)
    return {
        "status_ficha": ficha.status,
        "ficha": {**fichas_servico.filtrar_para_exibicao(ficha.dados, config), "slug": ficha.slug},
        "uso": planos.uso(sessao, usuario),
    }


@rotas.get("/{obra_id}/ficha/pdf")
def ficha_pdf(
    obra_id: str,
    sessao: Session = Depends(obter_sessao),
    usuario: Usuario = Depends(usuario_obrigatorio),
):
    """Exportação em PDF: planos Família e Escola."""
    config = cfg_servico.carregar(sessao)
    if not cfg_servico.pode_exibir(config, "exportar_pdf"):
        raise ErroApi(404, "indisponivel", "A exportação está desligada.")
    if planos.plano_do_usuario(sessao, usuario)["plano"] == "gratuito":
        raise ErroApi(402, "plano_necessario", "A exportação em PDF faz parte dos planos pagos.")
    obra = obras_servico.obter(sessao, obra_id)
    if (
        obra is None
        or obra.ficha is None
        or obra.ficha.status not in fichas_servico.STATUS_VISIVEIS
    ):
        raise nao_encontrado("Ficha")
    planos.registrar_consulta(sessao, usuario, obra.id)
    from fastapi.responses import Response

    from app.servicos.pdf import gerar_pdf_ficha

    conteudo = gerar_pdf_ficha(
        obras_servico.resumo(obra),
        fichas_servico.filtrar_para_exibicao(obra.ficha.dados, config),
        config,
    )
    return Response(
        conteudo,
        media_type="application/pdf",
        headers={
            "Content-Disposition": f'attachment; filename="entrelinhas-{obra.ficha.slug}.pdf"'
        },
    )


CAMPOS_CONTESTAVEIS = (
    "A1",
    "A2",
    "A3",
    "A4",
    "A5",
    "A6",
    "camada_b",
    "camada_c",
    "valor_formativo",
    "outro",
)


class NovaContestacao(BaseModel):
    campo: str
    texto: str = Field(min_length=10, max_length=4000)


@rotas.post("/{obra_id}/contestacoes", status_code=201)
def contestar(
    obra_id: str,
    dados: NovaContestacao,
    sessao: Session = Depends(obter_sessao),
    usuario: Usuario = Depends(usuario_obrigatorio),
):
    """A ficha contestada exibe "Ficha em revisão após contestação" até a resposta."""
    from app.modelos import Contestacao

    if dados.campo not in CAMPOS_CONTESTAVEIS:
        raise ErroApi(400, "campo_invalido", "Escolha o que você quer contestar.")
    obra = obras_servico.obter(sessao, obra_id)
    if (
        obra is None
        or obra.ficha is None
        or obra.ficha.status not in fichas_servico.STATUS_VISIVEIS
    ):
        raise nao_encontrado("Ficha")
    ficha = obra.ficha
    c = Contestacao(
        usuario_id=usuario.id, ficha_id=ficha.id, campo=dados.campo, texto=dados.texto.strip()
    )
    sessao.add(c)
    ficha.status = "em_revisao"
    ficha.dados = {**ficha.dados, "status": "em_revisao"}
    sessao.commit()
    return {"id": str(c.id), "status": c.status}


@rotas.post("/{obra_id}/analise", status_code=202)
def pedir_analise(
    obra_id: str,
    sessao: Session = Depends(obter_sessao),
    _: Usuario = Depends(usuario_obrigatorio),
):
    """ "Pedir análise": enfileira o pipeline. A obra fica em análise até a tarefa terminar."""
    from app import tarefas

    obra = obras_servico.obter(sessao, obra_id)
    if obra is None:
        raise nao_encontrado("Obra")
    if obra.ficha is not None and obra.ficha.status in fichas_servico.STATUS_VISIVEIS:
        raise ErroApi(409, "ficha_existente", "Esta obra já tem ficha.")
    if obra.ficha is not None and obra.ficha.status == "em_analise":
        return {"status_ficha": "em_analise"}
    tarefa = tarefas.enfileirar_analise(sessao, obra)
    ficha = obras_servico.ficha_da_obra(sessao, obra.id)
    sessao.refresh(ficha)  # a tarefa pode ter rodado em outra sessão
    return {"status_ficha": ficha.status, "tarefa_id": str(tarefa.id)}
