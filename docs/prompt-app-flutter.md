# Prompt: construir o Entrelinhas (app Flutter, backend e modelo de reconhecimento de capas)

Você vai construir, do zero e neste repositório, o **Entrelinhas**: um serviço brasileiro de Orientação de Leitura para livros. A pessoa aponta a câmera para um livro (capa ou código de barras) ou busca por título, autor ou ISBN, e recebe uma ficha com faixa etária recomendada, alertas de conteúdo, perfil de leitura e valor formativo.

Este documento contém tudo o que foi decidido até aqui. Leia-o inteiro antes de escrever código. Onde ele não decide algo, decida você, registre a escolha em `docs/decisoes.md` com uma linha de justificativa e siga em frente; só pare para perguntar se a dúvida mudar a arquitetura ou envolver dinheiro, dados pessoais ou credenciais.

## 1. Contexto

**O problema.** O Brasil tem sinalização etária obrigatória para cinema, TV, games e apps, mas não para livros. Com o BookTok, literatura juvenil e romance adulto explícito circulam sob a mesma estética. Pais, escolas e bibliotecas não têm uma fonte em português que diga o que cada obra contém.

**Quem usa.**
- Pais e responsáveis, muitas vezes dentro de uma livraria, decidindo se compram um livro para um filho. Estão em pé, com o livro na mão e pouco tempo. Por isso o caminho principal é a câmera, e a resposta precisa aparecer em poucos segundos.
- Leitores jovens e adultos que querem saber o que há no livro antes de ler.
- Escolas, redes de ensino e bibliotecas, que usam o navegador para avaliar acervos inteiros.

**De onde vem o projeto.** A ideia foi aprovada na Fase 1 do Programa Centelha 3 (PR). Os avaliadores apontaram quatro fragilidades, e o produto precisa responder a cada uma:
1. Critérios de classificação pouco definidos. Resposta: a rubrica da seção 3, pública no app.
2. Risco de erro da IA em temas sensíveis. Resposta: a IA só pontua eixos; a faixa etária sai de código determinístico; há revisão humana e contestação.
3. Direitos autorais e acesso ao texto das obras. Resposta: a análise padrão não usa o texto integral (seção 4.4).
4. Credibilidade junto a escolas e famílias. Resposta: procedência e confiança visíveis em toda ficha, metodologia pública, selo de revisão humana.

Já existe um protótipo em Python (Flet) com a rubrica e a regra de agregação. Você não tem acesso a esse código, mas as regras dele estão reproduzidas aqui e devem ser mantidas.

## 2. Princípios que valem para o produto inteiro

Estes princípios existem para proteger a confiança no produto. Cada um vem com o motivo, para que você saiba aplicá-lo em casos que este documento não previu.

1. **A IA nunca decide a faixa etária.** O modelo de linguagem pontua níveis de 0 a 4 em seis eixos e escreve justificativas. A faixa é calculada por uma função pura, testada, sem IA. Motivo: a mesma entrada precisa dar sempre a mesma faixa, e qualquer pessoa precisa poder auditar por que um livro recebeu 14+.
2. **Nunca use o termo "classificação indicativa".** Ele pertence ao sistema oficial do Ministério da Justiça (ClassInd), que não cobre livros. Use "Orientação de Leitura". Toda ficha e o rodapé do app exibem: "Orientação editorial independente, sem vínculo com o Ministério da Justiça ou com o sistema ClassInd." Pelo mesmo motivo, os selos de faixa não imitam as cores nem o formato dos selos do ClassInd.
3. **Tom descritivo, nunca moral.** As fichas descrevem o que há na obra. Não dizem que o conteúdo é impróprio, problemático ou lamentável. O produto informa; quem decide é a família ou a escola. Ele não censura nem recomenda proibir.
4. **Procedência sempre à vista.** Toda ficha mostra de que material a análise partiu, a confiança e se foi revisada por uma pessoa. Uma estimativa nunca pode se passar por análise.
5. **Regra dura do eixo A5.** Uma ficha com o eixo A5 (autolesão, suicídio, transtorno alimentar) em nível 3 ou 4 nunca exibe nem armazena trecho literal nem qualquer detalhe de método, conduta, dose ou meio. Vale no prompt do classificador, no validador da saída e na tela, e nenhuma configuração a desliga.
6. **Textos e tema em um só lugar.** Nenhuma string visível e nenhuma cor ficam espalhadas pelo código. No app, os textos vivem nos arquivos de localização e as cores e fontes em um único arquivo de tema. Motivo: uma pessoa sem conhecimento técnico deve conseguir reescrever o produto editando esses arquivos.
7. **Gerar e guardar tudo, mostrar o que a configuração permitir.** Blocos da ficha são ligados e desligados por flags vindas do servidor (seção 4.8). Desligar uma flag recompõe a tela sem quebrar e não apaga dado.
8. **Privacidade de crianças.** O app guarda o mínimo sobre os filhos (seção 4.9) e não cria contas para menores.

## 3. O método: a Rubrica Entrelinhas v1.0

A rubrica é dado, não código. Salve o JSON abaixo, sem alterações, em `backend/app/rubrica/rubrica_v1.json`. O backend lê a faixa, os descritores e os vocabulários deste arquivo; o app recebe o que precisa pela API.

