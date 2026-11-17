import io
import uuid

import numpy as np
import pytest
import zxingcpp
from PIL import Image

from app.core.isbn import digito_13
from app.main import app
from app.modelos import AmostraReconhecimento, Edicao, Obra
from app.provedores.modelo_capa import CapaFalsa, Histograma, obter_modelo_capa
from app.provedores.ocr import OcrFalso, obter_ocr
from app.reconhecimento.imagem import ler_codigo, localizar_livro
from app.reconhecimento.servico import Candidato, decidir, fundir, indexar_capa

from .conftest import cabecalho

CFG = {"peso_ocr": 0.55, "peso_capa": 0.45, "limiar_identificado": 0.45,
       "margem_minima": 0.08, "limiar_candidato": 0.2, "max_candidatos": 5,
       "similaridade_minima_ocr": 0.2, "piso_capa": 0.5}


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


def test_le_isbn_e_reconhece_codigo_que_nao_e_livro():
    assert ler_codigo(imagem_codigo("9780306406157")).isbn13 == "9780306406157"
    leitura = ler_codigo(imagem_codigo(EAN_PRODUTO))
    assert leitura.isbn13 is None and leitura.nao_e_livro
    assert ler_codigo(Image.new("RGB", (300, 300), "white")).codigos_lidos == []


def test_le_codigo_girado():
    girada = imagem_codigo("9780306406157").rotate(90, expand=True)
    assert ler_codigo(girada).isbn13 == "9780306406157"


