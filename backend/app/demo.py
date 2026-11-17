"""Dados de demonstração (seção 9).

Obras FICTÍCIAS, com títulos e autores inventados, marcadas como demonstração no banco
e na interface. Existem para que o app possa ser navegado sem chave de LLM. Nenhuma
ficha de livro real é escrita à mão: fichas reais só nascem do pipeline da seção 4.4.

As edições não têm ISBN de propósito: qualquer número inventado poderia coincidir com
o de um livro real e esconder a obra verdadeira numa consulta por código de barras.

Uso:  python -m app.demo
"""

from __future__ import annotations

import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.config import configuracoes
from app.core.ficha import montar_ficha
from app.db import fabrica_sessao
from app.modelos import Contestacao, Edicao, Ficha, Obra, Usuario
from app.motor.validador import validar_saida_modelo
from app.seguranca import hash_senha
from app.servicos import configuracao as cfg_servico
from app.servicos import fichas as fichas_servico

PASTA_CAPAS = Path(__file__).parent / "estatico" / "capas"


def _eixos(**niveis_e_justificativas) -> dict:
    camada = {}
    for e in ("A1", "A2", "A3", "A4", "A5", "A6"):
        valor = niveis_e_justificativas.get(e, (0, ""))
        camada[e] = {"nivel": valor[0], "justificativa": valor[1]}
    return camada


def _ev(eixo: str, parafrase: str, fonte: str = "sinopse da editora", trecho: str | None = None):
    return {
        "eixo": eixo,
        "parafrase": parafrase,
        "trecho_literal": trecho,
        "fonte": fonte,
        "por_que_selecionado": "",
    }


def _c(voc, est, dens, repertorio, vf_nivel, marcadores, vf_just):
    return {
        "vocabulario": voc,
        "estrutura_narrativa": est,
        "densidade_tematica": dens,
        "exigencia_repertorio": repertorio,
        "valor_formativo": {"nivel": vf_nivel, "marcadores": marcadores, "justificativa": vf_just},
    }


