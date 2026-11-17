# Entrelinhas

**O que está entre as linhas, antes da leitura.**

Serviço brasileiro de Orientação de Leitura para livros: aponte a câmera para a capa ou o
código de barras (ou busque por título, autor ou ISBN) e veja a faixa de idade recomendada,
os alertas de conteúdo, o perfil de leitura e o valor formativo da obra.

Orientação editorial independente, sem vínculo com o Ministério da Justiça ou com o sistema
ClassInd.

| Pasta | Conteúdo |
|---|---|
| `app/` | App Flutter (Android, iOS, web) |
| `backend/` | API FastAPI, motor de análise, reconhecimento, migrações, testes |
| `ml/` | Índice, avaliação e ajuste fino do modelo de capas |
| `docs/` | [Como rodar](docs/como-rodar.md), [arquitetura](docs/arquitetura.md), [decisões](docs/decisoes.md), [reconhecimento](docs/reconhecimento.md), [relatório final](docs/relatorio-final.md), rascunhos jurídicos |

Início rápido: `docker compose up --build` e `docker compose exec api python -m app.demo`
(detalhes e alternativa sem Docker em [docs/como-rodar.md](docs/como-rodar.md)).

O método (Rubrica Entrelinhas v1.0) está em `backend/app/rubrica/rubrica_v1.json` e é
publicado no app em "Como classificamos". A faixa etária nunca é decidida pela IA: ela é
calculada por `backend/app/core/agregacao.py`.