```json
{
  "versao": "1.0",
  "nome": "Rubrica Entrelinhas",
  "faixas_ordenadas": ["Livre", "10+", "12+", "14+", "16+", "18+"],
  "camada_a": {
    "descricao": "Eixos de risco. Únicos determinantes da faixa etária. Nível 0-4 por eixo.",
    "eixos": [
      {
        "id": "A1",
        "nome": "Violência física",
        "descritores": {
          "0": "Ausente. Sem conflito físico ou ameaça descrita.",
          "1": "Conflito verbal, ameaça implícita, violência fora de cena (relatada, não descrita).",
          "2": "Agressão ou briga descrita sem detalhe gráfico; consequências mostradas (ferimento), sem foco no ato.",
          "3": "Violência com detalhamento sensorial (movimento, dor, sangue); tortura, guerra ou abuso físico prolongado.",
          "4": "Violência gráfica extrema: gore, mutilação detalhada, crueldade explorada com riqueza de detalhe."
        },
        "mapeamento_faixa": { "0": "Livre", "1": "10+", "2": "12+", "3": "14+", "4": "16+" }
      },
      {
        "id": "A2",
        "nome": "Sexo e intimidade",
        "descritores": {
          "0": "Sem conteúdo além de afeto e beijo.",
          "1": "Desejo e atração referidos; cena corta antes do ato (fade to black).",
          "2": "Ato indicado por elipse ou metáfora, sem descrição de corpo ou movimento.",
          "3": "Cena descrita com clareza, incluindo nudez e contato físico, sem explicitação anatômica.",
          "4": "Descrição gráfica e detalhada do ato, sem eufemismo, com foco sensorial extenso."
        },
        "mapeamento_faixa": { "0": "Livre", "1": "10+", "2": "12+", "3": "16+", "4": "18+" }
      },
      {
        "id": "A3",
        "nome": "Linguagem ofensiva",
        "descritores": {
          "0": "Sem palavrão ou termo ofensivo.",
          "1": "Um ou dois palavrões leves isolados na obra inteira.",
          "2": "Palavrões recorrentes, sem linguagem discriminatória.",
          "3": "Linguagem chula frequente e/ou termos discriminatórios proferidos por personagens.",
          "4": "Linguagem de ódio estrutural na obra, sem contraponto narrativo."
        },
        "mapeamento_faixa": { "0": "Livre", "1": "10+", "2": "12+", "3": "14+", "4": "16+" }
      },
      {
        "id": "A4",
        "nome": "Substâncias",
        "descritores": {
          "0": "Sem menção.",
          "1": "Substância citada sem cena de uso ('ele bebia').",
          "2": "Consumo social retratado (festa, bar), sem consequência grave.",
          "3": "Consumo abusivo descrito, com consequências mostradas (dependência, overdose).",
          "4": "Dependência como eixo estrutural, com cenas explícitas de uso e degradação, ou descrição com precisão instrucional (dose, preparo, obtenção)."
        },
        "mapeamento_faixa": { "0": "Livre", "1": "10+", "2": "12+", "3": "14+", "4": "16+" }
      },
      {
        "id": "A5",
        "nome": "Risco à integridade e comportamento imitável",
        "escopo": "Autolesão, suicídio, transtorno alimentar e comportamento de risco replicável.",
        "descritores": {
          "0": "Ausente.",
          "1": "Tema citado sem aprofundamento ('tinha depressão').",
          "2": "Sintomas e impacto emocional mostrados; sofrimento psíquico retratado sem método descrito.",
          "3": "Cena explícita de autolesão, ideação suicida detalhada ou comportamento alimentar restritivo com descrição de conduta.",
          "4": "Método descrito com detalhe suficiente para ser reproduzido, ou autolesão apresentada como solução eficaz, ou tema estrutural com descrição gráfica recorrente."
        },
        "mapeamento_faixa": { "0": "Livre", "1": "12+", "2": "14+", "3": "16+", "4": "18+" },
        "regra_dura": {
          "condicao": "nivel >= 3",
          "efeito": "proibir_trecho_literal",
          "descricao": "Ficha com A5 >= 3 nunca reproduz trecho literal do método, independentemente de qualquer flag de visibilidade. Somente paráfrase neutra, sem detalhe de conduta."
        }
      },
      {
        "id": "A6",
        "nome": "Abuso, trauma e opressão",
        "escopo": "Violência sexual, abuso doméstico e infantil, exploração, tortura psicológica, discriminação sofrida por personagem.",
        "descritores": {
          "0": "Ausente.",
          "1": "Mencionado como passado ou contexto, sem cena.",
          "2": "Situação de abuso retratada em cena, sem detalhamento do ato.",
          "3": "Abuso descrito com detalhe, ou trauma retratado de forma prolongada e central à experiência do personagem.",
          "4": "Violência sexual ou abuso descrito de forma gráfica e extensa."
        },
        "mapeamento_faixa": { "0": "Livre", "1": "10+", "2": "14+", "3": "16+", "4": "18+" }
      }
    ]
  },
  "agregacao": {
    "regra": "max",
    "descricao": "Faixa base = maior faixa entre os seis eixos, pela tabela de mapeamento por eixo. Nunca média.",
    "agravante_acumulo": {
      "condicao_faixa_minima": "16+",
      "quantidade_minima_eixos": 2,
      "efeito_degraus": 1,
      "aplica_uma_unica_vez": true,
      "teto": "18+",
      "descricao": "Se dois ou mais eixos resultarem em faixa 16+ ou superior, a faixa final sobe um degrau. Aplica-se uma única vez."
    },
    "camada_b_altera_faixa": false,
    "camada_c_altera_faixa": false,
    "valor_formativo_altera_faixa": false
  },
  "recomendacao_contextual": {
    "conteudo_adulto": {
      "condicao": "qualquer eixo em nível 4",
      "descricao": "Conteúdo adulto. Não recomendada antes da faixa indicada."
    },
    "com_mediacao": {
      "condicao": "algum eixo em nível 3, ou dois ou mais eixos em nível >= 2",
      "descricao": "Recomendada com mediação de adulto a partir da faixa indicada."
    },
    "independente": {
      "condicao": "caso contrário",
      "descricao": "Leitura independente a partir da faixa indicada."
    }
  },
  "camada_b": {
    "descricao": "Alertas de conteúdo. Binários, vocabulário fechado, não alteram a faixa.",
    "vocabulario": [
      "morte_de_personagem_principal", "luto", "morte_ou_maus_tratos_de_animal",
      "doenca_terminal", "bullying", "violencia_escolar", "gravidez_indesejada",
      "aborto", "violencia_sexual_fora_de_cena", "sequestro_ou_carcere",
      "automutilacao", "suicidio", "transtorno_alimentar", "dependencia_quimica",
      "relacao_abusiva_romantizada", "diferenca_de_poder_em_relacao_afetiva",
      "discriminacao_sem_critica_narrativa", "conteudo_religioso_sensivel",
      "final_tragico", "acidente_grave", "arma_de_fogo"
    ],
    "flags_com_justificativa_obrigatoria": [
      "relacao_abusiva_romantizada", "discriminacao_sem_critica_narrativa"
    ]
  },
  "camada_c": {
    "descricao": "Perfil de leitura. Mede exigência, não risco. Nunca altera a faixa.",
    "dimensoes": {
      "vocabulario": { "1": "Cotidiano simples.", "3": "Culto padrão.", "5": "Erudito, técnico ou arcaico." },
      "estrutura_narrativa": { "1": "Linear, narrador único.", "3": "Múltiplos pontos de vista ou saltos temporais.", "5": "Fragmentada, metaficcional, narrador não confiável." },
      "densidade_tematica": { "1": "Conflito explícito e resolvido.", "3": "Subtexto relevante, ambiguidade moral pontual.", "5": "Obra filosófica ou alegórica, exige leitura interpretativa." },
      "extensao": {
        "derivada_de": "paginas",
        "limiares": [
          { "ate_paginas": 149, "nivel": 1 },
          { "ate_paginas": 300, "nivel": 2 },
          { "ate_paginas": 500, "nivel": 3 },
          { "ate_paginas": 800, "nivel": 4 },
          { "ate_paginas": null, "nivel": 5 }
        ]
      }
    },
    "nivel_leitura": {
      "calculo": "média das quatro dimensões, arredondada (meio para cima)",
      "rotulos": { "1": "Iniciante", "2": "Em formação", "3": "Intermediário", "4": "Avançado", "5": "Especializado" }
    },
    "exigencia_repertorio": { "max_itens": 3 },
    "valor_formativo": {
      "niveis": ["Baixo", "Médio", "Alto"],
      "marcadores": ["empatia", "repertorio_cultural", "pensamento_critico", "qualidade_estetica", "conhecimento_historico", "desenvolvimento_moral"],
      "max_marcadores": 3
    }
  },
  "evidencia": {
    "nivel_minimo_para_exigir": 2,
    "formatos": ["parafrase", "trecho_literal"],
    "parafrase_sempre_gerada": true,
    "limite_palavras_trecho_padrao": 40,
    "max_trechos_por_ficha_padrao": 6
  },
  "procedencia": {
    "fontes": {
      "texto_integral": "Obra analisada por inteiro. Confiança alta.",
      "amostragem": "Trechos amostrados. Confiança média; a ficha exibe isso.",
      "fontes_publicas": "Sinopse, metadados e resenhas públicas. Sem acesso ao texto. Confiança limitada; a ficha exibe aviso de estimativa.",
      "metadados_e_conhecimento_previo": "Sem acesso ao texto nem a resenhas. Confiança baixa; a ficha exibe aviso explícito de estimativa."
    }
  }
}
```

