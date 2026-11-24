// Android e iOS: leitura do EAN-13 ao vivo com o ML Kit.
//
// Situação: escrito conforme a documentação do pacote e verificado com análise estática
// e testes das partes puras. NÃO foi exercitado num aparelho real neste ambiente; o fluxo
// ao vivo precisa de validação em celular (docs/como-rodar.md, "Scanner em aparelho").

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' show Rect, Size;

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as mlkit;

import '../dominio/maquina_scanner.dart';
import 'leitor.dart';

class LeitorNativo implements LeitorDeCodigo {
  final _codigos = mlkit.BarcodeScanner(formats: [mlkit.BarcodeFormat.ean13]);

  @override
  bool get aoVivo => true;

  @override
  Future<void> iniciar() async {}

  @override
  Future<Analise> analisar(QuadroCamera q) async {
    final InputImageAdaptado entrada;
    try {
      entrada = InputImageAdaptado.de(q);
    } catch (_) {
      return Analise.vazia;
    }
    final lidos = await _codigos.processImage(entrada.imagem);
    final larg = entrada.larguraEmPe, alt = entrada.alturaEmPe;
    return Analise(
      codigos: [
        for (final c in lidos)
          CodigoLido(
            caixa: Rect.fromLTRB(
              c.boundingBox.left / larg,
              c.boundingBox.top / alt,
              c.boundingBox.right / larg,
              c.boundingBox.bottom / alt,
            ),
            valor: c.rawValue,
          ),
      ],
      luminancia: luminanciaDoQuadro(q),
    );
  }

  @override
  Future<void> encerrar() => _codigos.close();
}

/// Converte o QuadroCamera no InputImage do ML Kit.
class InputImageAdaptado {
  InputImageAdaptado._(this.imagem, this.larguraEmPe, this.alturaEmPe);
  final mlkit.InputImage imagem;
  final double larguraEmPe;
  final double alturaEmPe;

  factory InputImageAdaptado.de(QuadroCamera q) {
    final rotacao =
        mlkit.InputImageRotationValue.fromRawValue(q.rotacao) ??
        mlkit.InputImageRotation.rotation0deg;
    final formato = switch (q.formato) {
      FormatoQuadro.nv21 => mlkit.InputImageFormat.nv21,
      FormatoQuadro.bgra8888 => mlkit.InputImageFormat.bgra8888,
      FormatoQuadro.yuv420 => mlkit.InputImageFormat.yuv420,
    };
    final bytes = q.planos.length == 1
        ? q.planos.first.bytes
        : Uint8List.fromList([for (final p in q.planos) ...p.bytes]);
    final imagem = mlkit.InputImage.fromBytes(
      bytes: bytes,
      metadata: mlkit.InputImageMetadata(
        size: Size(q.largura.toDouble(), q.altura.toDouble()),
        rotation: rotacao,
        format: formato,
        bytesPerRow: q.planos.first.bytesPorLinha,
      ),
    );
    final emPe = q.rotacao == 90 || q.rotacao == 270;
    return InputImageAdaptado._(
      imagem,
      (emPe ? q.altura : q.largura).toDouble(),
      (emPe ? q.largura : q.altura).toDouble(),
    );
  }
}

/// Média de luminância numa grade esparsa do quadro (barato o bastante para cada análise).
double luminanciaDoQuadro(QuadroCamera q, {int amostras = 24}) {
  var soma = 0, n = 0;
  for (var j = 0; j < amostras; j++) {
    for (var i = 0; i < amostras; i++) {
      soma += _luma(q, (i + 0.5) * q.largura ~/ amostras, (j + 0.5) * q.altura ~/ amostras);
      n++;
    }
  }
  return n == 0 ? 0 : soma / n;
}

int _luma(QuadroCamera q, int x, int y) {
  final p0 = q.planos[0];
  if (q.formato == FormatoQuadro.bgra8888) {
    final o = y * p0.bytesPorLinha + x * 4;
    return ((p0.bytes[o] * 29 + p0.bytes[o + 1] * 150 + p0.bytes[o + 2] * 77) >> 8);
  }
  return p0.bytes[y * p0.bytesPorLinha + x];
}

LeitorDeCodigo criarLeitorDaPlataforma() => LeitorNativo();