OBRAS = [
    {
        "titulo": "A Ilha dos Relógios",
        "autores": ["Tomás Queiroz"],
        "genero": "Aventura",
        "paginas": 96,
        "cor": (63, 107, 122),
        "revisada": True,
        "sinopse": "Numa ilha onde cada casa guarda um relógio diferente, Nina descobre que o "
        "tempo parou na torre central e reúne os vizinhos para consertá-lo.",
        "fonte": "fontes_publicas",
        "confianca": 0.58,
        "saida": {
            "camada_a": _eixos(),
            "evidencias": [],
            "camada_b": {"flags": [], "justificativas": {}},
            "camada_c": _c(
                1,
                1,
                2,
                [],
                "Alto",
                ["empatia", "qualidade_estetica"],
                "Celebra a cooperação entre vizinhos e a curiosidade.",
            ),
        },
    },
    {
        "titulo": "O Clube das Lanternas",
        "autores": ["Beatriz Monteiro"],
        "genero": "Infantojuvenil",
        "paginas": 180,
        "cor": (143, 100, 16),
        "sinopse": "Quatro amigos criam um clube secreto para investigar luzes misteriosas no "
        "bairro, enquanto um deles enfrenta provocações na escola.",
        "fonte": "fontes_publicas",
        "confianca": 0.55,
        "saida": {
            "camada_a": _eixos(
                A1=(1, "Há ameaças verbais entre colegas, sem agressão descrita."),
                A3=(1, "Um insulto leve aparece uma vez."),
            ),
            "evidencias": [],
            "camada_b": {"flags": ["bullying"], "justificativas": {}},
            "camada_c": _c(
                2,
                1,
                2,
                [],
                "Médio",
                ["empatia"],
                "Mostra a amizade como apoio diante de provocações.",
            ),
        },
    },
    {
        "titulo": "Mapa para o Rio Escondido",
        "autores": ["Rafael Siqueira"],
        "genero": "Aventura",
        "paginas": 240,
        "cor": (47, 93, 80),
        "sinopse": "Dois irmãos seguem um mapa deixado pelo avô e enfrentam uma travessia "
        "perigosa, com uma queda grave na correnteza.",
        "fonte": "fontes_publicas",
        "confianca": 0.52,
        "saida": {
            "camada_a": _eixos(
                A1=(
                    2,
                    "Há uma briga descrita entre os irmãos e um desconhecido, sem detalhe gráfico.",
                ),
                A4=(1, "Um personagem adulto é descrito como alguém que bebia."),
            ),
            "evidencias": [
                _ev(
                    "A1",
                    "Os irmãos são abordados por um homem e há luta corporal "
                    "breve; um deles se machuca no braço.",
                )
            ],
            "camada_b": {"flags": ["acidente_grave"], "justificativas": {}},
            "camada_c": _c(
                2,
                2,
                2,
                ["Noções de geografia fluvial"],
                "Médio",
                ["repertorio_cultural"],
                "Aproxima o leitor da paisagem ribeirinha.",
            ),
        },
    },
    {
        "titulo": "O Jardim de Vidro",
        "autores": ["Marina Alcântara"],
        "genero": "Romance",
        "paginas": 312,
        "cor": (138, 75, 58),
        "sinopse": "Depois da morte da mãe, Lia passa um verão com a avó, cuida de um jardim "
        "abandonado e descobre um segredo da família ligado a um abuso no passado.",
        "fonte": "fontes_publicas",
        "confianca": 0.6,
        "saida": {
            "camada_a": _eixos(
                A1=(2, "Uma discussão entre adultos termina em empurrão, descrito sem detalhe."),
                A6=(
                    2,
                    "A avó presencia, em cena, uma situação de abuso doméstico no passado, "
                    "sem detalhamento do ato.",
                ),
            ),
            "evidencias": [
                _ev(
                    "A1",
                    "Em uma discussão, o tio empurra o irmão contra a porta; a cena é "
                    "curta e a narração se concentra na reação de Lia.",
                ),
                _ev(
                    "A6",
                    "Em lembrança narrada pela avó, o pai dela a agredia; o romance mostra "
                    "o medo da personagem, não o ato.",
                    "resenha pública",
                ),
            ],
            "camada_b": {"flags": ["luto", "morte_de_personagem_principal"], "justificativas": {}},
            "camada_c": _c(
                3,
                3,
                3,
                ["Familiaridade com narrativas em dois tempos"],
                "Alto",
                ["empatia", "desenvolvimento_moral"],
                "Trata de amizade e amadurecimento diante da perda. Boa abertura para "
                "conversar sobre luto em família.",
            ),
        },
    },
    {
        "titulo": "Ruído Branco em Agosto",
        "autores": ["Helena Duarte"],
        "genero": "Romance juvenil",
        "paginas": 280,
        "cor": (74, 59, 92),
        "sinopse": "Uma adolescente atravessa um inverno de isolamento e sofrimento psíquico; "
        "o livro acompanha sua recuperação com apoio da família e de uma terapeuta.",
        "fonte": "fontes_publicas",
        "confianca": 0.57,
        "saida": {
            "camada_a": _eixos(
                A3=(1, "Palavrões leves em poucas falas."),
                A5=(3, "Há uma cena explícita de autolesão no meio do livro."),
            ),
            "evidencias": [
                _ev(
                    "A5",
                    "A protagonista se machuca em um momento de crise; a narração "
                    "acompanha o que ela sente e o pedido de ajuda que vem depois.",
                ),
            ],
            "camada_b": {"flags": ["automutilacao"], "justificativas": {}},
            "camada_c": _c(
                3,
                2,
                4,
                [],
                "Alto",
                ["empatia", "pensamento_critico"],
                "Mostra a busca por ajuda e o papel do cuidado da família.",
            ),
        },
    },
    {
        "titulo": "Depois da Meia-Noite",
        "autores": ["Clara Vasques"],
        "genero": "Romance adulto",
        "paginas": 420,
        "cor": (43, 36, 48),
        "sinopse": "Romance entre dois músicos que se reencontram numa turnê, com cenas de "
        "sexo descritas de forma explícita.",
        "fonte": "fontes_publicas",
        "confianca": 0.6,
        "saida": {
            "camada_a": _eixos(
                A2=(
                    4,
                    "Resenhas e a sinopse indicam cenas de sexo descritas de forma gráfica e "
                    "recorrente.",
                ),
                A3=(2, "Palavrões recorrentes nos diálogos."),
                A4=(2, "Consumo social de álcool em festas."),
            ),
            "evidencias": [
                _ev(
                    "A2",
                    "Várias cenas íntimas entre o casal são descritas de forma explícita.",
                    "resenha pública",
                ),
                _ev(
                    "A3",
                    "Os personagens usam palavrões com frequência nos diálogos.",
                    "resenha pública",
                ),
                _ev("A4", "Os músicos bebem em festas depois dos shows.", "sinopse da editora"),
            ],
            "camada_b": {"flags": [], "justificativas": {}},
            "camada_c": _c(3, 2, 2, [], "Baixo", [], "Foco no romance e na vida da turnê."),
        },
    },
    {
        "titulo": "Cinzas de Porto Alto",
        "autores": ["Otávio Prates"],
        "genero": "Suspense",
        "paginas": 520,
        "cor": (140, 47, 27),
        "sinopse": "Um investigador volta à cidade natal para apurar uma série de crimes "
        "ligados à exploração de trabalhadores numa fábrica.",
        "fonte": "fontes_publicas",
        "confianca": 0.55,
        "saida": {
            "camada_a": _eixos(
                A1=(4, "Resenhas descrevem violência gráfica com mutilação."),
                A6=(3, "A exploração e a tortura psicológica dos trabalhadores são centrais."),
                A4=(2, "Consumo de álcool em bares."),
            ),
            "evidencias": [
                _ev(
                    "A1",
                    "Os crimes são descritos com detalhes gráficos dos ferimentos.",
                    "resenha pública",
                ),
                _ev(
                    "A6",
                    "Os trabalhadores são mantidos sob ameaça e humilhação constantes.",
                    "sinopse da editora",
                ),
                _ev(
                    "A4",
                    "O protagonista bebe com frequência em bares da cidade.",
                    "resenha pública",
                ),
            ],
            "camada_b": {"flags": ["arma_de_fogo", "sequestro_ou_carcere"], "justificativas": {}},
            "camada_c": _c(
                4,
                3,
                4,
                ["Contexto de relações de trabalho"],
                "Médio",
                ["pensamento_critico", "conhecimento_historico"],
                "Discute exploração e responsabilidade social.",
            ),
        },
    },
    {
        "titulo": "Vozes do Pátio",
        "autores": ["Lúcia Ferraz"],
        "genero": "Infantojuvenil",
        "paginas": 150,
        "cor": (47, 111, 143),
        "contestada": True,
        "sinopse": "Na hora do recreio, um grupo de alunos passa a perseguir um colega novo; "
        "a turma precisa decidir de que lado está.",
        "fonte": "fontes_publicas",
        "confianca": 0.5,
        "saida": {
            "camada_a": _eixos(
                A1=(1, "Ameaças entre alunos, sem agressão descrita."),
                A3=(2, "Xingamentos recorrentes entre os personagens."),
            ),
            "evidencias": [
                _ev(
                    "A3",
                    "Os alunos xingam o colega novo várias vezes ao longo do livro.",
                    "resenha pública",
                )
            ],
            "camada_b": {"flags": ["bullying", "violencia_escolar"], "justificativas": {}},
            "camada_c": _c(
                2,
                1,
                3,
                [],
                "Alto",
                ["empatia", "desenvolvimento_moral"],
                "Convida a discutir responsabilidade coletiva diante do bullying.",
            ),
        },
    },
    {
        "titulo": "Crônicas do Vento Sul",
        "autores": ["Ana Ribas"],
        "genero": "Crônicas",
        "paginas": 160,
        "cor": (94, 106, 99),
        "sinopse": None,
        "fonte": "metadados_e_conhecimento_previo",
        "confianca": 0.35,
        "saida": {
            "camada_a": _eixos(A4=(1, "Há menção a personagens que bebiam, sem cena de uso.")),
            "evidencias": [],
            "camada_b": {"flags": [], "justificativas": {}},
            "camada_c": _c(
                3,
                1,
                2,
                [],
                "Médio",
                ["repertorio_cultural"],
                "Crônicas sobre a vida no litoral sul.",
            ),
        },
    },
    {
        "titulo": "O Último Farol",
        "autores": ["Joana Leme"],
        "genero": "Aventura",
        "paginas": 210,
        "cor": (79, 90, 110),
        "sem_ficha": True,
        "sinopse": "Uma faroleira solitária recebe um náufrago misterioso.",
    },
]