### 3.1 Regra de agregação (função pura, com testes obrigatórios)

Implemente em `backend/app/core/agregacao.py`, sem IA, sem banco e sem rede. Se esta regra quebrar, o produto inteiro mente, então ela é o módulo com a cobertura de testes mais rigorosa.

Entrada: `{"A1": 0-4, ..., "A6": 0-4}`. Rejeite com erro claro qualquer entrada sem exatamente os seis eixos ou com nível fora de 0 a 4.

1. Converta o nível de cada eixo em faixa pela tabela `mapeamento_faixa` do próprio eixo. O mapeamento é diferente por eixo (A2 em nível 3 dá 16+, A1 em nível 3 dá 14+).
2. Faixa base = a maior faixa entre os seis eixos. Nunca média.
3. Agravante de acúmulo: se dois ou mais eixos resultarem em 16+ ou acima, a faixa final sobe um degrau, uma única vez, com teto em 18+.
4. Eixo determinante = o de maior faixa; em empate, o de maior nível; persistindo o empate, o primeiro na ordem A1 a A6.
5. Recomendação contextual: `conteudo_adulto` se algum eixo está em nível 4; senão `com_mediacao` se algum eixo está em nível 3 ou se dois ou mais eixos estão em nível 2 ou acima; senão `independente`.

Saída: `faixa_final`, `faixa_base`, `agravante_acumulo_aplicado`, `eixo_determinante`, `faixas_por_eixo`, `recomendacao_contextual`.

Camada C: a dimensão `extensao` vem do número de páginas pelos limiares da rubrica. O nível de leitura é a média das quatro dimensões arredondada com meio para cima (use `int(media + 0.5)`; o `round()` do Python arredonda meio para o par e daria resultado errado).

Testes mínimos: cada linha de cada tabela de mapeamento; o agravante com zero, um, dois e seis eixos em 16+; o teto de 18+; o desempate do eixo determinante; as três recomendações; entradas inválidas; o arredondamento em x,5; e um teste de determinismo (mesma entrada, mesma saída).

### 3.2 Textos derivados da rubrica

- Recomendação `independente`: "Leitura independente a partir de {faixa}." Quando a faixa é Livre: "Leitura livre, para todas as idades."
- `com_mediacao`: "Recomendada com mediação de adulto a partir de {faixa}."
- `conteudo_adulto`: "Conteúdo adulto. Não recomendada antes de {faixa}."
- Em frases, "14+" é escrito "14 anos". No selo, aparece "14+".
- Nomes curtos dos eixos na interface: A1 "Violência física", A2 "Sexo e intimidade", A3 "Linguagem ofensiva", A4 "Substâncias", A5 "Risco à integridade", A6 "Abuso, trauma e opressão".
- Rótulos dos alertas da Camada B: a chave com espaços no lugar de sublinhados e inicial maiúscula, com acentuação correta (por exemplo `doenca_terminal` vira "Doença terminal", `sequestro_ou_carcere` vira "Sequestro ou cárcere", `violencia_sexual_fora_de_cena` vira "Violência sexual fora de cena"). Escreva os 21 rótulos à mão no arquivo de textos.

## 4. Backend

### 4.1 Stack

Python com FastAPI, PostgreSQL com as extensões `pgvector` (busca de capas por similaridade) e `pg_trgm` (busca difusa por título), SQLAlchemy com Alembic, Pydantic para os contratos, uma fila de tarefas assíncronas com Redis para análises e importações em lote, e armazenamento de objetos compatível com S3 para imagens (MinIO no ambiente local). Tudo sobe com `docker compose up`. Use as versões estáveis atuais de cada biblioteca e confira a documentação antes de usar uma API da qual você não tenha certeza.

### 4.2 Modelo de dados (ponto de partida; ajuste se encontrar razão)

- `usuarios`: e-mail, hash de senha, nome, provedores sociais, papel global (`usuario`, `revisor`, `admin`), consentimentos com data.
- `perfis_leitor`: pertence a um usuário; apelido, ano de nascimento, ícone. É o "filho" do responsável.
- `organizacoes` e `membros_organizacao`: escola ou biblioteca; papéis `gestor`, `bibliotecario`, `professor`.
- `obras`: título, subtítulo, autores, sinopse, idioma, gênero, páginas, fonte dos metadados.
- `edicoes`: ISBN-13 (único), ISBN-10, editora, ano, URL da capa, ligação com `obras`. Uma obra tem várias edições e uma única ficha.
- `capas`: edição, URL de origem, vetor de embedding (`vector`), nome e versão do modelo que gerou o vetor.
- `fichas`: obra, JSON completo da ficha (`jsonb`), colunas indexadas (`faixa_final`, `fonte_da_analise`, `confianca`, `status`, `revisada_por_humano`), versão da rubrica, versão da ficha.
- `fichas_versoes`: histórico imutável de cada versão, com autor da mudança e motivo.
- `fontes_da_ficha`: URLs e tipo de cada material usado na análise (sinopse da editora, resenha, metadado).
- `consultas`: usuário, obra, data. Base do limite mensal.
- `listas` e `itens_lista`: listas pessoais e de organização (acervo, turma).
- `contestacoes`: usuário, ficha, eixo ou campo contestado, texto, status, resposta do revisor.
- `assinaturas`: plano, origem (loja ou Stripe), validade, estado.
- `tarefas`: análises e importações em lote, com estado e erro.
- `amostras_reconhecimento`: imagem enviada, resultado e correção do usuário, gravadas somente com consentimento explícito (seção 4.9).
- `configuracao`: flags e limites (seção 4.8).

### 4.3 Contrato da ficha

A ficha é um único JSON, igual para gerar, armazenar e exibir. Campos:

```json
{
  "obra_id": "uuid",
  "versao_rubrica": "1.0",
  "versao_ficha": 3,
  "status": "publicada | em_analise | em_revisao | indisponivel",
  "faixa_final": "14+",
  "faixa_base": "14+",
  "agravante_acumulo_aplicado": false,
  "eixo_determinante": "A1",
  "recomendacao_contextual": "com_mediacao",
  "texto_recomendacao": "Recomendada com mediação de adulto a partir de 14 anos.",
  "camada_a": {
    "A1": { "nivel": 3, "faixa": "14+", "justificativa": "..." }
  },
  "evidencias": [
    { "eixo": "A1", "parafrase": "...", "trecho_literal": null, "fonte": "sinopse da editora", "localizacao": null }
  ],
  "camada_b": { "flags": ["luto"], "justificativas": {} },
  "camada_c": {
    "vocabulario": 3, "estrutura_narrativa": 2, "densidade_tematica": 3, "extensao": 3,
    "nivel_leitura": 3, "rotulo_nivel_leitura": "Intermediário",
    "exigencia_repertorio": ["..."],
    "valor_formativo": { "nivel": "Alto", "marcadores": ["empatia"], "justificativa": "..." }
  },
  "procedencia": {
    "fonte_da_analise": "fontes_publicas",
    "confianca": 0.55,
    "modelo": "provedor/modelo usado",
    "fontes": [{ "tipo": "sinopse", "url": "..." }],
    "revisada_por_humano": false,
    "revisada_em": null
  },
  "atualizada_em": "ISO-8601"
}
```

