# API e worker do Entrelinhas.
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1

# Tesseract (OCR, por+eng), fontes para gerar capas de demonstração e cliente do Postgres.
RUN apt-get update \
 && apt-get install -y --no-install-recommends tesseract-ocr tesseract-ocr-por \
      fonts-dejavu-core libgl1 libglib2.0-0 postgresql-client \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /srv
COPY pyproject.toml ./
COPY app ./app
COPY migracoes ./migracoes
COPY alembic.ini ./
RUN pip install .

RUN useradd --create-home entrelinhas && mkdir -p /srv/dados_locais && chown -R entrelinhas /srv
USER entrelinhas

EXPOSE 8000
CMD ["sh", "-c", "alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port 8000"]