def test_localizar_livro_recorta_capa_em_perspectiva():
    import cv2

    capa = np.full((300, 200, 3), (140, 70, 50), np.uint8)
    fundo = np.full((600, 600, 3), (230, 230, 230), np.uint8)
    m = cv2.getPerspectiveTransform(np.float32([[0, 0], [200, 0], [200, 300], [0, 300]]),
                                    np.float32([[180, 120], [400, 140], [420, 470], [170, 450]]))
    quadro = cv2.warpPerspective(capa, m, (600, 600), dst=fundo, borderMode=cv2.BORDER_TRANSPARENT)
    recorte = localizar_livro(Image.fromarray(quadro))
    assert recorte.size != (600, 600)
    assert 180 < recorte.size[0] < 280 and 280 < recorte.size[1] < 380
    centro = np.asarray(recorte)[recorte.size[1] // 2, recorte.size[0] // 2]
    assert abs(int(centro[0]) - 140) < 20  # é a capa, não o fundo


def test_fusao_e_decisao():
    a, b = uuid.uuid4(), uuid.uuid4()
    cands = fundir({a: 0.9, b: 0.3}, {a: 0.95, b: 0.9}, CFG)
    status, escolhidos = decidir(cands, CFG)
    assert status == "identificado" and escolhidos[0].obra_id == a
    # Dois candidatos parecidos: lista, não afirmação.
    cands = fundir({a: 0.6, b: 0.58}, {}, CFG)
    assert decidir(cands, CFG)[0] == "candidatos"
    assert decidir([], CFG)[0] == "nao_identificado"
    assert decidir([Candidato(a, pontuacao=0.1)], CFG)[0] == "nao_identificado"


def test_histograma_reconhece_a_propria_capa_distorcida():
    rng = np.random.default_rng(0)
    capas = [Image.fromarray(rng.integers(0, 255, (90, 60, 3), dtype=np.uint8)).resize((300, 450))
             for _ in range(5)]
    m = Histograma()
    galeria = np.stack([m.embutir(c) for c in capas])
    consulta = m.embutir(capas[3].rotate(3).crop((10, 10, 290, 440)))
    assert int(np.argmax(galeria @ consulta)) == 3


# ------------------------------------------------------------------ rota

@pytest.fixture
def catalogo(sessao):
    obras = {}
    for titulo, cor in (("O Jardim de Vidro", (140, 75, 58)), ("A Ilha dos Relógios", (60, 100, 120))):
        o = Obra(titulo=titulo, autores=["Autora"], autores_texto="Autora", fonte_metadados="x")
        e = Edicao(capa_url=f"/{titulo}.png")
        o.edicoes.append(e)
        sessao.add(o)
        sessao.flush()
        indexar_capa(sessao, e, Image.new("RGB", (300, 450), cor), CapaFalsa(), e.capa_url)
        obras[titulo] = o
    livro = Obra(titulo="Livro com ISBN", autores=[], autores_texto="", fonte_metadados="x")
    livro.edicoes.append(Edicao(isbn13="9780306406157"))
    sessao.add(livro)
    sessao.commit()
    obras["isbn"] = livro
    return obras


def _usar(ocr_linhas=None):
    app.dependency_overrides[obter_ocr] = lambda: OcrFalso(ocr_linhas or [])
    app.dependency_overrides[obter_modelo_capa] = lambda: CapaFalsa()


def _enviar(cliente, img, dica="desconhecido", **extra):
    return cliente.post("/v1/reconhecimento",
                        files={"imagem": ("f.jpg", jpeg(img), "image/jpeg")},
                        data={"dica": dica, **extra}, **({}))


def test_rota_codigo_de_barras(cliente, catalogo):
    _usar()
    r = _enviar(cliente, imagem_codigo("9780306406157"), "codigo_de_barras").json()
    assert r["status"] == "identificado" and r["obra"]["titulo"] == "Livro com ISBN"
    assert r["sinais"]["isbn"] == "9780306406157"
    r = _enviar(cliente, imagem_codigo(EAN_PRODUTO), "codigo_de_barras").json()
    assert r["status"] == "nao_e_livro"


def test_rota_isbn_do_aparelho_e_conferido(cliente, catalogo):
    _usar()
    branca = Image.new("RGB", (200, 200), "white")
    r = _enviar(cliente, branca, "capa", isbn="978-0-306-40615-7").json()
    assert r["status"] == "identificado"
    r = _enviar(cliente, branca, "capa", isbn="9780306406158").json()  # dígito errado
    assert r["status"] != "identificado"


def test_rota_capa_por_ocr_e_imagem(cliente, catalogo):
    _usar(["O JARDIM DE VIDRO", "Autora"])
    r = _enviar(cliente, Image.new("RGB", (300, 450), (140, 75, 58)), "capa").json()
    assert r["status"] == "identificado"
    assert r["obra"]["titulo"] == "O Jardim de Vidro"
    assert r["sinais"]["texto_ocr"][0] == "O JARDIM DE VIDRO"


def test_rota_sem_pista_nao_identifica(cliente, catalogo):
    _usar([])
    r = _enviar(cliente, Image.new("RGB", (300, 450), (0, 0, 0)), "capa").json()
    assert r["status"] in ("nao_identificado", "candidatos")
    assert r["obra"] is None


def test_rota_valida_tipo(cliente):
    _usar()
    r = cliente.post("/v1/reconhecimento", files={"imagem": ("a.txt", b"oi", "text/plain")})
    assert r.status_code == 415 and r.json()["codigo"] == "tipo_invalido"


def test_amostra_so_com_consentimento(cliente, catalogo, usuario, sessao):
    _usar(["O JARDIM DE VIDRO"])
    img = Image.new("RGB", (300, 450), (140, 75, 58))
    h = cabecalho(usuario)
    r = cliente.post("/v1/reconhecimento", headers=h,
                     files={"imagem": ("f.jpg", jpeg(img), "image/jpeg")}).json()
    assert r["amostra_id"] is None and sessao.query(AmostraReconhecimento).count() == 0
    cliente.patch("/v1/eu", json={"contribuir_imagens": True}, headers=h)
    r = cliente.post("/v1/reconhecimento", headers=h,
                     files={"imagem": ("f.jpg", jpeg(img), "image/jpeg")}).json()
    assert r["amostra_id"] is not None
    alvo = catalogo["A Ilha dos Relógios"]
    assert cliente.post(f"/v1/reconhecimento/{r['amostra_id']}/correcao",
                        json={"obra_id": str(alvo.id)}, headers=h).status_code == 204
    amostra = sessao.query(AmostraReconhecimento).one()
    sessao.refresh(amostra)
    assert amostra.obra_corrigida_id == alvo.id
    # Excluir a conta apaga as amostras.
    cliente.delete("/v1/eu", headers=h)
    assert sessao.query(AmostraReconhecimento).count() == 0