`camada_a` sempre traz os seis eixos. Os campos calculados (`faixa_*`, `eixo_determinante`, `recomendacao_contextual`, `extensao`, `nivel_leitura`) são sempre produzidos pelo código da seção 3.1, nunca copiados da resposta do modelo.

### 4.4 Pipeline de análise

Decisão de produto: a análise padrão **não usa o texto integral das obras**, por causa dos direitos autorais. Ela parte de material público.

1. **Coleta.** Metadados e sinopse em cascata: base própria, depois Google Books, depois Open Library. Resenhas públicas entram apenas por APIs e fontes cujos termos de uso permitam; registre cada URL usada em `fontes_da_ficha`. A camada de rede é injetável para que os testes rodem sem internet.
2. **Fonte da análise.** Com sinopse e ao menos uma resenha, a fonte é `fontes_publicas` e a confiança tem teto de 0,6. Só com metadados, a fonte é `metadados_e_conhecimento_previo` e o teto é 0,4. Os tetos ficam em `configuracao`. As fontes `texto_integral` e `amostragem` existem no contrato para obras em domínio público ou com autorização da editora, carregadas por um administrador; implemente o caminho no backend, sem tela de envio para o usuário comum.
3. **Classificação.** Um modelo de linguagem recebe a rubrica, os metadados e o material coletado, e devolve JSON estrito no formato abaixo. O provedor é configurável (seção 4.7).
4. **Validação.** Valide a saída antes de usar. Se for inválida, refaça a chamada anexando a lista de erros, no máximo duas vezes; persistindo, a tarefa falha e a obra fica como "sem ficha", nunca com ficha parcial.
5. **Cálculo.** Aplique a seção 3.1 e monte a ficha.
6. **Publicação.** A ficha é publicada com `revisada_por_humano: false` e entra na fila de revisão editorial (seção 4.10).

A análise roda como tarefa assíncrona. Enquanto roda, a obra tem status `em_analise` e o app mostra esse estado e atualiza sozinho.

**Regras do prompt do classificador.** Escreva o prompt em `backend/app/motor/prompt.py`, montado a partir do arquivo da rubrica (descritores, vocabulário e marcadores vêm do JSON, não ficam duplicados no texto). Ele precisa transmitir:

- Responder somente com um objeto JSON válido, sem markdown e sem preâmbulo.
- O modelo não decide faixa etária e não menciona idades; ele pontua níveis de 0 a 4 por eixo.
- Tom descritivo e neutro; nenhuma avaliação moral.
- Na dúvida entre dois níveis, escolher o menor e registrar a dúvida na justificativa.
- Todo eixo acima de 0 exige justificativa de uma a duas frases; todo eixo em 2 ou mais exige ao menos uma evidência.
- Alertas da Camada B saem exclusivamente do vocabulário fechado. Se nenhum rótulo serve, o modelo não cria um novo; registra em `observacoes`.
- `relacao_abusiva_romantizada` e `discriminacao_sem_critica_narrativa` exigem justificativa.
- Regra dura do A5: em nível 3 ou 4, `trecho_literal` é nulo e a paráfrase não traz detalhe de conduta, método, dose ou meio.
- Sem acesso ao texto, `trecho_literal` é sempre nulo, a localização da cena é nula e nada é inventado; cada evidência diz de que fonte veio.
- A dimensão `extensao` não é tarefa do modelo.
- Declarar `confianca` de 0 a 1 com honestidade.

Formato de saída do modelo:

```json
{
  "camada_a": { "A1": { "nivel": 0, "justificativa": "" }, "A2": {}, "A3": {}, "A4": {}, "A5": {}, "A6": {} },
  "evidencias": [{ "eixo": "A1", "parafrase": "", "trecho_literal": null, "fonte": "", "por_que_selecionado": "" }],
  "camada_b": { "flags": [], "justificativas": {} },
  "camada_c": {
    "vocabulario": 1, "estrutura_narrativa": 1, "densidade_tematica": 1,
    "exigencia_repertorio": [],
    "valor_formativo": { "nivel": "Baixo", "marcadores": [], "justificativa": "" }
  },
  "confianca": 0.0,
  "observacoes": ""
}
```

O validador confere: seis eixos com nível inteiro de 0 a 4; justificativa presente quando o nível é maior que 0; evidência presente quando o nível é 2 ou mais; flags dentro do vocabulário; justificativas obrigatórias; regra dura do A5; dimensões da Camada C entre 1 e 5; até três itens de repertório e três marcadores; confiança entre 0 e 1 e abaixo do teto da fonte.

### 4.5 Reconhecimento de livro por imagem

O fluxo decidido: o app localiza na imagem da câmera a capa ou o código de barras, recorta e envia o recorte ao servidor. O servidor faz a leitura do código de barras, o OCR e o reconhecimento da capa, e responde qual é o livro.

`POST /v1/reconhecimento` recebe a imagem (JPEG, maior lado em torno de 1024 px), uma dica opcional do tipo de recorte (`capa`, `codigo_de_barras`, `desconhecido`) e, opcionalmente, um ISBN já lido no aparelho.

No servidor, três sinais rodam em paralelo sobre a imagem:

1. **Código de barras.** Decodifique com uma biblioteca como `zxing-cpp`, tentando variações da imagem (tons de cinza, contraste, rotações) quando a primeira leitura falhar. Só aceite EAN-13 com prefixo 978 ou 979 e dígito verificador correto. Um código válido que não é de livro gera a resposta `nao_e_livro`.
2. **OCR.** Extraia o texto da capa e use as linhas maiores como candidatas a título e autor. Busque no catálogo por similaridade de trigramas. O motor de OCR fica atrás de uma interface (seção 4.7).
3. **Embedding da capa.** Gere o vetor da imagem com o modelo da seção 5 e busque os vizinhos mais próximos em `capas` com `pgvector`.

Como o recorte do aparelho pode falhar ou nem existir (na web, por exemplo), o servidor também localiza o livro na imagem antes do OCR e do embedding quando recebe um quadro inteiro.

**Fusão dos sinais.**
- ISBN válido lido: é a resposta, com confiança máxima. Se a edição não está no catálogo, busque os metadados na cascata, crie a obra e a edição e enfileire a análise.
- Sem ISBN: combine a pontuação do OCR e a do embedding por obra candidata. Se a melhor candidata passa do limiar e tem margem clara sobre a segunda, a resposta é `identificado`. Se há candidatas plausíveis sem margem, a resposta é `candidatos`, com até cinco. Caso contrário, `nao_identificado`.
- Os limiares e pesos ficam em `configuracao` e são calibrados com o conjunto de avaliação da seção 5. Não invente números definitivos: comece com valores conservadores (prefira mostrar candidatos a afirmar o livro errado) e documente como recalibrar.

Resposta:

