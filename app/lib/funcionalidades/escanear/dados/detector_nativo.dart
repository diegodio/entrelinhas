// Android e iOS: ML Kit (código de barras) e TFLite (capa), fora da thread da interface.
//
// Situação: escrito conforme a documentação dos pacotes e verificado com análise estática
// e testes das partes puras. NÃO foi exercitado num aparelho real neste ambiente; o fluxo
// ao vivo precisa de validação em celular (docs/como-rodar.md, "Scanner").

import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' show Rect, Size;

import 'package:flutter/services.dart' show rootBundle;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as mlkit;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../dominio/deteccao.dart';
import 'detector.dart';

/// Classes do COCO aceitas como "objeto retangular que pode ser a capa". Em fotos de
/// capa vistas de frente, o modelo costuma responder "tv" ou "book" (docs/reconhecimento.md).
const classesDeCapa = {'book', 'tv', 'laptop', 'cell phone'};
const _ladoModelo = 300;
const _pontuacaoMinima = 0.4;

class DetectorNativo implements DetectorDeLivro {
  Interpreter? _interpretador;
  IsolateInterpreter? _isolado;
  List<String> _rotulos = const [];
  final _codigos = mlkit.BarcodeScanner(formats: [mlkit.BarcodeFormat.ean13]);

  @override
  bool get aoVivo => true;

  @override
  Future<void> iniciar() async {
    try {
      _interpretador = await Interpreter.fromAsset(
        'assets/modelos/detector_coco_ssd_mobilenet_v1.tflite',
      );
      _isolado = await IsolateInterpreter.create(address: _interpretador!.address);
      _rotulos = (await rootBundle.loadString('assets/modelos/rotulos_coco.txt'))
          .split('\n')
          .map((l) => l.trim())
          .toList();
    } catch (_) {
      // Sem o modelo, segue só com o código de barras e a captura manual.
      _interpretador = null;
    }
  }

  @override
  Future<Analise> analisar(QuadroCamera q) async {
    // Conversões pesadas num isolate: cinza para nitidez/luz e RGB 300x300 para o modelo.
    final preparo = await Isolate.run(() => _preparar(q));
    final resultados = await Future.wait([
      _detectarCapa(preparo.rgb, q.rotacao),
      _detectarCodigo(q),
    ]);
    return Analise(
      regioes: [...resultados[0], ...resultados[1]],
      nitidez: preparo.nitidez,
      luminancia: preparo.luminancia,
    );
  }

  Future<List<Regiao>> _detectarCapa(Uint8List rgb, int rotacao) async {
    final isolado = _isolado;
    if (isolado == null) return const [];
    final entrada = rgb.reshape([1, _ladoModelo, _ladoModelo, 3]);
    final caixas = List.generate(1, (_) => List.generate(10, (_) => List.filled(4, 0.0)));
    final classes = List.generate(1, (_) => List.filled(10, 0.0));
    final pontos = List.generate(1, (_) => List.filled(10, 0.0));
    final n = List.filled(1, 0.0);
    await isolado.runForMultipleInputs([entrada], {0: caixas, 1: classes, 2: pontos, 3: n});
    final regioes = <Regiao>[];
    for (var i = 0; i < n[0].toInt() && i < 10; i++) {
      final indice = classes[0][i].toInt() + 1; // o rótulo 0 do arquivo é "???"
      final rotulo = indice < _rotulos.length ? _rotulos[indice] : '';
      if (pontos[0][i] < _pontuacaoMinima || !classesDeCapa.contains(rotulo)) continue;
      final b = caixas[0][i]; // [ymin, xmin, ymax, xmax] no quadro do sensor
      final caixa = rodarCaixa(Rect.fromLTRB(b[1], b[0], b[3], b[2]), rotacao);
      final proporcao = caixa.width / (caixa.height == 0 ? 1 : caixa.height);
      if (proporcao < 0.35 || proporcao > 2.8 || caixa.width * caixa.height < 0.03) continue;
      regioes.add(Regiao(tipo: TipoRegiao.capa, caixa: caixa, confianca: pontos[0][i]));
    }
    return regioes;
  }

  Future<List<Regiao>> _detectarCodigo(QuadroCamera q) async {
    final InputImageAdaptado entrada;
    try {
      entrada = InputImageAdaptado.de(q);
    } catch (_) {
      return const [];
    }
    final lidos = await _codigos.processImage(entrada.imagem);
    final larg = entrada.larguraEmPe, alt = entrada.alturaEmPe;
    return [
      for (final c in lidos)
        Regiao(
          tipo: TipoRegiao.codigoDeBarras,
          caixa: Rect.fromLTRB(
            c.boundingBox.left / larg,
            c.boundingBox.top / alt,
            c.boundingBox.right / larg,
            c.boundingBox.bottom / alt,
          ),
          confianca: 1,
          valor: c.rawValue,
        ),
    ];
  }

