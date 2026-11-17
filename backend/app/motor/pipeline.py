"""Pipeline de análise (seção 4.4).

1. Coleta: metadados e sinopse (cascata) e resenhas públicas permitidas.
2. Fonte da análise e teto de confiança.
3. Classificação pelo LLM configurado.
4. Validação; até duas novas tentativas com a lista de erros. Persistindo, a obra fica sem
   ficha (status "indisponivel"), nunca com ficha parcial.
5. Cálculo (seção 3.1) e montagem da ficha.
6. Publicação com revisada_por_humano = false; entra na fila de revisão editorial.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass, field

from sqlalchemy.orm import Session

from app.core.agregacao import arredondar_meio_para_cima
from app.core.ficha import montar_ficha
from app.modelos import Ficha, FonteFicha, Obra
from app.motor import prompt as prompt_mod
from app.motor.validador import SaidaModeloInvalida, validar_saida_modelo
from app.provedores.llm import LLMIndisponivel, LLMRecusou, ProvedorLLM
from app.provedores.metadados import Cascata
from app.provedores.resenhas import FonteDeResenhas
from app.rubrica import IDS_EIXOS, carregar_rubrica
from app.servicos import configuracao as cfg_servico
from app.servicos import fichas as fichas_servico

log = logging.getLogger("entrelinhas.pipeline")

TENTATIVAS_EXTRAS = 2
PALAVRAS_POR_BLOCO = 6000


class AnaliseFalhou(Exception):
    pass


@dataclass
class Coleta:
    material: list[dict] = field(default_factory=list)
    fontes: list[dict] = field(default_factory=list)
    fonte_da_analise: str = "metadados_e_conhecimento_previo"


def coletar(obra: Obra, cascata: Cascata | None, resenhas: list[FonteDeResenhas]) -> Coleta:
    """Junta sinopse e resenhas permitidas. Nunca o texto integral da obra."""
    c = Coleta()
    if not obra.sinopse and cascata is not None:
        for edicao in obra.edicoes:
            if edicao.isbn13:
                achado = cascata.por_isbn(edicao.isbn13)
                if achado and achado.sinopse:
                    obra.sinopse = achado.sinopse
                    obra.paginas = obra.paginas or achado.paginas
                    c.fontes.append(
                        {
                            "tipo": "sinopse",
                            "url": achado.url_fonte,
                            "descricao": f"Sinopse ({achado.fonte})",
                        }
                    )
                    break
    if obra.sinopse:
        c.material.append(
            {"tipo": "sinopse", "origem": "sinopse da editora", "texto": obra.sinopse}
        )
        if not c.fontes:
            c.fontes.append(
                {"tipo": "sinopse", "url": None, "descricao": f"Sinopse ({obra.fonte_metadados})"}
            )
    for fonte in resenhas:
        for r in fonte.buscar(obra.titulo, list(obra.autores or [])):
            c.material.append(
                {"tipo": "resenha", "origem": f"resenha: {r.fonte}", "texto": r.texto}
            )
            c.fontes.append(
                {"tipo": "resenha", "url": r.url, "descricao": f"{r.fonte} ({r.licenca})"}
            )
    tem_sinopse = any(m["tipo"] == "sinopse" for m in c.material)
    tem_resenha = any(m["tipo"] == "resenha" for m in c.material)
    c.fonte_da_analise = (
        "fontes_publicas" if tem_sinopse and tem_resenha else "metadados_e_conhecimento_previo"
    )
    c.fontes.append({"tipo": "metadado", "url": None, "descricao": "Metadados bibliográficos"})
    return c


def _obra_meta(obra: Obra) -> dict:
    return {
        "titulo": obra.titulo,
        "subtitulo": obra.subtitulo,
        "autores": obra.autores,
        "genero": obra.genero,
        "idioma": obra.idioma,
        "paginas": obra.paginas,
    }


def classificar(
    llm: ProvedorLLM,
    obra_meta: dict,
    material: list[dict],
    fonte: str,
    teto: float,
    limite_palavras: int,
) -> dict:
    """Chama o LLM e valida. Refaz até TENTATIVAS_EXTRAS vezes anexando os erros."""
    rubrica = carregar_rubrica()
    esquema = prompt_mod.esquema_saida(rubrica)
    erros: list[str] | None = None
    for tentativa in range(1 + TENTATIVAS_EXTRAS):
        texto_prompt = prompt_mod.montar_prompt(
            obra_meta, material, fonte, teto, limite_palavras, erros, rubrica
        )
        bruto = llm.gerar_json(prompt_mod.SISTEMA, texto_prompt, esquema)
        try:
            saida = prompt_mod.extrair_json(bruto)
            return validar_saida_modelo(saida, fonte, teto_confianca=teto, rubrica=rubrica)
        except (ValueError, SaidaModeloInvalida) as e:
            erros = e.erros if isinstance(e, SaidaModeloInvalida) else [str(e)]
            log.warning("Saída inválida (tentativa %s): %s", tentativa + 1, erros)
    raise AnaliseFalhou("A saída do modelo continuou inválida: " + " | ".join(erros or []))


def consolidar_blocos(saidas: list[dict]) -> dict:
    """Junta as saídas de vários blocos de texto: máximo por eixo, união de alertas,
    média (meio para cima) do perfil de leitura. Código, não IA."""
    camada_a = {}
    for e in IDS_EIXOS:
        maior = max(saidas, key=lambda s: s["camada_a"][e]["nivel"])
        camada_a[e] = dict(maior["camada_a"][e])
    flags = list(dict.fromkeys(f for s in saidas for f in s["camada_b"]["flags"]))
    justificativas = {}
    for s in saidas:
        justificativas.update(s["camada_b"].get("justificativas") or {})

    def media(chave: str) -> int:
        return arredondar_meio_para_cima(sum(s["camada_c"][chave] for s in saidas) / len(saidas))

    niveis_vf = ["Baixo", "Médio", "Alto"]
    vf_nivel = niveis_vf[
        arredondar_meio_para_cima(
            sum(niveis_vf.index(s["camada_c"]["valor_formativo"]["nivel"]) for s in saidas)
            / len(saidas)
        )
    ]
    marcadores = list(
        dict.fromkeys(m for s in saidas for m in s["camada_c"]["valor_formativo"]["marcadores"])
    )[:3]
    repertorio = list(
        dict.fromkeys(r for s in saidas for r in s["camada_c"]["exigencia_repertorio"])
    )[:3]
    return {
        "camada_a": camada_a,
        "evidencias": [ev for s in saidas for ev in s.get("evidencias", [])],
        "camada_b": {"flags": flags, "justificativas": justificativas},
        "camada_c": {
            "vocabulario": media("vocabulario"),
            "estrutura_narrativa": media("estrutura_narrativa"),
            "densidade_tematica": media("densidade_tematica"),
            "exigencia_repertorio": repertorio,
            "valor_formativo": {
                "nivel": vf_nivel,
                "marcadores": marcadores,
                "justificativa": saidas[0]["camada_c"]["valor_formativo"]["justificativa"],
            },
        },
        "confianca": min(s["confianca"] for s in saidas),
        "observacoes": " ".join(s.get("observacoes", "") for s in saidas).strip(),
    }


def dividir_em_blocos(texto: str, palavras: int = PALAVRAS_POR_BLOCO) -> list[str]:
    p = texto.split()
    return [" ".join(p[i : i + palavras]) for i in range(0, len(p), palavras)] or [""]


def analisar(
    sessao: Session,
    obra: Obra,
    llm: ProvedorLLM,
    cascata: Cascata | None,
    resenhas: list[FonteDeResenhas],
    texto_obra: str | None = None,
    fonte_texto: str = "texto_integral",
) -> Ficha:
    """Executa o pipeline e publica a ficha. Levanta AnaliseFalhou."""
    config = cfg_servico.carregar(sessao)
    limites = config["limites"]
    ficha = obra.ficha
    if ficha is None:
        ficha = Ficha(
            obra_id=obra.id, slug=fichas_servico.novo_slug(sessao, obra), status="em_analise"
        )
        sessao.add(ficha)
        sessao.commit()

    if texto_obra:
        # Caminho de administrador: obra em domínio público ou com autorização da editora.
        fonte = fonte_texto
        teto = limites["tetos_confianca"][fonte]
        saidas = [
            classificar(
                llm,
                _obra_meta(obra),
                [{"tipo": "trecho", "origem": f"texto da obra, parte {i + 1}", "texto": bloco}],
                fonte,
                teto,
                limites["palavras_por_trecho"],
            )
            for i, bloco in enumerate(dividir_em_blocos(texto_obra))
        ]
        saida = consolidar_blocos(saidas) if len(saidas) > 1 else saidas[0]
        fontes = [
            {
                "tipo": "texto",
                "url": None,
                "descricao": "Texto da obra (domínio público ou autorizado)",
            }
        ]
    else:
        coleta = coletar(obra, cascata, resenhas)
        fonte = coleta.fonte_da_analise
        teto = limites["tetos_confianca"][fonte]
        saida = classificar(
            llm, _obra_meta(obra), coleta.material, fonte, teto, limites["palavras_por_trecho"]
        )
        fontes = coleta.fontes

    dados = montar_ficha(
        obra_id=str(obra.id),
        saida=saida,
        paginas=obra.paginas,
        procedencia={
            "fonte_da_analise": fonte,
            "confianca": min(float(saida["confianca"]), teto),
            "modelo": f"{llm.nome}/{llm.modelo}",
            "fontes": [{"tipo": f["tipo"], "url": f["url"]} for f in fontes],
            "revisada_por_humano": False,
            "revisada_em": None,
        },
        versao_ficha=ficha.versao_ficha + 1,
        max_trechos=limites["trechos_por_ficha"],
        limite_palavras=limites["palavras_por_trecho"],
    )
    sessao.query(FonteFicha).filter_by(ficha_id=ficha.id).delete()
    for f in fontes:
        sessao.add(
            FonteFicha(
                ficha_id=ficha.id, tipo=f["tipo"], url=f["url"], descricao=f.get("descricao")
            )
        )
    return fichas_servico.publicar_versao(
        sessao,
        ficha,
        dados,
        autor_papel="sistema",
        motivo=f"Análise automática ({fonte})",
        status="publicada",
    )


__all__ = [
    "AnaliseFalhou",
    "LLMIndisponivel",
    "LLMRecusou",
    "analisar",
    "classificar",
    "coletar",
    "consolidar_blocos",
    "dividir_em_blocos",
]