```json
{
  "status": "identificado | candidatos | nao_identificado | nao_e_livro",
  "obra": { "id": "", "titulo": "", "autores": [], "capa_url": "", "faixa_final": "14+", "status_ficha": "publicada" },
  "candidatos": [{ "obra": {}, "pontuacao": 0.0, "sinais": ["ocr", "capa"] }],
  "sinais": { "isbn": null, "texto_ocr": [], "tempo_ms": 0 }
}
```

A meta de tempo do servidor para esta rota é de até dois segundos em hardware modesto. Meça e registre; se o OCR for o gargalo, responda primeiro com o que os outros sinais já resolveram.

### 4.6 API

Prefixo `/v1`, JSON, erros em formato único (`codigo`, `mensagem`, `detalhes`), documentação OpenAPI gerada pelo FastAPI. Rotas principais:

- Autenticação: cadastro, login por e-mail e senha, login com Google e com Apple, renovação de token, recuperação de senha, exclusão de conta.
- `GET /v1/obras?busca=` (título, autor ou ISBN, mínimo de três caracteres para texto), `GET /v1/obras/{id}`, `GET /v1/obras/isbn/{isbn}`, `POST /v1/obras` (cadastro manual quando nenhuma fonte reconhece o ISBN).
- `GET /v1/obras/{id}/ficha` (conta consulta, seção 4.11), `GET /v1/obras/{id}/ficha/resumo` (selo, faixa e recomendação; não conta), `GET /v1/fichas/{id}/pdf`, `GET /v1/publico/fichas/{slug}` (página pública compartilhável do resumo).
- `POST /v1/reconhecimento`.
- Perfis de leitor, listas e itens, histórico de consultas.
- Contestações: criar, acompanhar.
- Organizações: membros, listas de acervo, `POST /v1/organizacoes/{id}/importacoes` (CSV de ISBNs), andamento da importação, relatórios.
- Assinaturas: estado do plano, validação de compra das lojas, sessão de pagamento e webhook do Stripe.
- Revisão editorial (papéis `revisor` e `admin`): fila, edição de ficha, publicação, resposta a contestação.
- `GET /v1/configuracao`: flags, limites e rubrica resumida para o app.
- `GET /v1/metodologia`: conteúdo da página "Como classificamos", gerado a partir da rubrica.

### 4.7 Provedores configuráveis

Nada no código de negócio conhece um fornecedor específico. Defina interfaces e adaptadores, escolhidos por variável de ambiente:

- `ProvedorLLM` (classificação): adaptadores para Anthropic, OpenAI e Google. Consulte a documentação atual de cada um para os identificadores de modelo; não escreva de memória.
- `MotorOCR`: um adaptador local de código aberto como padrão e um adaptador para serviço de nuvem.
- `ModeloDeCapa`: gera embeddings (seção 5).
- `FonteDeMetadados`: Google Books, Open Library.
- `ProvedorDePagamento`.

Cada interface tem também uma implementação falsa e determinística, usada nos testes e quando a chave não está configurada. Uma implementação falsa nunca produz dado que pareça real para o usuário: sem chave de LLM, a análise falha com mensagem clara em vez de publicar uma ficha inventada. A exceção são os dados de demonstração da seção 9, que são marcados como tais.

### 4.8 Flags e limites vindos do servidor

Guarde em `configuracao` e entregue pelo `GET /v1/configuracao`. O app consulta um único ponto (`podeExibir('chave')`); uma chave desconhecida é erro, nunca "verdadeiro". Valores iniciais:

| Chave | Inicial | O que controla |
|---|---|---|
| `trechos_literais` | desligada | Trechos exatos da obra (só fazem sentido com texto integral) |
| `parafrase_evidencia` | ligada | Descrição das cenas que sustentam cada nível |
| `camada_b` | ligada | Alertas de conteúdo |
| `camada_c` | ligada | Perfil de leitura |
| `valor_formativo` | ligada | Bloco de valor formativo |
| `eixo_a6` | ligada | Exibição do eixo A6 |
| `confianca` | ligada | Barra de confiança |
| `justificativa_eixo` | ligada | Justificativa por eixo |
| `selo_revisao_humana` | ligada | Selo "Revisado por editor humano" |
| `metodologia` | ligada | Página "Como classificamos" |
| `exportar_pdf` | ligada | Exportação da ficha |
| `compartilhar` | ligada | Link público do resumo |
| `scanner` | ligada | Tela da câmera |
| `busca_titulo` | ligada | Busca por texto |

Limites na mesma tabela: consultas grátis por mês (10), perfis de leitor no plano gratuito (1), palavras por trecho (40), trechos por ficha (6), tetos de confiança por fonte, limiares do reconhecimento.

### 4.9 Dados pessoais e LGPD

- De um perfil de leitor guarde só apelido, ano de nascimento e ícone. Nada de nome completo, foto, escola ou documento. Menores não têm conta.
- As imagens enviadas ao reconhecimento são processadas e descartadas. Só são gravadas em `amostras_reconhecimento` se o usuário ligar, nas configurações, a opção de ajudar a melhorar o reconhecimento; a opção vem desligada e explica o que é guardado.
- O recorte feito no aparelho existe também por privacidade: o que sai do celular é o livro, não a livraria nem as pessoas em volta.
- O usuário pode exportar e excluir seus dados pelo app. A exclusão de conta apaga perfis, listas, histórico e amostras.
- Registre consentimentos com data e versão do texto aceito. Escreva rascunhos de Política de Privacidade e Termos de Uso em `docs/`, marcados como rascunhos que precisam de revisão jurídica.
- Segredos só em variáveis de ambiente. Forneça `.env.example` sem valores reais.

### 4.10 Revisão editorial e contestação

Uma área web restrita aos papéis `revisor` e `admin`, dentro do mesmo app Flutter:

- Fila de fichas não revisadas, ordenada por número de consultas e, em seguida, por menor confiança.
- Tela de revisão: o revisor ajusta níveis, alertas, perfil de leitura e textos, com motivo obrigatório. A faixa é recalculada pelo mesmo código; o revisor não digita faixa.
- Ao publicar, a ficha ganha `revisada_por_humano: true`, o nome do papel do revisor (não o nome da pessoa) e uma nova versão no histórico.
- Qualquer usuário pode contestar uma ficha, indicando o eixo ou campo e o motivo. A ficha contestada exibe "Ficha em revisão após contestação" até a resposta. O usuário é avisado do resultado.

Isto responde à recomendação dos avaliadores de incluir especialistas em educação, biblioteconomia e desenvolvimento infantojuvenil no processo.

### 4.11 Planos e pagamento

- **Gratuito:** busca e câmera ilimitadas, resumo da ficha sempre visível, 10 fichas completas novas por mês, 1 perfil de leitor. Uma ficha já aberta continua acessível sem consumir nova consulta. Abrir a ficha completa exige conta.
- **Família (pago):** fichas ilimitadas, perfis de leitor ilimitados, listas ilimitadas, exportação em PDF.
- **Escola (pago, por organização):** tudo do Família para os membros, mais painel web, importação em lote e relatórios.

