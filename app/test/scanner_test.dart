import 'dart:typed_data';
import 'dart:ui';

import 'package:entrelinhas/funcionalidades/escanear/dados/leitor.dart';
import 'package:entrelinhas/funcionalidades/escanear/dados/leitor_nativo.dart';
import 'package:entrelinhas/funcionalidades/escanear/dominio/maquina_scanner.dart';
import 'package:flutter_test/flutter_test.dart';

const m = MaquinaScanner();
Duration ms(int v) => Duration(milliseconds: v);

const caixa = Rect.fromLTRB(0.25, 0.4, 0.75, 0.55);
const isbn = '9780306406157';
const eanProduto = '7891000315507'; // EAN válido, não é livro

Analise quadro(List<CodigoLido> codigos, {double luz = 128}) =>
    Analise(codigos: codigos, luminancia: luz);

EstadoScanner rodar(List<(int, Analise)> quadros, [EstadoScanner? inicio]) {
  var e = inicio ?? EstadoScanner.inicial;
  for (final (t, a) in quadros) {
    e = m.aoAnalisar(e, a, ms(t));
  }
  return e;
}

void main() {
  test('ISBN de livro: dígito verificador e prefixo 978/979', () {
    expect(eIsbnDeLivro(isbn), isTrue);
    expect(eIsbnDeLivro('9780306406158'), isFalse); // dígito errado
    expect(eIsbnDeLivro(eanProduto), isFalse);
    expect(eIsbnDeLivro(null), isFalse);
    expect(eIsbnDeLivro('978030640615'), isFalse);
  });

  test('sem código continua procurando', () {
    final e = rodar([(0, Analise.vazia), (100, Analise.vazia)]);
    expect(e.fase, FaseScanner.procurando);
    expect(e.caixa, isNull);
  });

  test('ISBN lido no aparelho consulta na hora', () {
    final e = rodar([
      (0, quadro([const CodigoLido(caixa: caixa, valor: isbn)])),
    ]);
    expect(e.fase, FaseScanner.consultando);
    expect(e.isbn, isbn);
    // Quadros que chegam durante a consulta são ignorados.
    expect(m.aoAnalisar(e, Analise.vazia, ms(10)).fase, FaseScanner.consultando);
  });

  test('código visto mas ainda não lido mostra o contorno e segue procurando', () {
    final e = rodar([
      (0, quadro([const CodigoLido(caixa: caixa)])),
    ]);
    expect(e.fase, FaseScanner.procurando);
    expect(e.caixa, caixa);
    expect(e.naoELivro, isFalse);
  });

  test('EAN que não é de livro avisa e não consulta', () {
    final e = rodar([
      (0, quadro([const CodigoLido(caixa: caixa, valor: eanProduto)])),
    ]);
    expect(e.fase, FaseScanner.procurando);
    expect(e.naoELivro, isTrue);
    // Com um ISBN no mesmo quadro (livro com dois códigos), o ISBN vence.
    final dois = rodar([
      (
        0,
        quadro([
          const CodigoLido(caixa: caixa, valor: eanProduto),
          const CodigoLido(caixa: caixa, valor: isbn),
        ]),
      ),
    ]);
    expect(dois.fase, FaseScanner.consultando);
    expect(dois.isbn, isbn);
  });

  test('falha curta da leitura é tolerada; longa apaga o contorno', () {
    var e = rodar([
      (0, quadro([const CodigoLido(caixa: caixa, valor: eanProduto)])),
    ]);
    e = rodar([(400, Analise.vazia)], e);
    expect(e.caixa, caixa);
    expect(e.naoELivro, isTrue);
    e = rodar([(900, Analise.vazia)], e);
    expect(e.caixa, isNull);
    expect(e.naoELivro, isFalse);
  });

  test('pouca luz é sinalizada', () {
    expect(rodar([(0, quadro([], luz: 20))]).poucaLuz, isTrue);
    expect(rodar([(0, quadro([], luz: 120))]).poucaLuz, isFalse);
  });

  test('captura manual, resultado, erro e reinício', () {
    var e = m.aoCapturarManual(EstadoScanner.inicial);
    expect(e.fase, FaseScanner.consultando);
    expect(e.isbn, isNull);
    expect(m.aoCapturarManual(e).fase, FaseScanner.consultando); // não duplica
    expect(m.aoReceberResultado(e).fase, FaseScanner.resultado);
    e = m.aoFalhar(e, 'sem rede');
    expect(e.fase, FaseScanner.erro);
    expect(e.mensagemErro, 'sem rede');
    expect(m.reiniciar(e).fase, FaseScanner.procurando);
  });

  test('luminância do quadro (NV21 e BGRA)', () {
    const l = 32, a = 24;
    final escuro = QuadroCamera(
      largura: l,
      altura: a,
      formato: FormatoQuadro.nv21,
      planos: [
        PlanoQuadro(bytes: Uint8List(l * a * 3 ~/ 2)..fillRange(0, l * a, 30), bytesPorLinha: l),
      ],
      rotacao: 90,
    );
    expect(luminanciaDoQuadro(escuro), 30);
    final claro = QuadroCamera(
      largura: l,
      altura: a,
      formato: FormatoQuadro.bgra8888,
      planos: [
        PlanoQuadro(
          bytes: Uint8List(l * a * 4)..fillRange(0, l * a * 4, 200),
          bytesPorLinha: l * 4,
        ),
      ],
      rotacao: 0,
    );
    expect(luminanciaDoQuadro(claro), closeTo(200, 2));
  });
}