  @override
  Future<void> encerrar() async {
    await _codigos.close();
    _isolado?.close();
    _interpretador?.close();
  }
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

/// Leva uma caixa normalizada do quadro do sensor para o quadro "em pé" da tela.
Rect rodarCaixa(Rect c, int rotacao) => switch (rotacao) {
  90 => Rect.fromLTRB(1 - c.bottom, c.left, 1 - c.top, c.right),
  180 => Rect.fromLTRB(1 - c.right, 1 - c.bottom, 1 - c.left, 1 - c.top),
  270 => Rect.fromLTRB(c.top, 1 - c.right, c.bottom, 1 - c.left),
  _ => c,
};

class _Preparo {
  const _Preparo(this.rgb, this.nitidez, this.luminancia);
  final Uint8List rgb;
  final double nitidez;
  final double luminancia;
}

/// Roda no isolate: luminância/nitidez numa miniatura cinza e RGB 300x300 para o modelo.
_Preparo _preparar(QuadroCamera q) {
  const lc = 160;
  final ac = (lc * q.altura / q.largura).round().clamp(1, 1000);
  final cinza = Uint8List(lc * ac);
  for (var y = 0; y < ac; y++) {
    for (var x = 0; x < lc; x++) {
      cinza[y * lc + x] = _luma(q, x * q.largura ~/ lc, y * q.altura ~/ ac);
    }
  }
  final rgb = Uint8List(_ladoModelo * _ladoModelo * 3);
  var i = 0;
  for (var y = 0; y < _ladoModelo; y++) {
    final sy = y * q.altura ~/ _ladoModelo;
    for (var x = 0; x < _ladoModelo; x++) {
      final sx = x * q.largura ~/ _ladoModelo;
      final (r, g, b) = _rgb(q, sx, sy);
      rgb[i++] = r;
      rgb[i++] = g;
      rgb[i++] = b;
    }
  }
  return _Preparo(rgb, nitidezLaplaciano(cinza, lc, ac, passo: 1), luminanciaMedia(cinza));
}

int _luma(QuadroCamera q, int x, int y) {
  final p0 = q.planos[0];
  if (q.formato == FormatoQuadro.bgra8888) {
    final o = y * p0.bytesPorLinha + x * 4;
    return ((p0.bytes[o] * 29 + p0.bytes[o + 1] * 150 + p0.bytes[o + 2] * 77) >> 8);
  }
  return p0.bytes[y * p0.bytesPorLinha + x];
}

(int, int, int) _rgb(QuadroCamera q, int x, int y) {
  if (q.formato == FormatoQuadro.bgra8888) {
    final p = q.planos[0];
    final o = y * p.bytesPorLinha + x * 4;
    return (p.bytes[o + 2], p.bytes[o + 1], p.bytes[o]);
  }
  final yy = _luma(q, x, y);
  int u, v;
  if (q.formato == FormatoQuadro.nv21) {
    // Plano único: Y (largura x altura) seguido de VU intercalado em meia resolução.
    final p = q.planos[0];
    final base = q.altura * p.bytesPorLinha + (y ~/ 2) * p.bytesPorLinha + (x ~/ 2) * 2;
    if (base + 1 >= p.bytes.length) return (yy, yy, yy);
    v = p.bytes[base];
    u = p.bytes[base + 1];
  } else {
    final pu = q.planos[1], pv = q.planos[2];
    final passo = pu.bytesPorPixel ?? 1;
    final o = (y ~/ 2) * pu.bytesPorLinha + (x ~/ 2) * passo;
    if (o >= pu.bytes.length || o >= pv.bytes.length) return (yy, yy, yy);
    u = pu.bytes[o];
    v = pv.bytes[o];
  }
  final c = yy - 16, d = u - 128, e = v - 128;
  int limitar(num n) => n < 0 ? 0 : (n > 255 ? 255 : n.toInt());
  return (
    limitar((298 * c + 409 * e + 128) >> 8),
    limitar((298 * c - 100 * d - 208 * e + 128) >> 8),
    limitar((298 * c + 516 * d + 128) >> 8),
  );
}

DetectorDeLivro criarDetectorDaPlataforma() => DetectorNativo();