No celular, a assinatura é feita pela loja (App Store e Google Play); na web, por Stripe. O direito de acesso vive no servidor: o app pergunta ao backend qual é o plano, e o backend valida os recibos das lojas e os webhooks do Stripe. Use `[PREÇO FAMÍLIA]` e `[PREÇO ESCOLA]` onde um valor apareceria; os preços ainda não foram definidos. Em ambiente local, um provedor de pagamento falso permite ativar planos para teste.

O limite é aplicado no servidor. Ao atingi-lo, a rota da ficha completa responde com um erro específico e o app mostra a tela de planos, mantendo o resumo visível.

## 5. Modelo de reconhecimento de capas (`ml/`)

O objetivo é ter um modelo próprio de reconhecimento de capas, com DINO como ponto de partida. Construa em etapas, cada uma utilizável por si:

1. **Base.** Use um modelo DINO pré-treinado como extrator de embeddings, sem treino. O padrão é o DINOv2 em uma variante pequena ou base, pela licença permissiva. Antes de trocar para o DINOv3 ou outro modelo, leia a licença dele e registre a conclusão em `docs/decisoes.md`. O modelo roda no servidor, em CPU por padrão, com uso de GPU quando disponível.
2. **Índice.** `ml/indexar.py` percorre as edições do catálogo, baixa a capa da URL de origem, gera o embedding e grava em `capas` com o nome e a versão do modelo. Respeite os termos das fontes das imagens: guarde o vetor e a URL, e use a imagem só para exibição conforme a fonte permitir. Reindexar após troca de modelo é um comando, e vetores de modelos diferentes nunca são comparados entre si.
3. **Avaliação.** `ml/avaliar.py` mede acerto em primeiro lugar e entre os cinco primeiros, e produz a curva que permite escolher os limiares da seção 4.5. O conjunto de avaliação tem duas partes: capas do catálogo com distorções sintéticas (perspectiva, reflexo, desfoque, baixa luz, oclusão parcial por dedos, etiqueta de preço) e fotos reais em `ml/dados/fotos_reais/`, pasta que começa vazia com um LEIAME explicando como a equipe adiciona fotos rotuladas.
4. **Ajuste fino (opcional, preparado).** `ml/treinar.py` faz ajuste fino por aprendizado contrastivo: a capa limpa e suas versões distorcidas são pares positivos; outras capas são negativos, com atenção especial a edições diferentes da mesma obra e a volumes de uma mesma série, que são os casos difíceis. Use também as amostras consentidas da seção 4.9. O script exporta o modelo em um formato que o adaptador `ModeloDeCapa` carrega, e a avaliação compara o modelo ajustado com a base antes de qualquer troca.

Não afirme números de acurácia que você não mediu. O relatório final diz o que foi medido, em quais dados, e o que ficou sem medir por falta de fotos reais.

## 6. App Flutter

### 6.1 Plataformas e arquitetura

Um único código para Android, iOS e web. No celular, o uso típico é o do responsável na livraria; na web, o da escola diante de um acervo e também o do responsável em casa.

- Flutter estável atual, Dart com null safety.
- Organização por funcionalidade (`lib/funcionalidades/<nome>/` com dados, domínio e apresentação) e um `lib/nucleo/` com tema, textos, rede, configuração e componentes compartilhados.
- Gerência de estado com Riverpod; rotas com `go_router`, com URLs legíveis na web (`/obra/{id}`, `/ficha/{slug}`); HTTP com `dio`; modelos imutáveis gerados por código.
- Camada de repositório entre a interface e a API, com cache local do histórico e das fichas já abertas, para que a última ficha vista abra sem rede.
- Localização em arquivos ARB, com `pt-BR` como único idioma por enquanto. Todos os textos visíveis ficam ali.
- Escolha os pacotes conferindo no pub.dev se estão mantidos e quais plataformas suportam. Registre as escolhas em `docs/decisoes.md`.

### 6.2 Navegação

Celular: barra inferior com quatro destinos: **Início**, **Escanear**, **Listas**, **Perfil**. Em telas largas (a partir de cerca de 900 px), a barra vira um trilho lateral, o conteúdo tem largura máxima de leitura e a ficha passa a duas colunas. Na web, organizações ganham o destino **Acervo** e revisores ganham **Revisão**.

### 6.3 Telas

**Primeiro uso.** Três telas curtas: o que o Entrelinhas faz; como ler uma ficha (selo, alertas, perfil de leitura); o aviso de independência. Em seguida, entrar ou criar conta. Buscar e escanear funcionam sem conta.

**Início.**
- Marca "Entrelinhas" e o slogan "O que está entre as linhas, antes da leitura."
- Campo de busca com rótulo "Buscar um livro" e dica "Título, autor ou ISBN".
- Botão principal, grande, "Apontar para o livro", com o subtítulo "Capa ou código de barras".
- "Consultas recentes": linhas com miniatura da capa, título, autor e selo de faixa.
- Com perfis de leitor cadastrados, um seletor "Para quem é a leitura?" que personaliza as fichas.
- No plano gratuito, um indicador discreto: "7 de 10 fichas neste mês".

**Busca.** Resultados conforme a digitação, a partir de três caracteres, com atraso curto para não disparar a cada tecla. Cada resultado mostra capa, título, autor, origem dos dados (Base Entrelinhas, Google Books, Open Library) e o selo quando há ficha, ou "Sem ficha ainda" quando não há. Um texto com 10 ou 13 dígitos é tratado como ISBN e validado. Mensagens:
- "Digite ao menos 3 letras para buscar."
- "Nenhuma obra encontrada. Confira a grafia ou tente o ISBN."
- "Este número não é um ISBN válido. Confira os dígitos."
- "Sem conexão com as fontes externas. Mostrando só a base Entrelinhas."
- "ISBN válido, mas nenhuma fonte reconheceu a obra. Você pode cadastrá-la manualmente."

**Escanear** (a tela mais importante do app; detalhes na seção 6.4).

**Confirmação do reconhecimento.**
- `identificado`: abre a ficha direto, com uma faixa no topo, "É este o livro?", e a ação "Não é este", que leva aos candidatos e à busca.
- `candidatos`: "Encontramos estas opções", com até cinco cartões de capa, título e autor, e "Nenhuma destas".
- `nao_identificado`: "Não reconhecemos este livro. Tente o código de barras na contracapa ou busque pelo título.", com as ações de escanear de novo, buscar e digitar o ISBN.
- `nao_e_livro`: "O código lido não é de um livro. Procure o código ISBN, geralmente na contracapa."

