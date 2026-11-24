# Decisões tomadas durante a construção

Cada linha registra uma escolha que o prompt deixou em aberto (ou que precisou ser
ajustada), com o motivo. Ordem: aproximadamente cronológica.

## Método e ficha

- **A rubrica é copiada literalmente do prompt** para `backend/app/rubrica/rubrica_v1.json`
  (extraída por script, sem edição à mão), para não haver divergência.
- **O limiar da regra dura do A5 é lido da própria rubrica** (`"condicao": "nivel >= 3"`),
  em vez de ficar fixo no código.
- **Sem número de páginas, o nível de leitura usa a média das três dimensões disponíveis.**
  A rubrica pede a média de quatro, mas `extensao` depende das páginas, que nem toda fonte
  traz. Inventar páginas seria pior; a ficha mostra `extensao: null`.
- **Tetos de confiança:** `fontes_publicas` 0,6 e `metadados_e_conhecimento_previo` 0,4
  (do prompt); acrescentei `amostragem` 0,8 e `texto_integral` 1,0. Todos ficam em
  `configuracao` (`limite.tetos_confianca`).
- **Trechos literais nunca saem quando não houve acesso ao texto**, mesmo que a flag
  `trechos_literais` seja ligada: o validador rejeita, a montagem limpa e a saída filtra
  (três camadas, como na regra do A5).
- **O servidor também filtra o que expõe:** a flag `trechos_literais` e a regra do A5 são
  aplicadas na resposta da API (e no PDF), não só na tela. As demais flags controlam a
  renderização no app.
- **Rótulos dos níveis 0 a 4:** Ausente, Leve, Moderado, Intenso, Extremo (do prompt).
  O rótulo de confiança é Baixa (< 0,45), Média (< 0,75) ou Alta.

## Cores e acessibilidade

- **O terracota da faixa 14+ e do acento foi escurecido de `#B4532A` para `#B05129`.**
  O teste de contraste automatizado mostrou que `#B4532A` ficava em 4,43:1 como texto sobre
  `papel` (a pílula de faixa nas listas). `#B05129` dá 4,6:1 e é visualmente o mesmo tom.
  As outras cores do prompt passaram e foram mantidas.
- A barra de confiança deixa o rótulo quebrar linha com texto ampliado (o teste de 200%
  achou um estouro de 19 px).

## Backend

- **Fila de tarefas:** RQ + Redis em produção (`TAREFAS_MODO=fila`); em desenvolvimento sem
  Redis, uma thread no próprio processo (`thread`); nos testes, execução síncrona.
- **Resenhas públicas:** a fonte implementada é a Wikipédia em português (CC BY-SA, com a
  URL registrada em `fontes_da_ficha`). Não encontrei API de resenhas de livros em
  português cujos termos permitam o uso; a interface `FonteDeResenhas` aceita outras.
- **Busca externa:** resultados de Google Books/Open Library com ISBN entram no catálogo
  (sem ficha) para ganhar um id estável; resultados sem ISBN são descartados.
- **Plano gratuito e listas:** o prompt diz que o Família tem "listas ilimitadas"; o
  gratuito ficou com 3 listas pessoais (as duas padrão contam), configurável em
  `limite.listas_plano_gratuito`.
- **Exportar PDF** exige plano pago (o prompt lista PDF no Família); responde
  `402 plano_necessario` no gratuito.
- **Importação em lote e relatórios** exigem o plano Escola ativo na organização; criar a
  organização e as listas não exige.
- **Contestação:** a ficha fica "em revisão" até que todas as contestações abertas sejam
  respondidas. Publicar uma revisão não fecha contestações sozinho.
- **Histórico de versões guarda o papel do revisor**, não o nome (como pede o prompt); o id
  do autor fica na tabela para auditoria interna.
- **Dados de demonstração sem ISBN:** qualquer ISBN inventado poderia coincidir com o de
  um livro real e esconder a obra verdadeira numa consulta.
