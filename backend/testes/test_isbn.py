import pytest

from app.core import isbn


@pytest.mark.parametrize(
    "texto,esperado",
    [
        ("978-85-359-0277-8", "9788535902778"),
        ("ISBN 978 85 359 0277 8", "9788535902778"),
        ("isbn-13: 9780306406157", "9780306406157"),
        ("0-306-40615-2", "0306406152"),
        ("080442957x", "080442957X"),
    ],
)
def test_normalizar(texto, esperado):
    assert isbn.normalizar(texto) == esperado


def test_validos_e_invalidos_13():
    assert isbn.valido_13("9780306406157")
    assert not isbn.valido_13("9780306406158")
    assert not isbn.valido_13("978030640615")


def test_validos_e_invalidos_10():
    assert isbn.valido_10("0306406152")
    assert isbn.valido_10("080442957X")
    assert not isbn.valido_10("0306406153")
    assert not isbn.valido_10("X306406152")


def test_conversoes():
    assert isbn.para_13("0306406152") == "9780306406157"
    assert isbn.para_13("080442957X") == "9780804429573"
    assert isbn.para_10("9780306406157") == "0306406152"
    assert isbn.para_10("9780804429573") == "080442957X"
    assert isbn.para_10("9791034304530") is None  # 979 não tem ISBN-10
    with pytest.raises(ValueError):
        isbn.para_13("123")


def test_ida_e_volta():
    for dez in ("0306406152", "080442957X", "8535902775"):
        assert isbn.para_10(isbn.para_13(dez)) == dez


def test_ean_de_livro():
    assert isbn.e_ean_de_livro("9780306406157")
    assert isbn.e_ean_de_livro("9791034304530")
    assert not isbn.e_ean_de_livro("7891000315507")  # EAN válido de produto, não livro
    assert not isbn.e_ean_de_livro("9780306406158")


def test_validar():
    assert isbn.validar("85-359-0277-5") == "9788535902778"
    assert isbn.validar("abc") is None
    assert isbn.validar("7891000315507") is None


def test_parece_isbn():
    assert isbn.parece_isbn("978-85-359-0277-8")
    assert isbn.parece_isbn("8535902775")
    assert not isbn.parece_isbn("Dom Casmurro")
    assert not isbn.parece_isbn("12345")
