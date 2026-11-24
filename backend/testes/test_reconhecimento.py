"""Identificação pelo código de barras: leitura na foto e rota /v1/reconhecimento."""

import io

import numpy as np
import pytest
import zxingcpp
from PIL import Image

from app.core.isbn import digito_13
from app.modelos import Edicao, Obra
from app.reconhecimento.imagem import ler_codigo


def imagem_codigo(texto: str) -> Image.Image:
    cod = zxingcpp.create_barcode(texto, zxingcpp.BarcodeFormat.EAN13)
    arr = np.asarray(cod.to_image(scale=3))
    fundo = np.full((arr.shape[0] + 200, arr.shape[1] + 200), 255, np.uint8)
    fundo[100:-100, 100:-100] = arr
    return Image.fromarray(fundo).convert("RGB")


def jpeg(img: Image.Image) -> bytes:
    b = io.BytesIO()
    img.save(b, format="JPEG", quality=92)
    return b.getvalue()


EAN_PRODUTO = "789100031550" + digito_13("789100031550")  # EAN válido, não é livro
ISBN = "9780306406157"


def test_le_isbn_e_reconhece_codigo_que_nao_e_livro():
    assert ler_codigo(imagem_codigo(ISBN)).isbn13 == ISBN
    leitura = ler_codigo(imagem_codigo(EAN_PRODUTO))
    assert leitura.isbn13 is None and leitura.nao_e_livro
    assert ler_codigo(Image.new("RGB", (300, 300), "white")).codigos_lidos == []


def test_le_codigo_girado_e_pequeno_na_foto():
    girada = imagem_codigo(ISBN).rotate(90, expand=True)
    assert ler_codigo(girada).isbn13 == ISBN
    # Código ocupando pouco da foto, como no verso inteiro do livro.
    cena = Image.new("RGB", (1400, 1800), (200, 190, 170))
    cena.paste(imagem_codigo(ISBN), (700, 1300))
    assert ler_codigo(cena).isbn13 == ISBN


@pytest.fixture
def livro(sessao):
    obra = Obra(
        titulo="Livro com ISBN", autores=["Autora"], autores_texto="Autora", fonte_metadados="x"
    )
    obra.edicoes.append(Edicao(isbn13=ISBN))
    sessao.add(obra)
    sessao.commit()
    return obra


def _enviar(cliente, img=None, **dados):
    arquivos = {"imagem": ("f.jpg", jpeg(img), "image/jpeg")} if img is not None else None
    return cliente.post("/v1/reconhecimento", files=arquivos, data=dados)


def test_rota_identifica_pelo_codigo_da_foto(cliente, livro):
    r = _enviar(cliente, imagem_codigo(ISBN)).json()
    assert r["status"] == "identificado" and r["obra"]["titulo"] == "Livro com ISBN"
    assert r["isbn"] == ISBN


def test_rota_isbn_fora_do_catalogo(cliente, livro):
    outro = "978853590277" + digito_13("978853590277")
    r = _enviar(cliente, imagem_codigo(outro)).json()
    assert r["status"] == "nao_identificado" and r["isbn"] == outro and r["obra"] is None


def test_rota_codigo_que_nao_e_livro_e_foto_sem_codigo(cliente, livro):
    assert _enviar(cliente, imagem_codigo(EAN_PRODUTO)).json()["status"] == "nao_e_livro"
    r = _enviar(cliente, Image.new("RGB", (300, 450), (140, 75, 58))).json()
    assert r["status"] == "sem_codigo" and r["obra"] is None


def test_rota_isbn_do_aparelho_e_conferido(cliente, livro):
    branca = Image.new("RGB", (200, 200), "white")
    assert _enviar(cliente, branca, isbn="978-0-306-40615-7").json()["status"] == "identificado"
    assert _enviar(cliente, isbn=ISBN).json()["status"] == "identificado"  # só o ISBN
    # Dígito errado: ignora o ISBN informado e tenta a foto (que não tem código).
    assert _enviar(cliente, branca, isbn="9780306406158").json()["status"] == "sem_codigo"


def test_rota_valida_entrada(cliente):
    r = cliente.post("/v1/reconhecimento", files={"imagem": ("a.txt", b"oi", "text/plain")})
    assert r.status_code == 415 and r.json()["codigo"] == "tipo_invalido"
    r = cliente.post("/v1/reconhecimento", data={})
    assert r.status_code == 400 and r.json()["codigo"] == "sem_imagem"
