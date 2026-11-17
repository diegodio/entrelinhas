import 'dart:typed_data';
import 'dart:ui';

import 'package:entrelinhas/funcionalidades/escanear/dominio/deteccao.dart';
import 'package:entrelinhas/funcionalidades/escanear/dominio/maquina_scanner.dart';
import 'package:flutter_test/flutter_test.dart';

const m = MaquinaScanner();
Duration ms(int v) => Duration(milliseconds: v);

Regiao capa(Rect r, {double conf = 0.8}) =>
    Regiao(tipo: TipoRegiao.capa, caixa: r, confianca: conf);

Analise quadro(List<Regiao> rs, {double nitidez = 200, double luz = 128}) =>
    Analise(regioes: rs, nitidez: nitidez, luminancia: luz);

const livro = Rect.fromLTRB(0.2, 0.15, 0.8, 0.85);

EstadoScanner rodar(List<(int, Analise)> quadros, [EstadoScanner? inicio]) {
  var e = inicio ?? EstadoScanner.inicial;
  for (final (t, a) in quadros) {
    e = m.aoAnalisar(e, a, ms(t));
  }
  return e;
}

void main() {
  test('sem detecção continua procurando', () {
    expect(rodar([(0, Analise.vazia), (100, Analise.vazia)]).fase, FaseScanner.procurando);
  });

  test('livro parado e nítido dispara a captura depois de ~0,7 s', () {
    var e = rodar([
      (0, quadro([capa(livro)])),
    ]);
    expect(e.fase, FaseScanner.estavel);
    e = rodar([
      (400, quadro([capa(livro)])),
    ], e);
    expect(e.fase, FaseScanner.estavel);
    expect(e.progresso(ms(400), const ParametrosScanner()), closeTo(0.57, 0.01));
    e = rodar([
      (720, quadro([capa(livro.translate(0.01, 0))])),
    ], e);
    expect(e.fase, FaseScanner.capturando);
  });

  test('livro que se mexe reinicia a contagem', () {
    final e = rodar([
      (0, quadro([capa(livro)])),
      (400, quadro([capa(livro.translate(0.2, 0))])),
      (800, quadro([capa(livro.translate(0.2, 0))])),
    ]);
    expect(e.fase, FaseScanner.estavel); // só 400 ms parado
    expect(
      rodar([
        (1150, quadro([capa(livro.translate(0.2, 0))])),
      ], e).fase,
      FaseScanner.capturando,
    );
  });

  test('imagem tremida ou livro pequeno não disparam', () {
    expect(
      rodar([
        (0, quadro([capa(livro)], nitidez: 10)),
        (900, quadro([capa(livro)], nitidez: 10)),
      ]).fase,
      FaseScanner.detectado,
    );
    const pequeno = Rect.fromLTRB(0.45, 0.45, 0.55, 0.55);
    expect(
      rodar([
        (0, quadro([capa(pequeno)])),
        (900, quadro([capa(pequeno)])),
      ]).fase,
      FaseScanner.detectado,
    );
  });

  test('código lido no aparelho dispara na hora', () {
    const codigo = Regiao(
      tipo: TipoRegiao.codigoDeBarras,
      caixa: Rect.fromLTRB(0.3, 0.6, 0.6, 0.7),
      confianca: 1,
      valor: '9780306406157',
    );
    expect(
      rodar([
        (0, quadro([capa(livro), codigo])),
      ]).fase,
      FaseScanner.capturando,
    );
  });

  test('falha curta do detector é tolerada; longa volta a procurar', () {
    var e = rodar([
      (0, quadro([capa(livro)])),
      (300, quadro([capa(livro)])),
    ]);
    e = rodar([(500, Analise.vazia)], e);
    expect(e.fase, FaseScanner.estavel);
    e = rodar([(900, Analise.vazia)], e);
    expect(e.fase, FaseScanner.procurando);
  });

  test('pouca luz é sinalizada', () {
    expect(rodar([(0, quadro([], luz: 20))]).poucaLuz, isTrue);
  });

  test('vários livros: o maior e mais central; toque escolhe outro', () {
    const pequenoCanto = Rect.fromLTRB(0.0, 0.0, 0.25, 0.3);
    final regioes = [capa(pequenoCanto), capa(livro)];
    expect(escolherPrincipal(regioes)!.caixa, livro);
    expect(escolherPrincipal(regioes, toque: const Offset(0.1, 0.1))!.caixa, pequenoCanto);
    var e = rodar([(0, quadro(regioes))]);
    expect(e.variasRegioes, isTrue);
    e = m.aoTocar(e, const Offset(0.1, 0.1));
    e = rodar([(100, quadro(regioes))], e);
    expect(e.regiao!.caixa, pequenoCanto);
  });

  test('captura manual, envio, resultado, erro e reinício', () {
    var e = m.aoCapturarManual(EstadoScanner.inicial);
    expect(e.fase, FaseScanner.capturando);
    // Quadros que chegam durante a captura são ignorados.
    expect(m.aoAnalisar(e, quadro([capa(livro)]), ms(10)).fase, FaseScanner.capturando);
    e = m.aoEnviar(e);
    expect(e.fase, FaseScanner.enviando);
    expect(m.aoCapturarManual(e).fase, FaseScanner.enviando);
    expect(m.aoReceberResultado(e).fase, FaseScanner.resultado);
    e = m.aoFalhar(e, 'sem rede');
    expect(e.fase, FaseScanner.erro);
    expect(e.mensagemErro, 'sem rede');
    expect(m.reiniciar(e).fase, FaseScanner.procurando);
  });

  test('iou, recorte com margem e nitidez', () {
    expect(iou(livro, livro), 1);
    expect(iou(livro, const Rect.fromLTRB(0.9, 0.9, 1, 1)), 0);
    final r = recorteComMargem(const Rect.fromLTRB(0, 0.5, 0.5, 1));
    expect(r.left, 0);
    expect(r.bottom, 1);
    expect(r.right, closeTo(0.53, 0.001));

    final liso = Uint8List(64 * 64)..fillRange(0, 64 * 64, 128);
    final xadrez = Uint8List.fromList(
      List.generate(64 * 64, (i) => ((i ~/ 64) ~/ 4 + (i % 64) ~/ 4).isEven ? 0 : 255),
    );
    expect(nitidezLaplaciano(liso, 64, 64), 0);
    expect(nitidezLaplaciano(xadrez, 64, 64), greaterThan(1000));
    expect(luminanciaMedia(liso), 128);
  });
}
