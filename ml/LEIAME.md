# Reconhecimento de capas (`ml/`)

| Arquivo | O que faz | Situação |
|---|---|---|
| `distorcoes.py` | Fotos simuladas: perspectiva, reflexo, desfoque, pouca luz, dedo, etiqueta | Usado e testado |
| `gerar_capas_sinteticas.py` | Capas fictícias, com edições da mesma obra e volumes de série | Usado |
| `indexar.py` | Gera e grava os vetores das capas do catálogo (`capas`) | Usado com o modelo histograma |
| `avaliar.py` | Top-1/top-5 por sinal e da fusão; curva de cobertura x precisão | Executado (resultados em `resultados/`) |
| `treinar.py` | Ajuste fino contrastivo do DINOv2 | Escrito, **não executado** (sem pesos/torch aqui) |

Resultados e decisões: `docs/reconhecimento.md`.

## Rodar

```bash
psql -c "create database entrelinhas_ml"          # banco separado para a avaliação
backend/.venv/bin/python ml/gerar_capas_sinteticas.py --quantidade 60
PYTHONPATH=backend backend/.venv/bin/python ml/avaliar.py --fotos-por-capa 3
```

Para usar o DINOv2: `pip install -e "backend[ml]"`, `MODELO_CAPA=dinov2`, reindexar com
`ml/indexar.py` e rodar a avaliação de novo. Leia a licença do modelo antes de trocar.
