import 'dart:math';
import 'dart:typed_data';

import 'package:entrelinhas/simples/ean13.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

// Codificador mínimo de EAN-13, só para gerar imagens de teste.
const _l = [
  '0001101',
  '0011001',
  '0010011',
  '0111101',
  '0100011',
  '0110001',
  '0101111',
  '0111011',
  '0110111',
  '0001011',
];
const _par = [
  'LLLLLL',
  'LLGLGG',
  'LLGGLG',
  'LLGGGL',
  'LGLLGG',
  'LGGLLG',
  'LGGGLL',
  'LGLGLG',
  'LGLGGL',
  'LGGLGL',
];

String _modulos(String c) {
  String inv(String s) => s.split('').map((b) => b == '0' ? '1' : '0').join();
  final b = StringBuffer('101');
  final p = _par[int.parse(c[0])];
  for (var i = 1; i <= 6; i++) {
    final l = _l[int.parse(c[i])];
    b.write(p[i - 1] == 'L' ? l : inv(l).split('').reversed.join());
  }
  b.write('01010');
  for (var i = 7; i <= 12; i++) {
    b.write(inv(_l[int.parse(c[i])]));
  }
  b.write('101');
  return b.toString();
}

/// Foto simulada: fundo claro, código com [escala] px por módulo, ruído e borrão opcionais.
img.Image foto(String codigo, {double escala = 3, int ruido = 0, double borrao = 0}) {
  final mods = _modulos(codigo);
  final larg = (mods.length * escala).round() + 240, alt = 260;
  final im = img.Image(width: larg, height: alt);
  img.fill(im, color: img.ColorRgb8(225, 215, 195));
  final rnd = Random(1);
  for (var x = 0; x < larg; x++) {
    final m = ((x - 120) / escala).floor();
    final barra = m >= 0 && m < mods.length && mods[m] == '1';
    for (var y = 60; y < 200; y++) {
      if (barra) im.setPixelRgb(x, y, 25, 25, 30);
    }
  }
  for (final p in im) {
    final r = ruido == 0 ? 0 : rnd.nextInt(2 * ruido + 1) - ruido;
    p
      ..r = (p.r + r).clamp(0, 255)
      ..g = (p.g + r).clamp(0, 255)
      ..b = (p.b + r).clamp(0, 255);
  }
  return borrao > 0 ? img.gaussianBlur(im, radius: borrao.round()) : im;
}

(Uint8List, int, int) cinza(img.Image im) {
  final c = Uint8List(im.width * im.height);
  var i = 0;
  for (final p in im) {
    c[i++] = p.r.toInt();
  }
  return (c, im.width, im.height);
}

String? ler(img.Image im) {
  final (c, w, h) = cinza(im);
  return lerEan13(c, w, h);
}

void main() {
  const isbn = '9780306406157';

  test('dígito verificador', () {
    expect(digitoVerificadorOk(isbn), isTrue);
    expect(digitoVerificadorOk('9780306406158'), isFalse);
    expect(digitoVerificadorOk('123'), isFalse);
  });

  test('lê vários códigos, incluindo os do catálogo', () {
    for (final c in [isbn, '9788595081512', '9788532530783', '7891000315507', '9788506051009']) {
      expect(ler(foto(c)), c, reason: c);
    }
  });

  test('lê com módulos finos, ruído e borrão', () {
    expect(ler(foto(isbn, escala: 2)), isbn);
    expect(ler(foto(isbn, escala: 2.6, ruido: 30)), isbn);
    expect(ler(foto(isbn, escala: 4, borrao: 1)), isbn);
  });

  test('lê de cabeça para baixo e na vertical', () {
    expect(ler(img.copyRotate(foto(isbn), angle: 180)), isbn);
    expect(ler(img.copyRotate(foto(isbn), angle: 90)), isbn);
  });

  test('imagem sem código não inventa leitura', () {
    final vazio = img.Image(width: 400, height: 300);
    img.fill(vazio, color: img.ColorRgb8(200, 200, 200));
    expect(ler(vazio), isNull);
    final listras = img.Image(width: 400, height: 300);
    for (final p in listras) {
      final v = (p.x ~/ 7).isEven ? 20 : 230;
      p
        ..r = v
        ..g = v
        ..b = v;
    }
    expect(ler(listras), isNull);
  });

  test('lê de um JPEG (como a foto da câmera)', () async {
    final jpeg = img.encodeJpg(foto(isbn, escala: 3, ruido: 10), quality: 80);
    expect(await lerEan13DeFoto(Uint8List.fromList(jpeg)), isbn);
  });
}
