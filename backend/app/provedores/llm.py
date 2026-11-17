"""Provedores de LLM para o classificador (seção 4.7).

Nada no código de negócio conhece um fornecedor: o pipeline usa só `ProvedorLLM`.
Cada adaptador recebe o prompt e o JSON Schema da saída e devolve o TEXTO JSON; quem
valida é app/motor/validador.py, sempre.

Situação de verificação: só a implementação falsa foi exercitada neste ambiente (não há
chaves de API). Os adaptadores reais estão escritos conforme a documentação de cada
provedor e precisam de um teste com chave antes de produção (docs/como-rodar.md).
"""

from __future__ import annotations

import json
from collections.abc import Callable
from typing import Protocol

import httpx

from app.config import Configuracoes, configuracoes


class LLMIndisponivel(Exception):
    """Sem provedor configurado ou falha temporária (rede, limite, servidor)."""


class LLMRecusou(Exception):
    """O modelo recusou a tarefa (ex.: classificadores de segurança)."""


class ProvedorLLM(Protocol):
    nome: str
    modelo: str

    def gerar_json(self, sistema: str, prompt: str, esquema: dict) -> str: ...


# ----------------------------------------------------------------- Anthropic


class Anthropic:
    """Messages API via SDK oficial, com saída estruturada (output_config.format).

    Usa o mecanismo de fallback do servidor para recusas ("default": a API escolhe o
    modelo de reserva pela categoria da recusa). Desligue com LLM_FALLBACKS=0.
    """

    nome = "anthropic"
    MODELO_PADRAO = "claude-opus-5-5"

    def __init__(self, cfg: Configuracoes):
        import anthropic

        if not cfg.anthropic_api_key:
            raise LLMIndisponivel("ANTHROPIC_API_KEY não configurada.")
        self._sdk = anthropic
        self.cliente = anthropic.Anthropic(
            api_key=cfg.anthropic_api_key, timeout=180, max_retries=2
        )
        self.modelo = cfg.modelo_llm or self.MODELO_PADRAO
        self.fallbacks = cfg.llm_fallbacks

    def gerar_json(self, sistema: str, prompt: str, esquema: dict) -> str:
        a = self._sdk
        extras = (
            {"betas": ["server-side-fallback-2026-07-01"], "fallbacks": "default"}
            if self.fallbacks
            else {}
        )
        try:
            resposta = self.cliente.beta.messages.create(
                model=self.modelo,
                max_tokens=16000,
                system=sistema,
                messages=[{"role": "user", "content": prompt}],
                output_config={
                    "effort": "medium",
                    "format": {"type": "json_schema", "schema": esquema},
                },
                **extras,
            )
        except (a.RateLimitError, a.InternalServerError, a.APIConnectionError) as e:
            raise LLMIndisponivel(f"Anthropic temporariamente indisponível: {e}") from e
        except a.APIStatusError as e:
            raise LLMIndisponivel(f"Anthropic recusou a requisição ({e.status_code}).") from e
        if resposta.stop_reason == "refusal":
            categoria = getattr(resposta.stop_details, "category", None)
            raise LLMRecusou(f"O modelo recusou a análise (categoria: {categoria}).")
        if resposta.stop_reason == "max_tokens":
            raise LLMIndisponivel("Resposta truncada (max_tokens).")
        textos = [b.text for b in resposta.content if b.type == "text"]
        if not textos:
            raise LLMIndisponivel("Resposta sem texto.")
        return textos[0]


# --------------------------------------------------------------------- OpenAI


