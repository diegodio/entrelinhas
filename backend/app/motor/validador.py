"""Validação da saída do classificador (seção 4.4). Nada da IA entra no banco sem passar aqui."""

from __future__ import annotations

from app.rubrica import IDS_EIXOS, carregar_rubrica, nivel_regra_dura_a5

TETOS_PADRAO = {
    "texto_integral": 1.0,
    "amostragem": 0.8,
    "fontes_publicas": 0.6,
    "metadados_e_conhecimento_previo": 0.4,
}
FONTES_COM_TEXTO = ("texto_integral", "amostragem")


class SaidaModeloInvalida(ValueError):
    """A resposta do modelo não cumpre o contrato. A mensagem vai anexada no reprocesso."""

    def __init__(self, erros: list[str]):
        self.erros = erros
        super().__init__(" | ".join(erros))


def _inteiro(valor) -> bool:
    return isinstance(valor, int) and not isinstance(valor, bool)


def validar_saida_modelo(
    saida: dict,
    fonte_da_analise: str,
    teto_confianca: float | None = None,
    rubrica: dict | None = None,
    exigir_confianca: bool = True,
) -> dict:
    """Levanta SaidaModeloInvalida com a lista completa de erros, ou devolve a saída."""
    rubrica = rubrica or carregar_rubrica()
    erros: list[str] = []
    if not isinstance(saida, dict):
        raise SaidaModeloInvalida(["A resposta não é um objeto JSON."])

    camada_a = saida.get("camada_a")
    if not isinstance(camada_a, dict):
        erros.append("camada_a ausente ou não é objeto.")
        camada_a = {}
    extras = set(camada_a) - set(IDS_EIXOS)
    if extras:
        erros.append(f"camada_a com eixos desconhecidos: {sorted(extras)}.")

    evidencias = saida.get("evidencias", [])
    if not isinstance(evidencias, list):
        erros.append("evidencias deve ser uma lista.")
        evidencias = []
    eixos_com_evidencia = {ev.get("eixo") for ev in evidencias if isinstance(ev, dict)}

    niveis: dict[str, int] = {}
    for eixo_id in IDS_EIXOS:
        item = camada_a.get(eixo_id)
        if not isinstance(item, dict):
            erros.append(f"camada_a.{eixo_id} ausente.")
            continue
        nivel = item.get("nivel")
        if not _inteiro(nivel) or not 0 <= nivel <= 4:
            erros.append(f"camada_a.{eixo_id}.nivel inválido: {nivel!r} (inteiro de 0 a 4).")
            continue
        niveis[eixo_id] = nivel
        if nivel > 0 and not str(item.get("justificativa") or "").strip():
            erros.append(f"camada_a.{eixo_id}: nível {nivel} sem justificativa.")
        if nivel >= rubrica["evidencia"]["nivel_minimo_para_exigir"] and (
            eixo_id not in eixos_com_evidencia
        ):
            erros.append(f"camada_a.{eixo_id}: nível {nivel} exige ao menos uma evidência.")

    sem_texto = fonte_da_analise not in FONTES_COM_TEXTO
    limite_palavras = rubrica["evidencia"]["limite_palavras_trecho_padrao"]
    for i, ev in enumerate(evidencias):
        if not isinstance(ev, dict):
            erros.append(f"evidencias[{i}] não é objeto.")
            continue
        if ev.get("eixo") not in IDS_EIXOS:
            erros.append(f"evidencias[{i}].eixo inválido: {ev.get('eixo')!r}.")
        if not str(ev.get("parafrase") or "").strip():
            erros.append(f"evidencias[{i}]: paráfrase é obrigatória.")
        trecho = ev.get("trecho_literal")
        if trecho:
            if sem_texto:
                erros.append(
                    f"evidencias[{i}]: trecho_literal deve ser null quando não há acesso ao texto."
                )
            elif len(str(trecho).split()) > limite_palavras:
                erros.append(
                    f"evidencias[{i}]: trecho_literal acima de {limite_palavras} palavras."
                )
        if sem_texto and ev.get("localizacao"):
            erros.append(f"evidencias[{i}]: localização deve ser null quando não há texto.")

    # Regra dura do A5: nenhum trecho literal com nível >= 3.
    if niveis.get("A5", 0) >= nivel_regra_dura_a5(rubrica):
        for ev in evidencias:
            if isinstance(ev, dict) and ev.get("eixo") == "A5" and ev.get("trecho_literal"):
                erros.append(
                    "Regra dura A5 violada: evidência de A5 com trecho_literal em nível >= 3."
                )

    camada_b = saida.get("camada_b")
    if not isinstance(camada_b, dict):
        erros.append("camada_b ausente ou não é objeto.")
        camada_b = {}
    vocabulario = set(rubrica["camada_b"]["vocabulario"])
    flags = camada_b.get("flags", [])
    if not isinstance(flags, list):
        erros.append("camada_b.flags deve ser uma lista.")
        flags = []
    for flag in flags:
        if flag not in vocabulario:
            erros.append(f"camada_b: flag fora do vocabulário fechado: {flag!r}.")
    if len(set(flags)) != len(flags):
        erros.append("camada_b: flags repetidas.")
    justificativas = camada_b.get("justificativas") or {}
    for obrigatoria in rubrica["camada_b"]["flags_com_justificativa_obrigatoria"]:
        if obrigatoria in flags and not str(justificativas.get(obrigatoria) or "").strip():
            erros.append(f"camada_b: flag {obrigatoria!r} sem justificativa obrigatória.")

    camada_c = saida.get("camada_c")
    if not isinstance(camada_c, dict):
        erros.append("camada_c ausente ou não é objeto.")
        camada_c = {}
    for dimensao in ("vocabulario", "estrutura_narrativa", "densidade_tematica"):
        valor = camada_c.get(dimensao)
        if not _inteiro(valor) or not 1 <= valor <= 5:
            erros.append(f"camada_c.{dimensao} inválido: {valor!r} (inteiro de 1 a 5).")
    repertorio = camada_c.get("exigencia_repertorio", [])
    max_rep = rubrica["camada_c"]["exigencia_repertorio"]["max_itens"]
    if not isinstance(repertorio, list) or len(repertorio) > max_rep:
        erros.append(f"camada_c.exigencia_repertorio: lista com até {max_rep} itens.")
    vf = camada_c.get("valor_formativo")
    regras_vf = rubrica["camada_c"]["valor_formativo"]
    if not isinstance(vf, dict):
        erros.append("camada_c.valor_formativo ausente.")
    else:
        if vf.get("nivel") not in regras_vf["niveis"]:
            erros.append(f"valor_formativo.nivel inválido: {vf.get('nivel')!r}.")
        marcadores = vf.get("marcadores", [])
        if not isinstance(marcadores, list) or len(marcadores) > regras_vf["max_marcadores"]:
            erros.append(f"valor_formativo.marcadores: até {regras_vf['max_marcadores']} itens.")
        else:
            for m in marcadores:
                if m not in regras_vf["marcadores"]:
                    erros.append(f"valor_formativo: marcador desconhecido {m!r}.")

    if exigir_confianca:
        confianca = saida.get("confianca")
        teto = (
            teto_confianca
            if teto_confianca is not None
            else TETOS_PADRAO.get(fonte_da_analise, 0.4)
        )
        if isinstance(confianca, bool) or not isinstance(confianca, int | float):
            erros.append(f"confianca inválida: {confianca!r}.")
        elif not 0.0 <= float(confianca) <= 1.0:
            erros.append(f"confianca fora de 0 a 1: {confianca!r}.")
        elif float(confianca) > teto + 1e-9:
            erros.append(
                f"confianca {confianca} acima do teto {teto} para a fonte {fonte_da_analise}."
            )

    if erros:
        raise SaidaModeloInvalida(erros)
    return saida