**Ficha do livro.** De cima para baixo:
1. Barra com voltar, "Salvar na lista" e um menu com compartilhar, exportar PDF e contestar.
2. Capa (com sombra suave), título, autores, gênero e páginas.
3. **Selo e recomendação.** Cartão com o selo circular da faixa, o rótulo "ORIENTAÇÃO DE LEITURA" e o texto da recomendação contextual.
4. **Para o leitor selecionado**, quando há perfil: compara a idade com a faixa em linguagem neutra. Exemplos: "Dentro da faixa para Lia (12 anos)." ou "A faixa é 14 anos; Lia tem 12. A orientação é leitura com mediação de adulto ou aguardar." Sem perfil selecionado, o bloco não aparece.
5. **Procedência.** Uma linha com a fonte ("Análise a partir de sinopse e resenhas públicas"), a barra "Confiança da análise" e, quando for o caso, o selo "Revisado por editor humano" ou o aviso "Ficha em revisão após contestação". Em fichas sem acesso ao texto, o aviso: "Esta ficha é uma estimativa gerada sem acesso ao texto da obra. Trate a faixa como orientação inicial, não como análise."
6. **Conteúdo sensível.** Os seis eixos, cada um em uma linha com nome, uma barra de cinco segmentos (0 a 4) e o rótulo do nível (Ausente, Leve, Moderado, Intenso, Extremo). O eixo determinante vem marcado com "Define a faixa". Tocar em uma linha abre a justificativa e as evidências em paráfrase. Se o agravante foi aplicado, uma nota explica: "Dois ou mais eixos em 16 anos ou acima elevam a faixa em um degrau."
7. **Alertas de conteúdo.** Chips com os rótulos da Camada B. Os dois alertas com justificativa obrigatória abrem a justificativa ao toque.
8. **Perfil de leitura.** "Nível de leitura" com o rótulo (por exemplo "Intermediário"), as quatro dimensões em barras de 1 a 5 e "Repertório que ajuda" com até três itens.
9. **Valor formativo.** Nível (Baixo, Médio, Alto), até três marcadores e a justificativa.
10. Link "Como classificamos" e o aviso de independência.

Quando A5 está em 3 ou 4, a tela não mostra trecho literal em nenhuma hipótese e exibe: "Trechos desta obra não são reproduzidos por descreverem conduta de risco. A orientação se baseia em descrição neutra das cenas."

Estados da ficha: carregando (esqueleto com a forma da ficha, não um indicador giratório no meio da tela); "Estamos analisando esta obra. Isso leva alguns instantes.", com atualização automática; "Obra localizada, ainda sem ficha Entrelinhas.", com o botão "Pedir análise"; erro de rede com "Tentar de novo"; limite atingido, que mantém selo e recomendação e oferece os planos.

**Listas.** Listas pessoais ("Quero ler", "Aprovados", e as que o usuário criar), cada item com capa, título e selo. Filtro por faixa e por leitor.

**Perfil.** Conta, leitores (apelido, ano de nascimento, ícone), plano e uso do mês, privacidade (opção de contribuir com imagens, exportar dados, excluir conta), "Como classificamos", termos e política.

**Planos.** Comparação curta entre Gratuito, Família e Escola, com os preços como placeholders.

**Como classificamos.** Página pública gerada a partir da rubrica: os seis eixos com seus descritores, as tabelas de mapeamento, a regra do maior eixo, o agravante, o que os alertas e o perfil de leitura são e não são, as fontes de análise e o que significa cada nível de confiança, e como contestar.

**Acervo (organizações, web).**
- Listas de acervo e de turma, com ano escolar ou idade de referência.
- Importação em lote: envio de CSV com uma coluna de ISBN, validação linha a linha, relatório do que foi aceito, rejeitado e não encontrado, e andamento das análises pendentes.
- Tabela do acervo com ordenação e filtros por faixa, alerta, nível de leitura e situação da ficha.
- Relatório: distribuição do acervo por faixa, alertas mais frequentes, obras acima da idade de referência de uma turma, exportação em CSV e PDF. Use gráficos simples e uma tabela equivalente para acessibilidade.
- Gestão de membros e papéis.

**Revisão (revisores, web).** Conforme a seção 4.10.

### 6.4 A tela de escanear, em detalhe

O objetivo é que a pessoa aponte o celular para o livro e a ficha apareça, sem apertar nada no caso comum.

**O que acontece no aparelho.**
1. A câmera traseira abre em tela cheia, com foco contínuo.
2. Dois detectores analisam os quadros da pré-visualização, fora da thread da interface e com frequência limitada (cerca de 8 a 10 análises por segundo), para a imagem não travar:
   - um detector de código de barras, que devolve a posição do código e, quando conseguir, o valor lido;
   - um detector de objetos leve, executado no aparelho, que devolve o contorno do livro. Um modelo pré-treinado com a classe "livro" serve como ponto de partida.
3. Sobre a imagem, um contorno acompanha o livro ou o código detectado, em tempo real. Sem detecção, aparece uma moldura-guia com a instrução "Enquadre a capa ou o código de barras".
4. A captura é automática quando o contorno fica estável por cerca de 0,7 segundo, ocupa uma parte razoável do quadro e a imagem está nítida (uma medida simples de foco, como a variância do laplaciano, basta). O contorno muda de cor e o aparelho vibra de leve. Há também um botão de captura manual, sempre disponível.
5. O app recorta a região detectada com uma margem, reduz para cerca de 1024 px no maior lado, comprime em JPEG e envia a `POST /v1/reconhecimento` com a dica de tipo. Se o código de barras foi lido no aparelho, o ISBN vai junto: o servidor continua sendo a autoridade, mas responde mais rápido.
6. Durante o envio, a imagem congelada fica na tela com "Identificando o livro…". A resposta leva à confirmação (seção 6.3).

**Controles.** Lanterna, alternar entre "Capa" e "Código de barras" quando o automático não acerta, escolher foto da galeria, "Digitar ISBN" e fechar.

**Casos a tratar.** Permissão de câmera negada (explicar por que é necessária e levar às configurações, mantendo a galeria e o ISBN manual como alternativas); pouca luz (sugerir a lanterna); vários livros no quadro (escolher o maior e mais central, e permitir tocar em outro); sem rede (guardar a captura e oferecer tentar de novo); aparelho lento (reduzir a frequência das análises); app em segundo plano (soltar a câmera).

**Web.** A câmera vem do navegador e exige HTTPS. Verifique quais detectores funcionam na web com os pacotes escolhidos. Onde a detecção no aparelho não estiver disponível, mostre a moldura-guia com captura manual e envie o quadro; o servidor localiza o livro. Em computador sem câmera, a tela oferece enviar uma foto e digitar o ISBN.

**Arquitetura.** Isole a câmera e os detectores atrás de uma interface (`DetectorDeLivro`, que recebe um quadro e devolve regiões com tipo e confiança), com implementações por plataforma e uma implementação falsa para testes. A lógica de estabilidade e disparo é uma máquina de estados pura, testável sem câmera: `procurando`, `detectado`, `estavel`, `capturando`, `enviando`, `resultado`, `erro`.

### 6.5 Estados, erros e acessibilidade

- Toda tela que busca dados trata carregando, vazio, erro e sucesso.
- Erros dizem o que aconteceu e o que fazer, sem código técnico e sem pedir desculpas em excesso.
- Alvos de toque de ao menos 44 por 44 pontos; contraste de texto de ao menos 4,5 para 1; a faixa nunca é comunicada só pela cor (o selo sempre traz o texto); rótulos semânticos em ícones, selos e barras ("Violência física: nível 3 de 4, intenso"); suporte a texto ampliado sem cortes; navegação por teclado e foco visível na web.
- Tema claro nesta versão. Estruture os tokens para que um tema escuro seja adicionado depois sem tocar nas telas.

## 7. Identidade visual: editorial e acolhedora

A referência é uma livraria ou revista literária: papel, tinta, tipografia serifada nos títulos, calma. O app precisa parecer confiável para um responsável e para uma escola, sem parecer um órgão oficial nem um aplicativo infantil. Evite gradientes, ilustrações decorativas, emojis e excesso de sombras.

