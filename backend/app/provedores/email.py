"""Envio de e-mail. "console" registra no log (desenvolvimento); "smtp" envia de verdade."""

from __future__ import annotations

import logging
import smtplib
from email.message import EmailMessage
from typing import Protocol

from app.config import Configuracoes, configuracoes

log = logging.getLogger("entrelinhas.email")


class ProvedorEmail(Protocol):
    def enviar(self, para: str, assunto: str, texto: str) -> None: ...


class EmailConsole:
    def __init__(self):
        self.enviados: list[tuple[str, str, str]] = []

    def enviar(self, para: str, assunto: str, texto: str) -> None:
        self.enviados.append((para, assunto, texto))
        log.info("E-mail (console) para=%s assunto=%s\n%s", para, assunto, texto)


class EmailSmtp:
    def __init__(self, cfg: Configuracoes):
        self.cfg = cfg

    def enviar(self, para: str, assunto: str, texto: str) -> None:
        msg = EmailMessage()
        msg["From"] = self.cfg.email_remetente
        msg["To"] = para
        msg["Subject"] = assunto
        msg.set_content(texto)
        with smtplib.SMTP(self.cfg.smtp_host, self.cfg.smtp_porta, timeout=10) as s:
            s.starttls()
            if self.cfg.smtp_usuario:
                s.login(self.cfg.smtp_usuario, self.cfg.smtp_senha)
            s.send_message(msg)


_console = EmailConsole()


def obter_email() -> ProvedorEmail:
    cfg = configuracoes()
    return EmailSmtp(cfg) if cfg.provedor_email == "smtp" else _console
