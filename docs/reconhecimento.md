# Reconhecimento de livro por imagem

## Fluxo

1. **No aparelho** (Android/iOS): a câmera analisa ~9 quadros por segundo fora da thread
   da interface. O ML Kit procura código de barras EAN-13; o detector TFLite (COCO SSD
   MobileNet v1) procura o objeto retangular que é a capa. A máquina de estados
   (`app/lib/funcionalidades/escanear/dominio/maquina_scanner.dart`) dispara a captura quando
   o contorno fica parado ~0,7 s, ocupa ≥ 12% do quadro e a imagem está nítida (variância do
   laplaciano). Código já decodificado dispara na hora.
2. O app recorta a região (com margem), reduz para ~1024 px e envia a `POST /v1/reconhecimento`.
3. **No servidor**: ISBN do aparelho conferido; senão, leitura de código com variações
   (CLAHE, binarização, ampliação, rotações); senão, capa: localização da capa no quadro
   (contorno + perspectiva) quando a dica é "desconhecido", OCR (Tesseract por+eng) e
   embedding em paralelo, fusão e decisão.
4. **Web**: sem análise ao vivo; moldura-guia e captura manual; o servidor localiza.

## Fusão e decisão

`pontuação = (peso_ocr × ocr + peso_capa × capa_reescalada) / soma dos pesos presentes`,
com `capa_reescalada = (sim − piso) / (1 − piso)`.

- OCR: `0,75 × word_similarity(título, texto) + 0,25 × word_similarity(autores, texto)`,
  sem acentos (função SQL `unaccent_simples`, migração 0002).
- Capa: similaridade de cosseno via pgvector, só entre vetores do mesmo modelo e versão.
- `identificado` se `pontuação ≥ limiar_identificado` e a margem sobre o segundo ≥
  `margem_minima`; `candidatos` (até 5) se ≥ `limiar_candidato`; senão `nao_identificado`.
- Tudo em `configuracao` → `limite.reconhecimento`.

## Medição (feita neste ambiente)

`ml/avaliar.py`, 60 capas **sintéticas** (`ml/gerar_capas_sinteticas.py`), 3 fotos simuladas
por capa (perspectiva + 1 a 2 entre reflexo, desfoque, pouca luz, dedo, etiqueta de preço),
modelo de capa `histograma/1`, OCR Tesseract:

| Sinal | Top-1 | Top-5 |
|---|---|---|
| Capa (histograma) | 30,0% | 74,4% |
| OCR | 56,1% | 63,9% |
| **Fusão** | **66,1%** | **88,9%** |

Por caso: edições diferentes da mesma obra 83%, obras simples 76%, volumes de série 57%
(top-1 da fusão). Mediana de tempo por consulta (localização + OCR + capa): 314 ms.

Curva para precisão ≥ 99% no status `identificado`: limiar 0,40 e margem 0,05 dão 29% de
identificações diretas com precisão 100% neste conjunto. Adotei limiar 0,45 e margem 0,08
(≈20% de identificações diretas), um pouco mais conservador porque o conjunto é sintético.

### O que NÃO foi medido

- **Fotos reais**: nenhuma. `ml/dados/fotos_reais/` tem o LEIAME para a equipe adicionar.
- **DINOv2**: pesos não baixáveis aqui. A expectativa é que melhore muito o sinal da capa,
  que hoje é o mais fraco; isso precisa ser medido antes de qualquer afirmação.
- **Detector no aparelho em celular real**: o detector foi testado em Python sobre fotos
  simuladas (achou a caixa da capa, rotulada "tv"); a integração Dart não rodou em aparelho.
- **Escala**: o índice de vetores não tem índice ANN (a coluna tem dimensão livre). Para
  milhares de capas, criar índice parcial por modelo, por exemplo:
  `CREATE INDEX ON capas USING hnsw ((vetor::vector(768)) vector_cosine_ops) WHERE modelo = 'facebook/dinov2-small';`

## Recalibrar

```bash
psql -c "create database entrelinhas_ml"
backend/.venv/bin/python ml/gerar_capas_sinteticas.py --quantidade 60
PYTHONPATH=backend backend/.venv/bin/python ml/avaliar.py --fotos-por-capa 3
```

O relatório em `ml/resultados/avaliacao_<modelo>.json` traz `piso_capa_calibrado` e a curva
completa; copie os valores escolhidos para `configuracao` (`limite.reconhecimento`). Refaça
a cada troca de modelo e sempre que houver fotos reais novas.

## Ajuste fino (preparado)

`ml/treinar.py`: InfoNCE simétrico com negativos do lote; o amostrador junta no mesmo lote
edições da mesma obra e volumes da mesma série (os casos difíceis); edições da mesma obra
contam como positivas entre si; usa também as amostras consentidas. Exporta com
`save_pretrained`, carregável por `MODELO_CAPA=dinov2 MODELO_CAPA_PESOS_LOCAIS=...`. Compare
com a base em `ml/avaliar.py` antes de trocar.