class OpenAI:
    """Chat Completions com response_format json_schema. Exige MODELO_LLM (sem padrão)."""

    nome = "openai"

    def __init__(self, cfg: Configuracoes, cliente: httpx.Client | None = None):
        if not cfg.openai_api_key or not cfg.modelo_llm:
            raise LLMIndisponivel("OPENAI_API_KEY e MODELO_LLM são necessários.")
        self.modelo = cfg.modelo_llm
        self.chave = cfg.openai_api_key
        self.cliente = cliente or httpx.Client(timeout=180)

    def gerar_json(self, sistema: str, prompt: str, esquema: dict) -> str:
        try:
            r = self.cliente.post(
                "https://api.openai.com/v1/chat/completions",
                headers={"Authorization": f"Bearer {self.chave}"},
                json={
                    "model": self.modelo,
                    "messages": [
                        {"role": "system", "content": sistema},
                        {"role": "user", "content": prompt},
                    ],
                    "response_format": {
                        "type": "json_schema",
                        "json_schema": {
                            "name": "ficha_entrelinhas",
                            "schema": esquema,
                            "strict": False,
                        },
                    },
                },
            )
            r.raise_for_status()
            escolha = r.json()["choices"][0]
        except (httpx.HTTPError, KeyError, ValueError) as e:
            raise LLMIndisponivel(f"OpenAI indisponível: {e}") from e
        if escolha.get("message", {}).get("refusal"):
            raise LLMRecusou(escolha["message"]["refusal"])
        return escolha["message"]["content"]


# --------------------------------------------------------------------- Google


class Google:
    """Gemini generateContent com responseMimeType JSON. Exige MODELO_LLM (sem padrão)."""

    nome = "google"

    def __init__(self, cfg: Configuracoes, cliente: httpx.Client | None = None):
        if not cfg.google_api_key or not cfg.modelo_llm:
            raise LLMIndisponivel("GOOGLE_API_KEY e MODELO_LLM são necessários.")
        self.modelo = cfg.modelo_llm
        self.chave = cfg.google_api_key
        self.cliente = cliente or httpx.Client(timeout=180)

    def gerar_json(self, sistema: str, prompt: str, esquema: dict) -> str:
        url = (
            f"https://generativelanguage.googleapis.com/v1beta/models/{self.modelo}:generateContent"
        )
        try:
            r = self.cliente.post(
                url,
                headers={"x-goog-api-key": self.chave},
                json={
                    "systemInstruction": {"parts": [{"text": sistema}]},
                    "contents": [{"role": "user", "parts": [{"text": prompt}]}],
                    "generationConfig": {"responseMimeType": "application/json"},
                },
            )
            r.raise_for_status()
            candidato = r.json()["candidates"][0]
        except (httpx.HTTPError, KeyError, IndexError, ValueError) as e:
            raise LLMIndisponivel(f"Google indisponível: {e}") from e
        if candidato.get("finishReason") == "SAFETY":
            raise LLMRecusou("O modelo recusou a análise.")
        return "".join(p.get("text", "") for p in candidato["content"]["parts"])


# -------------------------------------------------------------------- falsos


class Falso:
    """Determinístico, para testes. Devolve respostas prontas (ou geradas por função)."""

    nome = "falso"
    modelo = "falso-1"

    def __init__(self, respostas: list[str | dict] | Callable[[str], str | dict] | None = None):
        self.respostas = respostas
        self.chamadas: list[str] = []

    def gerar_json(self, sistema: str, prompt: str, esquema: dict) -> str:
        self.chamadas.append(prompt)
        if self.respostas is None:
            raise LLMIndisponivel("Provedor falso sem respostas configuradas.")
        if callable(self.respostas):
            r = self.respostas(prompt)
        else:
            r = self.respostas[min(len(self.chamadas), len(self.respostas)) - 1]
        return r if isinstance(r, str) else json.dumps(r, ensure_ascii=False)


class Nenhum:
    nome = "nenhum"
    modelo = ""

    def gerar_json(self, sistema: str, prompt: str, esquema: dict) -> str:
        raise LLMIndisponivel(
            "Nenhum provedor de LLM configurado. Defina PROVEDOR_LLM e a chave correspondente."
        )


_falso_global = Falso()


def obter_llm() -> ProvedorLLM:
    cfg = configuracoes()
    match cfg.provedor_llm:
        case "anthropic":
            return Anthropic(cfg)
        case "openai":
            return OpenAI(cfg)
        case "google":
            return Google(cfg)
        case "falso":
            return _falso_global
        case _:
            return Nenhum()
