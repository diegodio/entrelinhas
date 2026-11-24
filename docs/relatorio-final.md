# Relatório final

Estado do projeto ao fim da construção a partir de `docs/prompt-app-flutter.md`.

## 1. Funciona e foi verificado

**Testes automatizados:** 167 no backend e 85 no app, todos passando. A análise estática
não acusa nenhum aviso (`ruff check` e `flutter analyze --fatal-infos`).

**Método**
- Rubrica v1.0 copiada sem alteração; agregação como função pura.
- O teste de determinismo percorre as 15.625 combinações de níveis.
- Também cobertos por teste: o agravante (com teto), o desempate do eixo determinante, as três recomendações e o arredondamento meio para cima.
- A faixa nunca vem da IA: a ficha sempre recalcula, mesmo que o modelo mande uma faixa.

**Regra dura do A5** (nível 3 ou mais, sem trecho literal), testada em cinco pontos:
- no prompt;
- no validador;
- na montagem da ficha;
- na resposta da API e no PDF;
- na tela.

O teste liga a flag `trechos_literais` e planta um trecho no banco: ele não sai.

**API (49 rotas)**
- busca local e externa;
- ficha, resumo e página pública;
- limite mensal e reabertura sem custo;
- contas com renovação e rotação de tokens, e recuperação de senha;
- leitores, listas, contestação, PDF, organizações, importação de CSV, relatórios em JSON, CSV e PDF;
- revisão editorial com prévia e publicação, e resposta a contestação com e-mail;
- análise de texto integral pelo administrador.

Tudo testado contra Postgres real com pgvector.

**Pipeline de análise**, testado com o provedor falso:
- coleta, fonte da análise e tetos de confiança;
- correção automática com a lista de erros (até duas vezes);
- falha sem ficha parcial;
- análise por blocos com consolidação;
- parâmetros enviados ao SDK da Anthropic (simulado) e tratamento de recusa.

**Código de barras no servidor** (escopo atual: só código de barras; detalhes em `docs/reconhecimento.md`)
- Leitura de EAN-13: em pé, girado, pequeno numa foto grande e "não é livro".
- Rota com identificado, ISBN fora do catálogo, não é livro, sem código e ISBN vindo do aparelho.

**App web percorrido no navegador**, contra a API real:
- Boas-vindas, Início, Busca, Ficha (resumo e completa), login, Perfil, Listas, Metodologia e Planos.
- Fila de revisão e edição de ficha.
- Acervo, tabela da lista e relatório.
- O trilho lateral aparece em tela larga.
- **Scanner web de ponta a ponta:** a câmera falsa do Chromium mostrava o verso de um livro com código de barras; a captura manual leu o ISBN no servidor e abriu a ficha de "O Jardim de Vidro".

**Testes do app**
- Imagens de referência: ficha completa, ficha em duas colunas e limite atingido.
- Cada flag desligada, uma por teste.
- Texto ampliado a 200%.
- Contraste de 4,5:1 em todos os pares de cores usados.
- Máquina de estados do scanner.
- Repositórios: cache sem rede, histórico e renovação de token.
- Ausência do termo do sistema oficial em todos os textos.

## 2. Escrito, mas não verificado (e por quê)

| Parte | Motivo |
|---|---|
| Scanner nativo (leitura ao vivo do EAN-13 pelo ML Kit, posição do contorno) | Não há aparelho nem SDK Android ou Xcode aqui |
| Builds Android e iOS | Sem SDK Android nem macOS |
| `docker compose` e Dockerfile | Sem daemon Docker neste ambiente |
| Classificação com LLM real (Anthropic, OpenAI, Google) | Sem chaves |
| Google Books, Open Library e Wikipédia ao vivo | 429 por cota e bloqueio de rede deste ambiente |
| Stripe (checkout e webhook reais), App Store, Google Play | Sem credenciais. A verificação de assinatura do webhook tem teste. |
| Login com Google e Apple | O backend verifica ID tokens via JWKS, mas não foi exercitado. No app só existe a interface; os pacotes não foram adicionados. |
| Envio de e-mail por SMTP | Sem credenciais |

## 3. O que falta

- **Reconhecimento pela capa:** retirado por enquanto; ver `docs/reconhecimento.md` para voltar.
- **Login social no app:** implementar `ProvedorLoginSocial` com `google_sign_in` e `sign_in_with_apple`.
- **Tema escuro.** Os tokens já estão prontos para recebê-lo.
- **Validação editorial do método:** especialistas em educação, biblioteconomia e desenvolvimento infantojuvenil, como recomendaram os avaliadores do Centelha.
- **Escala da importação:** o acompanhamento no app desiste depois de 2 minutos, e importações muito grandes podem precisar de paginação do resultado.
- **Navegação por teclado na web:** os componentes usam elementos semânticos, mas o percurso por teclado não foi testado.
- **Revisão jurídica** dos rascunhos de política e termos (`docs/rascunhos/`).

## 4. Decisões que tomei por conta própria

Lista completa em `docs/decisoes.md`. As mais importantes:

- **Cor da faixa 14+:** o terracota passou de `#B4532A` para `#B05129`, porque o teste de contraste reprovou a cor original como texto.
- **Só código de barras:** ISBN lido no celular consulta direto, sem enviar foto; ISBN fora do catálogo abre "Cadastrar obra" já preenchido.
- **Fonte de resenhas:** Wikipédia em português.
- **Limites não definidos no prompt:** 3 listas no plano gratuito; PDF só nos planos pagos; importação e relatório só no plano Escola.
- **Obras de demonstração sem ISBN,** para não colidir com ISBNs de livros reais.

## 5. Repositório

Desenvolvido no branch `claude/cool-edison-lachef` e enviado à `main` pelo PR #1, com a CI
(backend e app) passando. O app web é publicado no GitHub Pages pelo workflow `pages.yml`
(veja "GitHub Pages" em `docs/como-rodar.md`).