**Cores** (arquivo único de tema):

| Token | Valor | Uso |
|---|---|---|
| `papel` | `#F6F1E7` | Fundo das telas |
| `superficie` | `#FFFBF3` | Cartões, campos, barra de navegação |
| `superficieSuave` | `#EDE5D4` | Blocos de apoio (nível de leitura, dimensões) |
| `tinta` | `#23302B` | Texto principal |
| `tintaFraca` | `#5E6A63` | Texto secundário e rótulos |
| `pauta` | `#E3DAC8` | Divisores |
| `pautaForte` | `#CFC4AE` | Bordas de campos e botões secundários |
| `marca` | `#2F5D50` | Botão principal, destino ativo, links |
| `sobreMarca` | `#FFFBF3` | Texto sobre a cor de marca |
| `acento` | `#B4532A` | Destaques pontuais |
| `alertaForte` | `#8C2F1B` | Níveis intensos e avisos |

**Escala de faixas** (a única família saturada da interface; texto do selo em `#FFFBF3`):

| Faixa | Cor |
|---|---|
| Livre | `#2F5D50` |
| 10+ | `#2F6F8F` |
| 12+ | `#8F6410` |
| 14+ | `#B4532A` |
| 16+ | `#8C2F1B` |
| 18+ | `#2B2430` |

Confira o contraste de cada par com um teste automatizado e ajuste o tom, mantendo a família, se algum ficar abaixo de 4,5 para 1.

**Tipografia.** Fraunces para a marca, títulos de obra, títulos de seção, o número do selo e valores em destaque. Nunito Sans para corpo, rótulos, botões e navegação. Empacote as fontes no app; não dependa de download em tempo de execução. Escala: marca 34, título de obra 26, título de seção 19 a 20, destaque 17, corpo 15 a 16, apoio 13 a 14, legenda 12. Rótulos em maiúsculas (como "ORIENTAÇÃO DE LEITURA") usam 12 com espaçamento de letras de cerca de 1.

**Forma e espaço.** Espaçamentos em múltiplos de 4 (4, 8, 12, 16, 24, 36). Margem lateral de 24 no celular. Raios: 12 em campos, 16 em cartões e no botão principal, 999 em pílulas e chips, 3 a 4 em capas. Divisores de 1 px em `pauta`. Uma única sombra, suave, reservada às capas.

**Componentes centrais.**
- **Selo de faixa:** círculo preenchido com a cor da faixa e o texto ("14+", "Livre") em Fraunces. Tamanhos: 76 na ficha, 48 em cartões, e uma versão em pílula com contorno para listas.
- **Linha de eixo:** nome à esquerda, barra de cinco segmentos, rótulo do nível à direita. Segmentos preenchidos em `tinta` até o nível 2 e em `alertaForte` a partir do 3; vazios em `pauta`.
- **Chip de alerta:** pílula com contorno em `pautaForte` e texto em `tinta`.
- **Barra de confiança:** barra fina com o valor em texto ao lado ("Média").
- **Botão principal:** fundo `marca`, altura mínima de 52. O botão de escanear do Início é maior (cerca de 104 de altura), com ícone à esquerda, título em Fraunces e subtítulo.
- **Linha de livro:** miniatura da capa (44 por 64), título em Fraunces 17, autor em 14, selo em pílula à direita.

Ícones de traço fino, de um único conjunto. Animações curtas e discretas (150 a 250 ms), respeitando a preferência do sistema por movimento reduzido.

## 8. Qualidade

- **Backend:** testes da agregação (seção 3.1), do validador da saída do modelo, da validação de ISBN (10 e 13 dígitos, conversão, dígito verificador), da fusão de sinais do reconhecimento, do limite mensal e das permissões por papel. Todos rodam sem rede e sem chaves, usando as implementações falsas.
- **App:** testes de unidade da máquina de estados do scanner e dos repositórios; testes de widget da ficha em seus estados (incluindo A5 em nível 3 ou mais, flags desligadas e limite atingido); imagens de referência do selo e da ficha.
- **Invariantes com teste dedicado:** mesma entrada, mesma faixa; nenhuma ficha com A5 em 3 ou mais expõe trecho literal, em qualquer combinação de flags; desligar qualquer flag recompõe a ficha sem erro; a expressão "classificação indicativa" não aparece em nenhum arquivo de textos (um teste percorre os arquivos).
- Análise estática sem avisos no Dart e no Python, formatação automática e um fluxo de integração contínua que roda tudo isso.
- Segurança: senhas com algoritmo de hash adequado, tokens de curta duração com renovação, limite de requisições nas rotas públicas e no reconhecimento, validação de tipo e tamanho de imagens e CSVs, autorização conferida no servidor em toda rota.

## 9. Dados de demonstração

O banco começa com um pequeno conjunto de obras **fictícias**, com títulos e autores inventados e fichas completas que cobrem todas as faixas, o agravante de acúmulo, A5 em nível 3 e uma ficha contestada. Elas são marcadas como demonstração no banco e na interface, e existem para que o app possa ser navegado sem chave de LLM. Não escreva fichas de livros reais à mão: uma ficha de obra real só existe se tiver passado pelo pipeline da seção 4.4.

## 10. Estrutura do repositório

```
app/        aplicativo Flutter (Android, iOS, web)
backend/    API FastAPI, motor de análise, reconhecimento, migrações, testes
ml/         indexação, avaliação e ajuste fino do modelo de capas
docs/       decisoes.md, arquitetura.md, como-rodar.md, rascunhos jurídicos
docker-compose.yml
.env.example
```

## 11. Como conduzir o trabalho

Trabalhe nesta ordem, deixando cada etapa funcionando e testada antes da seguinte, porque as posteriores dependem das anteriores:

1. Rubrica, agregação e seus testes.
2. Banco, contrato da ficha, API de obras e fichas, dados de demonstração.
3. App: tema, textos, navegação, Início, Busca e Ficha, lendo da API.
4. Pipeline de análise com provedores configuráveis.
5. Reconhecimento no servidor e `ml/` (base, índice, avaliação).
6. Tela de escanear com detecção ao vivo.
7. Contas, perfis de leitor, listas, limites e planos.
8. Organizações, importação em lote e relatórios.
9. Revisão editorial, contestação e "Como classificamos".
10. Ajuste fino do modelo de capas (scripts prontos e documentados), acessibilidade, acabamento.

Sobre o que você não consegue fazer neste ambiente:
- Sem chaves de API, lojas de aplicativos ou Stripe, construa contra as interfaces, use as implementações falsas e deixe a integração real escrita e documentada, dizendo com clareza que ela não foi exercitada.
- Sem um aparelho com câmera, teste a máquina de estados e os detectores com imagens de arquivo, e diga que o fluxo ao vivo precisa de validação em aparelho real.
- Rode o que for possível: os testes, o backend em contêiner e o app na web. Antes de dizer que algo funciona, veja funcionar.

Ao terminar, escreva `docs/como-rodar.md` e um relatório final que comece pelo estado real do projeto: o que funciona e foi verificado, o que foi escrito mas não pôde ser verificado e por quê, o que falta, e as decisões que tomou por conta própria. Não descreva como concluído algo que só foi esboçado.