def _quebrar(texto: str, fonte, largura: int, desenho: ImageDraw.ImageDraw) -> list[str]:
    linhas, atual = [], ""
    for palavra in texto.split():
        teste = f"{atual} {palavra}".strip()
        if desenho.textlength(teste, font=fonte) <= largura:
            atual = teste
        else:
            linhas.append(atual)
            atual = palavra
    return [*linhas, atual] if atual else linhas


def _fonte(caminhos: list[str], tamanho: int):
    for c in caminhos:
        if Path(c).exists():
            return ImageFont.truetype(c, tamanho)
    return ImageFont.load_default(size=tamanho)


def gerar_capa(titulo: str, autor: str, cor: tuple[int, int, int], destino: Path) -> None:
    """Capa simples e legível: título grande em serifa, autor embaixo, motivo geométrico."""
    img = Image.new("RGB", (600, 900), cor)
    d = ImageDraw.Draw(img)
    clara = (246, 241, 231)
    serifa = _fonte(
        [
            "/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf",
            "/usr/share/fonts/truetype/liberation/LiberationSerif-Bold.ttf",
        ],
        64,
    )
    sans = _fonte(
        [
            "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
            "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
        ],
        34,
    )
    d.rectangle([40, 40, 560, 860], outline=clara, width=3)
    for i in range(5):
        d.ellipse([200 - i * 18, 520 - i * 18, 400 + i * 18, 720 + i * 18], outline=clara, width=2)
    y = 110
    for linha in _quebrar(titulo.upper(), serifa, 480, d):
        d.text((300, y), linha, font=serifa, fill=clara, anchor="ma")
        y += 78
    d.text((300, 780), autor, font=sans, fill=clara, anchor="ma")
    destino.parent.mkdir(parents=True, exist_ok=True)
    img.save(destino, format="PNG", optimize=True)


