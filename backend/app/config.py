"""Configuração por variáveis de ambiente. Segredos só aqui, nunca no código."""

from __future__ import annotations

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Configuracoes(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    ambiente: str = "local"  # local | teste | producao
    database_url: str = "postgresql+psycopg://postgres@localhost:5432/entrelinhas"
    redis_url: str | None = None
    # "fila": Redis + RQ (produção). "thread": segundo plano no próprio processo (dev sem
    # Redis). "sincrono": executa na hora (testes).
    tarefas_modo: str = "thread"

    url_publica_api: str = "http://localhost:8000"
    url_publica_app: str = "http://localhost:8080"
    cors_origens: str = "http://localhost:8080,http://localhost:5000"

    # Autenticação
    jwt_segredo: str = "troque-este-segredo-em-producao-0000000000"
    jwt_minutos_acesso: int = 15
    dias_renovacao: int = 30
    google_client_ids: str = ""  # separados por vírgula
    apple_client_ids: str = ""

    # Provedores (seção 4.7). "falso" = implementação determinística para testes.
    provedor_llm: str = "nenhum"  # anthropic | openai | google | falso | nenhum
    modelo_llm: str = ""  # identificador do modelo no provedor; conferir na documentação atual
    llm_fallbacks: bool = True  # fallback do servidor para recusas (só Anthropic)
    anthropic_api_key: str = ""
    openai_api_key: str = ""
    google_api_key: str = ""

    fontes_metadados: str = "google_books,open_library"  # vazio = sem rede
    fontes_resenhas: str = "wikipedia_pt"  # vazio = nenhuma
    google_books_api_key: str = ""

    provedor_pagamento: str = "falso"  # stripe | falso
    stripe_secret_key: str = ""
    stripe_webhook_secret: str = ""
    stripe_preco_familia: str = ""
    stripe_preco_escola: str = ""
    apple_bundle_id: str = ""
    apple_shared_secret: str = ""
    google_play_pacote: str = ""
    google_play_conta_servico_json: str = ""

    armazenamento: str = "local"  # local | s3
    pasta_arquivos: str = "dados_locais/arquivos"
    s3_endpoint: str = ""
    s3_bucket: str = "entrelinhas"
    s3_chave: str = ""
    s3_segredo: str = ""

    provedor_email: str = "console"  # console | smtp
    smtp_host: str = ""
    smtp_porta: int = 587
    smtp_usuario: str = ""
    smtp_senha: str = ""
    email_remetente: str = "nao-responda@entrelinhas.app"

    limite_requisicoes_por_minuto: int = 120
    limite_reconhecimento_por_minuto: int = 30

    @property
    def lista_cors(self) -> list[str]:
        return [o.strip() for o in self.cors_origens.split(",") if o.strip()]


@lru_cache
def configuracoes() -> Configuracoes:
    return Configuracoes()
