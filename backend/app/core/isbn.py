"""ISBN: normalização, validação do dígito verificador (10 e 13) e conversão."""

from __future__ import annotations

import re

PREFIXOS_LIVRO = ("978", "979")


def normalizar(texto: str) -> str:
    """Remove hífens, espaços e prefixo 'ISBN'. Mantém X final (ISBN-10) em maiúscula."""
    limpo = re.sub(r"(?i)^isbn(-1[03])?:?", "", (texto or "").strip())
    return re.sub(r"[\s\-]", "", limpo).upper()


def parece_isbn(texto: str) -> bool:
    """Texto com 10 ou 13 dígitos (X final permitido no de 10) depois de normalizar."""
    n = normalizar(texto)
    return bool(re.fullmatch(r"\d{13}|\d{9}[\dX]", n))


def valido_10(isbn: str) -> bool:
    if not re.fullmatch(r"\d{9}[\dX]", isbn):
        return False
    total = sum((10 - i) * int(c) for i, c in enumerate(isbn[:9]))
    total += 10 if isbn[9] == "X" else int(isbn[9])
    return total % 11 == 0


def digito_13(primeiros12: str) -> str:
    soma = sum(int(c) * (1 if i % 2 == 0 else 3) for i, c in enumerate(primeiros12))
    return str((10 - soma % 10) % 10)


def valido_13(isbn: str) -> bool:
    return bool(re.fullmatch(r"\d{13}", isbn)) and digito_13(isbn[:12]) == isbn[12]


def e_ean_de_livro(codigo: str) -> bool:
    """EAN-13 com prefixo de livro (978/979) e dígito verificador correto."""
    return valido_13(codigo) and codigo.startswith(PREFIXOS_LIVRO)


def para_13(isbn: str) -> str:
    """Converte ISBN-10 em ISBN-13 (prefixo 978). Levanta ValueError se inválido."""
    n = normalizar(isbn)
    if valido_13(n):
        return n
    if not valido_10(n):
        raise ValueError(f"ISBN inválido: {isbn!r}")
    base = "978" + n[:9]
    return base + digito_13(base)


def para_10(isbn13: str) -> str | None:
    """Converte ISBN-13 978 em ISBN-10. Prefixo 979 não tem equivalente: devolve None."""
    n = normalizar(isbn13)
    if not valido_13(n) or not n.startswith("978"):
        return None
    corpo = n[3:12]
    resto = (11 - sum((10 - i) * int(c) for i, c in enumerate(corpo)) % 11) % 11
    return corpo + ("X" if resto == 10 else str(resto))


def validar(texto: str) -> str | None:
    """Devolve o ISBN-13 normalizado ou None se o texto não for um ISBN válido de livro."""
    n = normalizar(texto)
    try:
        isbn13 = para_13(n)
    except ValueError:
        return None
    return isbn13 if isbn13.startswith(PREFIXOS_LIVRO) else None
