// Compressão da foto enviada ao servidor, fora da thread da interface (package:image).
// `compute` usa um isolate no celular; na web (sem isolates) roda no próprio fluxo.

import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;

/// Endireita pela orientação EXIF, reduz para ~1600 px no maior lado (o código de barras
/// costuma ocupar pouco da foto) e comprime em JPEG.
Future<Uint8List> prepararEnvio(Uint8List bytes, {int ladoMaximo = 1600}) =>
    compute(_preparar, (bytes, ladoMaximo));

Uint8List _preparar((Uint8List, int) args) {
  final (bytes, ladoMaximo) = args;
  final decodificada = img.decodeImage(bytes);
  if (decodificada == null) throw const FormatException('Imagem ilegível.');
  var foto = img.bakeOrientation(decodificada);
  final maior = foto.width > foto.height ? foto.width : foto.height;
  if (maior > ladoMaximo) {
    foto = foto.width >= foto.height
        ? img.copyResize(foto, width: ladoMaximo)
        : img.copyResize(foto, height: ladoMaximo);
  }
  return Uint8List.fromList(img.encodeJpg(foto, quality: 88));
}
