// Leitor de EAN-13 em Dart puro, para a web (onde não há ML Kit) e para fotos da galeria.
//
// Percorre várias linhas (e colunas) da imagem em tons de cinza, binariza cada uma, procura
// a sequência de 59 faixas do EAN-13 (guarda, 6 dígitos, guarda central, 6 dígitos, guarda)
// e decodifica comparando a largura das faixas com os padrões L, G e R. Só aceita leituras
// com dígito verificador correto e, quando há mais de uma, fica com a mais votada.

import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;

/// Larguras (espaço, barra, espaço, barra) do código L de cada dígito. O G é o L invertido;
/// o R tem as mesmas larguras do L, começando por barra.
const _padroesL = [
  [3, 2, 1, 1],
  [2, 2, 2, 1],
  [2, 1, 2, 2],
  [1, 4, 1, 1],
  [1, 1, 3, 2],
  [1, 2, 3, 1],
  [1, 1, 1, 4],
  [1, 3, 1, 2],
  [1, 2, 1, 3],
  [3, 1, 1, 2],
];

/// Paridade dos 6 dígitos da esquerda (true = G) que codifica o primeiro dígito.
const _paridades = [
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

const _faixas = 59; // 3 + 24 + 5 + 24 + 3
const _modulos = 95;

bool digitoVerificadorOk(String codigo) {
  if (!RegExp(r'^\d{13}$').hasMatch(codigo)) return false;
  var soma = 0;
  for (var i = 0; i < 12; i++) {
    soma += int.parse(codigo[i]) * (i.isEven ? 1 : 3);
  }
  return (10 - soma % 10) % 10 == int.parse(codigo[12]);
}

/// Lê um EAN-13 numa imagem em tons de cinza ([cinza] com [largura] x [altura] bytes).
/// Devolve os 13 dígitos ou null.
String? lerEan13(Uint8List cinza, int largura, int altura, {int linhas = 40}) {
  final votos = <String, int>{};
  void anotar(String? r) {
    if (r != null) votos[r] = (votos[r] ?? 0) + 1;
  }

  final linha = Uint8List(largura);
  for (var k = 0; k < linhas; k++) {
    final y = ((k + 0.5) * altura / linhas).floor();
    linha.setRange(0, largura, cinza, y * largura);
    anotar(_lerLinha(linha));
  }
  // Código na vertical: percorre colunas.
  final coluna = Uint8List(altura);
  for (var k = 0; k < linhas; k++) {
    final x = ((k + 0.5) * largura / linhas).floor();
    for (var y = 0; y < altura; y++) {
      coluna[y] = cinza[y * largura + x];
    }
    anotar(_lerLinha(coluna));
  }
  if (votos.isEmpty) return null;
  return votos.entries.reduce((a, b) => b.value > a.value ? b : a).key;
}

/// Decodifica uma foto (JPEG/PNG) fora da thread da interface quando possível.
Future<String?> lerEan13DeFoto(Uint8List bytes, {int ladoMaximo = 1000}) =>
    compute(_lerFoto, (bytes, ladoMaximo));

String? _lerFoto((Uint8List, int) args) {
  final (bytes, ladoMaximo) = args;
  final decodificada = img.decodeImage(bytes);
  if (decodificada == null) return null;
  var foto = img.bakeOrientation(decodificada);
  final maior = foto.width > foto.height ? foto.width : foto.height;
  if (maior > ladoMaximo) {
    foto = foto.width >= foto.height
        ? img.copyResize(foto, width: ladoMaximo)
        : img.copyResize(foto, height: ladoMaximo);
  }
  final cinza = Uint8List(foto.width * foto.height);
  var i = 0;
  for (final p in foto) {
    cinza[i++] = ((p.r * 77 + p.g * 150 + p.b * 29) / 256).floor();
  }
  return lerEan13(cinza, foto.width, foto.height);
}

/// Uma linha: tenta dois limiares (global da linha e local) e os dois sentidos.
String? _lerLinha(Uint8List px) {
  for (final pretos in [_binarizarGlobal(px), _binarizarLocal(px)]) {
    if (pretos == null) continue;
    final faixas = _faixasDe(pretos);
    final r = _procurar(faixas) ?? _procurar(faixas.reversed.toList());
    if (r != null) return r;
  }
  return null;
}

List<bool>? _binarizarGlobal(Uint8List px) {
  var min = 255, max = 0;
  for (final v in px) {
    if (v < min) min = v;
    if (v > max) max = v;
  }
  if (max - min < 40) return null; // sem contraste
  final limiar = (min + max) ~/ 2;
  return [for (final v in px) v < limiar];
}

/// Limiar pela média numa janela (lida com sombra e reflexo ao longo da linha).
List<bool>? _binarizarLocal(Uint8List px) {
  final n = px.length;
  if (n < _modulos) return null;
  final janela = (n ~/ 12).clamp(16, 200);
  final acumulado = Int32List(n + 1);
  for (var i = 0; i < n; i++) {
    acumulado[i + 1] = acumulado[i] + px[i];
  }
  return [
    for (var i = 0; i < n; i++)
      () {
        final a = (i - janela).clamp(0, n), b = (i + janela).clamp(0, n);
        final media = (acumulado[b] - acumulado[a]) / (b - a);
        return px[i] < media - 4;
      }(),
  ];
}

/// Faixas alternadas: (é barra, largura em pixels).
List<(bool, int)> _faixasDe(List<bool> pretos) {
  final faixas = <(bool, int)>[];
  var atual = pretos.first, tamanho = 0;
  for (final p in pretos) {
    if (p == atual) {
      tamanho++;
    } else {
      faixas.add((atual, tamanho));
      atual = p;
      tamanho = 1;
    }
  }
  faixas.add((atual, tamanho));
  return faixas;
}

String? _procurar(List<(bool, int)> faixas) {
  for (var i = 1; i + _faixas <= faixas.length; i++) {
    if (!faixas[i].$1) continue; // começa numa barra (guarda)
    final trecho = faixas.sublist(i, i + _faixas);
    final total = trecho.fold<int>(0, (s, f) => s + f.$2);
    final modulo = total / _modulos;
    if (modulo < 1) continue;
    // Zona de silêncio antes da guarda: pelo menos ~3 módulos de espaço.
    if (faixas[i - 1].$2 < 3 * modulo) continue;
    final r = _decodificar(trecho, modulo);
    if (r != null) return r;
  }
  return null;
}

bool _guarda(List<(bool, int)> fs, double modulo) =>
    fs.every((f) => f.$2 > 0.4 * modulo && f.$2 < 2.0 * modulo);

/// Melhor dígito para 4 larguras: (dígito, é G, erro).
(int, bool, double) _digito(List<int> larguras, {required bool esquerda}) {
  final soma = larguras.fold<int>(0, (s, w) => s + w);
  final normal = [for (final w in larguras) w * 7 / soma];
  var melhor = (-1, false, double.infinity);
  for (var d = 0; d < 10; d++) {
    final l = _padroesL[d];
    for (final g in esquerda ? [false, true] : [false]) {
      final padrao = g ? l.reversed.toList() : l;
      var erro = 0.0;
      for (var k = 0; k < 4; k++) {
        erro += (normal[k] - padrao[k]).abs();
      }
      if (erro < melhor.$3) melhor = (d, g, erro);
    }
  }
  return melhor;
}

String? _decodificar(List<(bool, int)> t, double modulo) {
  if (!_guarda(t.sublist(0, 3), modulo) ||
      !_guarda(t.sublist(27, 32), modulo) ||
      !_guarda(t.sublist(56, 59), modulo)) {
    return null;
  }
  final digitos = <int>[];
  final paridade = StringBuffer();
  for (var k = 0; k < 12; k++) {
    final inicio = k < 6 ? 3 + 4 * k : 32 + 4 * (k - 6);
    final larguras = [for (final f in t.sublist(inicio, inicio + 4)) f.$2];
    final (d, g, erro) = _digito(larguras, esquerda: k < 6);
    if (erro > 1.6) return null;
    digitos.add(d);
    if (k < 6) paridade.write(g ? 'G' : 'L');
  }
  final primeiro = _paridades.indexOf(paridade.toString());
  if (primeiro < 0) return null;
  final codigo = '$primeiro${digitos.join()}';
  return digitoVerificadorOk(codigo) ? codigo : null;
}