def semear_demo(sessao: Session) -> list[Obra]:
    cfg_servico.semear(sessao)
    criadas = []
    for dados in OBRAS:
        existente = sessao.scalars(
            select(Obra).where(Obra.titulo == dados["titulo"], Obra.demonstracao.is_(True))
        ).first()
        if existente:
            criadas.append(existente)
            continue
        from app.servicos.obras import slugificar

        arquivo = f"demo-{slugificar(dados['titulo'])}.png"
        gerar_capa(dados["titulo"], dados["autores"][0], dados["cor"], PASTA_CAPAS / arquivo)
        obra = Obra(
            titulo=dados["titulo"],
            autores=dados["autores"],
            autores_texto=", ".join(dados["autores"]),
            sinopse=dados.get("sinopse"),
            idioma="pt",
            genero=dados["genero"],
            paginas=dados["paginas"],
            fonte_metadados="base_entrelinhas",
            demonstracao=True,
        )
        edicao = Edicao(
            editora="Edição de demonstração", ano=2026, capa_url=f"/estatico/capas/{arquivo}"
        )
        obra.edicoes.append(edicao)
        sessao.add(obra)
        sessao.flush()
        _indexar(sessao, edicao, PASTA_CAPAS / arquivo)
        if not dados.get("sem_ficha"):
            saida = {**dados["saida"], "confianca": dados["confianca"], "observacoes": ""}
            validar_saida_modelo(saida, dados["fonte"])
            ficha = Ficha(
                obra_id=obra.id, slug=fichas_servico.novo_slug(sessao, obra), status="em_analise"
            )
            sessao.add(ficha)
            sessao.flush()
            revisada = bool(dados.get("revisada"))
            ficha_dados = montar_ficha(
                obra_id=str(obra.id),
                saida=saida,
                paginas=dados["paginas"],
                procedencia={
                    "fonte_da_analise": dados["fonte"],
                    "confianca": dados["confianca"],
                    "modelo": "demonstração (ficha escrita à mão para obra fictícia)",
                    "fontes": [{"tipo": "demonstracao", "url": None}],
                    "revisada_por_humano": revisada,
                    "revisada_em": "2026-11-01T12:00:00+00:00" if revisada else None,
                },
                versao_ficha=1,
            )
            fichas_servico.publicar_versao(
                sessao,
                ficha,
                ficha_dados,
                autor_papel="sistema",
                motivo="Dados de demonstração",
                status="em_revisao" if dados.get("contestada") else "publicada",
            )
            if dados.get("contestada"):
                usuario = _usuario_demo(
                    sessao, "leitora@demo.entrelinhas", "usuario", "Leitora Demo"
                )
                sessao.add(
                    Contestacao(
                        usuario_id=usuario.id,
                        ficha_id=ficha.id,
                        campo="A3",
                        texto="Os xingamentos aparecem só em dois capítulos; acho que o nível é 1.",
                    )
                )
        sessao.commit()
        criadas.append(obra)
    return criadas


