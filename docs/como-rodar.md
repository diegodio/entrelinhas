# Como rodar

## Requisitos

- Python 3.12, PostgreSQL 16 com `pgvector` e `pg_trgm`. Redis só para o modo fila.
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

## Modo simples (padrão, por enquanto)

O app abre direto no leitor: aponte a câmera para o código de barras e ele mostra o nome do
livro. Não precisa de servidor.

- **Catálogo:** `app/assets/catalogo.json`, com 6 livros (ISBN de 13 dígitos sem traços,
  título e autor). **O ISBN do Murdoku foi conferido numa foto; os outros 5 vieram de memória e não foram conferidos**, porque a rede
  deste ambiente bloqueou os sites de ISBN. Confira no verso dos seus livros e corrija o
  arquivo; dá para trocar por quaisquer livros.
- **Leitura:**
  - celular: ML Kit, ao vivo;
  - web: uma foto da prévia a cada ~0,9 s, lida em Dart (`app/lib/simples/ean13.dart`);
  - também dá para escolher uma foto da galeria ou digitar o ISBN.
- **Busca do livro:** primeiro no catálogo local; se não estiver lá, na **BrasilAPI**
  (`brasilapi.com.br/api/isbn/v1/{isbn}`) e depois no **Google Books**
  (`googleapis.com/books/v1/volumes?q=isbn:{isbn}`). As duas são gratuitas, sem chave, e
  aceitam chamadas do navegador. O que vem delas fica guardado no aparelho.
- **Capas**, nesta ordem: a do catálogo (`capa`, imagem em `app/assets/capas/` ou endereço), a
  da API, a da **Open Library** pelo ISBN (`covers.openlibrary.org`, gratuita) e, por fim,
  uma capa desenhada com o título.
- **Resultado:** página do livro com capa,
  título, autor, sinopse e dados; "Livro não encontrado" quando ninguém conhece o ISBN;
  "Sem conexão" com "Tentar de novo" quando as APIs não respondem.
- **Telas:** Início (busca, atalho para escanear, vistos recentemente, livros
  cadastrados), Histórico e o botão de escanear no centro da barra inferior.

```bash
cd app
flutter run -d chrome          # modo simples
```

## App completo

```bash
cd app
flutter pub get
flutter gen-l10n
flutter test
flutter run -d chrome --dart-define=MODO_COMPLETO=true --dart-define=API_URL=http://localhost:8000
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
| Stripe | `PROVEDOR_PAGAMENTO=stripe` + chaves e preços; webhook em `/v1/assinaturas/stripe/webhook` | Checkout e webhooks reais (a verificação de assinatura tem teste) |
| App Store / Google Play | variáveis `APPLE_*`, `GOOGLE_PLAY_*`; produto em `--dart-define=PRODUTO_FAMILIA` | Compra real em aparelho |
| Login social | `GOOGLE_CLIENT_IDS`, `APPLE_CLIENT_IDS`; no app, implementar `ProvedorLoginSocial` com os pacotes oficiais | Tudo no app; backend verifica ID tokens via JWKS |
| E-mail | `PROVEDOR_EMAIL=smtp` + `SMTP_*` | Envio real |
| Scanner nativo | rodar em celular Android/iOS | Leitura ao vivo do EAN-13 pelo ML Kit, posição do contorno, desempenho |

## Scanner em aparelho

Android: `minSdk 24` (ML Kit); permissão de câmera já declarada.
iOS: veja `app/ios/Podfile.entrelinhas.md` (iOS 15.5+ e macros do permission_handler).
Pontos a validar no aparelho: a leitura ao vivo do EAN-13 (distância, ângulo, reflexo), a
posição do contorno sobre a prévia (sistema de coordenadas do ML Kit) e o consumo de bateria.

## GitHub Pages (app web)

`.github/workflows/pages.yml` publica o app web a cada push na `main`, em
`https://<dono>.github.io/<repositório>/`. Antes da primeira execução, em Settings → Pages,
escolha Source: **GitHub Actions**. O modo simples (padrão) não precisa de mais nada.

Para publicar o app completo:

1. Acrescente `--dart-define=MODO_COMPLETO=true` ao build no `pages.yml`.
2. Crie a variável `API_URL` (Settings → Secrets and variables → Actions → **Variables**)
   com o endereço público da API, que precisa de hospedagem própria.
3. Inclua o domínio do Pages em `CORS_ORIGENS` e `URL_PUBLICA_APP` da API.

A câmera na web exige HTTPS, que o Pages já oferece.

Links diretos (`/obra/...`, `/ficha/...`) funcionam porque o build copia `index.html` para
`404.html`. Verificado localmente imitando o Pages; a publicação em si não foi executada.
