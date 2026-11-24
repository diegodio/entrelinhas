# Arquitetura

```
app/        Flutter (Android, iOS, web) ── HTTP/JSON ──▶ backend/  FastAPI ──▶ PostgreSQL + pgvector
                                                            │  ├─▶ Redis + RQ (worker: análises, importações)
                                                            │  ├─▶ S3/MinIO (PDFs e arquivos)
                                                            │  └─▶ provedores: LLM, metadados, resenhas,
                                                            │        pagamento, e-mail
```

## Backend (`backend/app`)

| Pasta/arquivo | Papel |
|---|---|
| `rubrica/` | Rubrica v1.0 (JSON, dado) e leitura |
| `core/agregacao.py` | Regra da faixa (função pura). Nenhuma IA aqui |
| `core/ficha.py` | Monta a ficha (contrato 4.3); campos calculados sempre pelo código |
| `core/isbn.py`, `core/textos.py` | ISBN; textos gerados pelo backend |
| `motor/` | Prompt do classificador, validador, pipeline (coleta → classificação → validação → cálculo → publicação) |
| `reconhecimento/` | Leitura do código de barras (EAN-13/ISBN) numa foto |
| `provedores/` | Interfaces e adaptadores trocáveis: `llm`, `metadados`, `resenhas`, `pagamento`, `email`, `login_social`. Cada um tem implementação falsa |
| `servicos/` | Regras de uso: planos e limite mensal, flags, fichas, obras, importação, relatórios, PDF, armazenamento, limitador |
| `api/` | Rotas `/v1` (OpenAPI em `/docs`) |
| `tarefas.py`, `worker.py` | Fila (RQ) e execução das tarefas |
| `demo.py` | Obras fictícias de demonstração |

Erros em formato único: `{"codigo", "mensagem", "detalhes"}`.

## App (`app/lib`)

| Pasta | Papel |
|---|---|
| `nucleo/tema` | Único arquivo de cores, tipografia, espaços e raios (direção editorial) |
| `l10n/app_pt.arb` | Todos os textos visíveis |
| `nucleo/rede` | Dio, erro da API, renovação de token |
| `nucleo/config` | Ambiente (`--dart-define`) e flags do servidor (`podeExibir`) |
| `nucleo/componentes` | Selo de faixa, linha de eixo, chip, barra de confiança, linha de livro, estados |
| `funcionalidades/<nome>/{dados,dominio,apresentacao}` | Início, busca, ficha, escanear, conta, listas, planos, contestação, metodologia, boas-vindas, acervo, revisão |

Estado com Riverpod 3; rotas com go_router (URLs legíveis na web); modelos com freezed.

## Invariantes e onde são garantidos

| Invariante | Código | Teste |
|---|---|---|
| A IA não decide a faixa | `core/agregacao.py`, `core/ficha.py` | `test_agregacao.py`, `test_validador_e_ficha.py::test_campos_calculados_vem_do_codigo` |
| Mesma entrada, mesma faixa | `core/agregacao.py` | `test_determinismo_exaustivo` (15.625 combinações) |
| A5 ≥ 3 sem trecho literal | prompt, `motor/validador.py`, `core/ficha.py`, `servicos/fichas.py`, `tela_ficha.dart` | backend e `ficha_test.dart` |
| Desligar flag não quebra | `ConfiguracaoServidor.podeExibir` | `ficha_test.dart` (uma por flag) |
| Termo do sistema oficial ausente | — | `test_terminologia.py`, `regras_test.dart` |
| Procedência sempre visível | `BlocoProcedencia` | `ficha_test.dart` |
