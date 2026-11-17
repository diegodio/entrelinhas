"""Armazenamento de arquivos (amostras de reconhecimento). Local ou compatível com S3 (MinIO)."""

from __future__ import annotations

from pathlib import Path
from typing import Protocol

from app.config import configuracoes


class Armazenamento(Protocol):
    def salvar(self, caminho: str, dados: bytes, tipo: str) -> str: ...

    def ler(self, caminho: str) -> bytes: ...

    def apagar(self, caminho: str) -> None: ...


class ArmazenamentoLocal:
    def __init__(self, pasta: str):
        self.raiz = Path(pasta).resolve()

    def _seguro(self, caminho: str) -> Path:
        destino = (self.raiz / caminho).resolve()
        if self.raiz not in destino.parents:
            raise ValueError("Caminho fora da pasta de arquivos.")
        return destino

    def salvar(self, caminho: str, dados: bytes, tipo: str) -> str:
        destino = self._seguro(caminho)
        destino.parent.mkdir(parents=True, exist_ok=True)
        destino.write_bytes(dados)
        return caminho

    def ler(self, caminho: str) -> bytes:
        return self._seguro(caminho).read_bytes()

    def apagar(self, caminho: str) -> None:
        self._seguro(caminho).unlink(missing_ok=True)


class ArmazenamentoS3:
    def __init__(self):
        import boto3

        cfg = configuracoes()
        self.bucket = cfg.s3_bucket
        self.cliente = boto3.client(
            "s3",
            endpoint_url=cfg.s3_endpoint or None,
            aws_access_key_id=cfg.s3_chave or None,
            aws_secret_access_key=cfg.s3_segredo or None,
        )

    def salvar(self, caminho: str, dados: bytes, tipo: str) -> str:
        self.cliente.put_object(Bucket=self.bucket, Key=caminho, Body=dados, ContentType=tipo)
        return caminho

    def ler(self, caminho: str) -> bytes:
        return self.cliente.get_object(Bucket=self.bucket, Key=caminho)["Body"].read()

    def apagar(self, caminho: str) -> None:
        self.cliente.delete_object(Bucket=self.bucket, Key=caminho)


def obter() -> Armazenamento:
    cfg = configuracoes()
    if cfg.armazenamento == "s3":
        return ArmazenamentoS3()
    return ArmazenamentoLocal(cfg.pasta_arquivos)
