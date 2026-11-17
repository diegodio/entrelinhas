// Recorte e compressão da captura, fora da thread da interface (package:image, puro Dart).
// `compute` usa um isolate no celular; na web (sem isolates) roda no próprio fluxo.

import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;

/// Endireita pela orientação EXIF, recorta a região normalizada (se houver), reduz para
/// ~1024 px no maior lado e comprime em JPEG. O que sai do celular é o livro, não a cena.
Future<Uint8List> prepararEnvio(Uint8List bytes, {Rect? regiao, int ladoMaximo = 1024}) =>
    compute(_preparar, (
      bytes,
      regiao == null ? null : [regiao.left, regiao.top, regiao.width, regiao.height],
      ladoMaximo,
    ));

Uint8List _preparar((Uint8List, List<double>?, int) args) {
  final (bytes, r, ladoMaximo) = args;
  final regiao = r == null ? null : Rect.fromLTWH(r[0], r[1], r[2], r[3]);
  final decodificada = img.decodeImage(bytes);
  if (decodificada == null) throw const FormatException('Imagem ilegível.');
  var foto = img.bakeOrientation(decodificada);
  if (regiao != null) {
    final x = (regiao.left * foto.width).round().clamp(0, foto.width - 1);
    final y = (regiao.top * foto.height).round().clamp(0, foto.height - 1);
    final w = (regiao.width * foto.width).round().clamp(1, foto.width - x);
    final h = (regiao.height * foto.height).round().clamp(1, foto.height - y);
    foto = img.copyCrop(foto, x: x, y: y, width: w, height: h);
  }
  final maior = foto.width > foto.height ? foto.width : foto.height;
  if (maior > ladoMaximo) {
    foto = foto.width >= foto.height
        ? img.copyResize(foto, width: ladoMaximo)
        : img.copyResize(foto, height: ladoMaximo);
  }
  return Uint8List.fromList(img.encodeJpg(foto, quality: 85));
}