- **Login social:** o backend verifica ID tokens do Google e da Apple pelas chaves públicas
  (JWKS). Sem client IDs configurados, responde `503 login_social_indisponivel`.
- **Recuperação de senha** responde igual exista ou não a conta (não revela e-mails
  cadastrados). Tokens de renovação são rotacionados; reusar um token já trocado revoga
  todos os tokens da pessoa.
- **Adaptador Anthropic:** SDK oficial `anthropic`, modelo padrão `claude-opus-5-5`, saída
  estruturada (`output_config.format` com JSON Schema), esforço `medium` e o fallback do
  servidor para recusas (`fallbacks: "default"`, desligável com `LLM_FALLBACKS=false`). O
  validador continua sendo a autoridade sobre a saída.
- **OpenAI e Google** exigem `MODELO_LLM` explícito: não escrevi identificadores de modelo
  desses provedores de memória.

## Modo simples (padrão por enquanto)

- **Pedido do usuário:** ler o código de barras e mostrar só o nome do livro, com um catálogo
  de uns 5 títulos. Foi escolhido catálogo fixo no app (sem servidor) e o resto do app
  escondido, não apagado: `main.dart` abre `AppSimples` a menos que
  `--dart-define=MODO_COMPLETO=true`.
- **Leitor de EAN-13 próprio em Dart** (`app/lib/simples/ean13.dart`) para a web, já que o
  ML Kit não roda no navegador, o pacote `zxing2` só lê QR Code e a API `BarcodeDetector`
  não existe no Safari nem no Chrome de Windows/Linux. Aceita só leituras com dígito
  verificador correto e escolhe por votação entre várias linhas e colunas.
- **ISBNs do catálogo não conferidos:** a rede do ambiente bloqueou os sites de ISBN; os
  números vieram de memória (todos com dígito verificador válido).

## Reconhecimento

- **Só código de barras, por enquanto** (pedido do usuário). Saíram o detector TFLite, o OCR
  (Tesseract/Google Vision), o modelo de capa (histograma/DINOv2), a fusão de sinais, a
  pasta `ml/` e a opção de contribuir com fotos. O esquema do banco ficou como estava
  (tabelas `capas` e `amostras_reconhecimento` sem uso) para não exigir migração destrutiva.
- **Código de barras no aparelho:** ML Kit (Android/iOS), só EAN-13. Com ISBN de livro, o app
  consulta direto `GET /v1/obras/isbn/{isbn}`, sem enviar foto.
- **Web:** sem leitura ao vivo; captura manual e o servidor lê o código na foto (zxing-cpp).
- **ISBN fora do catálogo** abre "Cadastrar obra" já preenchido, em vez de uma tela de erro.

## App

- **Material desacoplado:** no Flutter 3.50 o Material vem do pacote `material_ui`
  (`package:material_ui/material_ui.dart`); `package:flutter/material.dart` está obsoleto.
- **Riverpod 3:** nova tentativa automática desligada no `ProviderScope` (as telas oferecem
  "Tentar de novo").
- **Modelos com freezed + json_serializable**, `field_rename: snake`.
- **Cache local com shared_preferences** (histórico, fichas abertas, configuração);
  tokens com flutter_secure_storage.
- **Login social no app:** a interface `ProvedorLoginSocial` existe, mas a implementação
  padrão declara "nenhum provedor"; os pacotes `google_sign_in`/`sign_in_with_apple` não
  foram adicionados por não haver credenciais para exercitá-los. Os botões não aparecem.
- **Compras nas lojas** com `in_app_purchase`; o produto vem de `--dart-define=PRODUTO_FAMILIA`.
  Sem esse valor, o app usa o checkout web.
- **CanvasKit empacotado** (`--no-web-resources-cdn`): o app web não depende de CDN.
- **Leitor (perfil) guarda só o ano de nascimento**; a idade é "anos completados no ano
  corrente" (pode ficar 1 ano acima antes do aniversário). É o preço de não guardar a data.