def _indexar(sessao: Session, edicao: Edicao, caminho: Path) -> None:
    """Põe a capa no índice de reconhecimento com o modelo configurado."""
    from app.provedores.modelo_capa import obter_modelo_capa
    from app.reconhecimento.servico import indexar_capa

    with Image.open(caminho) as img:
        indexar_capa(sessao, edicao, img.convert("RGB"), obter_modelo_capa(),
                     edicao.capa_url or "")


def _usuario_demo(sessao: Session, email: str, papel: str, nome: str) -> Usuario:
    usuario = sessao.scalars(select(Usuario).where(Usuario.email == email)).first()
    if usuario is None:
        senha = os.environ.get("DEMO_SENHA", "entrelinhas-demo")
        usuario = Usuario(email=email, hash_senha=hash_senha(senha), nome=nome, papel=papel)
        sessao.add(usuario)
        sessao.flush()
    return usuario


def semear_contas_demo(sessao: Session) -> None:
    """Contas de demonstração, só fora de produção."""
    if configuracoes().ambiente == "producao":
        return
    _usuario_demo(sessao, "leitora@demo.entrelinhas", "usuario", "Leitora Demo")
    _usuario_demo(sessao, "revisora@demo.entrelinhas", "revisor", "Revisora Demo")
    _usuario_demo(sessao, "admin@demo.entrelinhas", "admin", "Admin Demo")
    sessao.commit()


def main() -> None:
    with fabrica_sessao()() as sessao:
        semear_contas_demo(sessao)
        obras = semear_demo(sessao)
        print(f"{len(obras)} obras de demonstração prontas.")


if __name__ == "__main__":
    main()
