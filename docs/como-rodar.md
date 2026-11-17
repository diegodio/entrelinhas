# Como rodar

## Requisitos

- Python 3.12, PostgreSQL 16 com `pgvector` e `pg_trgm`, Tesseract (`tesseract-ocr`,
  `tesseract-ocr-por`). Redis só para o modo fila.
- Flutter 3.50 (Dart 3.14).
- Ou Docker com Compose (sobe banco, Redis, MinIO, API e worker).

## Com Docker

```bash
cp .env.example .env        # preencha JWT_SEGREDO e, se quiser, as chaves
docker compose up --build
docker compose exec api python -m app.demo
```

API em http://localhost:8000 (documentação em `/docs`). **Não verificado neste ambiente**
(sem daemon Docker); os mesmos componentes foram rodados diretamente, sem contêiner.

## Sem Docker (como foi verificado)

```bash
cd backend
uv venv .venv -p 3.12 && uv pip install -p .venv -e ".[dev]"
createdb entrelinhas && createdb entrelinhas_teste
export DATABASE_URL="postgresql+psycopg://postgres@localhost/entrelinhas"
.venv/bin/alembic upgrade head
.venv/bin/python -m app.demo                       # obras fictícias + contas de demonstração
.venv/bin/uvicorn app.main:app --port 8000
```

Contas de demonstração (só fora de produção; senha `entrelinhas-demo` ou `DEMO_SENHA`):
`leitora@demo.entrelinhas`, `revisora@demo.entrelinhas`, `admin@demo.entrelinhas`.

Testes do backend (sem rede e sem chaves; usam um Postgres de teste):

```bash
TEST_DATABASE_URL="postgresql+psycopg://postgres@localhost/entrelinhas_teste" .venv/bin/python -m pytest testes
```

## App

```bash
cd app
flutter pub get
flutter gen-l10n
flutter test
flutter run -d chrome --dart-define=API_URL=http://localhost:8000
```

Build web sem CDN: `flutter build web --release --no-web-resources-cdn --dart-define=API_URL=...`.
No emulador Android a API padrão é `http://10.0.2.2:8000`.

`--dart-define` disponíveis: `API_URL`, `URL_APP` (links compartilháveis), `URL_TERMOS`,
`URL_POLITICA`, `PRODUTO_FAMILIA` (id do produto nas lojas), `GOOGLE_CLIENT_ID_WEB`.

## Integrações reais (escritas, não exercitadas aqui)

| Integração | Como ligar | O que falta verificar |
|---|---|---|
| Classificador | `PROVEDOR_LLM=anthropic` + `ANTHROPIC_API_KEY` | Uma análise real; qualidade das fichas por especialistas |
| Metadados | `FONTES_METADADOS` (Google Books pede `GOOGLE_BOOKS_API_KEY` para cota) | Neste ambiente: Google Books 429, Open Library bloqueado pela rede |
| Resenhas | `FONTES_RESENHAS=wikipedia_pt` | Bloqueado pela rede deste ambiente |
| OCR em nuvem | `MOTOR_OCR=google_vision` + chave | Chamada real |
| DINOv2 | `pip install -e ".[ml]"`, `MODELO_CAPA=dinov2`, `python ml/indexar.py` | Download dos pesos e medição |
| Stripe | `PROVEDOR_PAGAMENTO=stripe` + chaves e preços; webhook em `/v1/assinaturas/stripe/webhook` | Checkout e webhooks reais (a verificação de assinatura tem teste) |
| App Store / Google Play | variáveis `APPLE_*`, `GOOGLE_PLAY_*`; produto em `--dart-define=PRODUTO_FAMILIA` | Compra real em aparelho |
| Login social | `GOOGLE_CLIENT_IDS`, `APPLE_CLIENT_IDS`; no app, implementar `ProvedorLoginSocial` com os pacotes oficiais | Tudo no app; backend verifica ID tokens via JWKS |
| E-mail | `PROVEDOR_EMAIL=smtp` + `SMTP_*` | Envio real |
| Scanner nativo | rodar em celular Android/iOS | Fluxo ao vivo, rotação das caixas do ML Kit, desempenho |

## Scanner em aparelho

Android: `minSdk 24` (ML Kit e TFLite); permissão de câmera já declarada.
iOS: veja `app/ios/Podfile.entrelinhas.md` (iOS 15.5+ e macros do permission_handler).
Pontos a validar no aparelho: a orientação das caixas (`rodarCaixa` e o sistema de
coordenadas do ML Kit), a frequência real de análise, o recorte da foto em alta resolução e
o consumo de bateria.

## GitHub Pages (app web)

`.github/workflows/pages.yml` publica o app web a cada push na `main`, em
`https://<dono>.github.io/<repositório>/`. Antes da primeira execução:

1. Settings → Pages → Source: **GitHub Actions**.
2. Settings → Secrets and variables → Actions → **Variables**: `API_URL` com o endereço
   público da API. O Pages hospeda só o app estático; o backend (FastAPI, Postgres, Redis)
   precisa de hospedagem própria. Sem `API_URL`, o app abre, mas busca e fichas mostram
   "Sem conexão".
3. Inclua o domínio do Pages em `CORS_ORIGENS` e `URL_PUBLICA_APP` da API.

Links diretos (`/obra/...`, `/ficha/...`) funcionam porque o build copia `index.html` para
`404.html`. Verificado localmente imitando o Pages; a publicação em si não foi executada.
