// Interface do leitor de código de barras no aparelho. Implementações por plataforma:
//   - nativa (Android/iOS): ML Kit, EAN-13, ao vivo;
//   - web: sem análise ao vivo (captura manual; o servidor lê o código na foto).
// Os testes usam um detector falso.

import 'dart:typed_data';

import '../dominio/maquina_scanner.dart';
import 'leitor_web.dart' if (dart.library.ffi) 'leitor_nativo.dart' as plataforma;

/// Formato dos bytes do quadro vindo da câmera.
enum FormatoQuadro { nv21, yuv420, bgra8888 }

class PlanoQuadro {
  const PlanoQuadro({required this.bytes, required this.bytesPorLinha, this.bytesPorPixel});
  final Uint8List bytes;
  final int bytesPorLinha;
  final int? bytesPorPixel;
}

/// Quadro de câmera independente do pacote `camera` (testável).
class QuadroCamera {
  const QuadroCamera({
    required this.largura,
    required this.altura,
    required this.formato,
    required this.planos,
    required this.rotacao,
  });

  final int largura;
  final int altura;
  final FormatoQuadro formato;
  final List<PlanoQuadro> planos;

  /// Graus para deixar o quadro em pé (orientação do sensor): 0, 90, 180 ou 270.
  final int rotacao;
}

abstract interface class LeitorDeCodigo {
  /// Se analisa quadros ao vivo. Na web, false: só captura manual.
  bool get aoVivo;
  Future<void> iniciar();
  Future<Analise> analisar(QuadroCamera quadro);
  Future<void> encerrar();
}

LeitorDeCodigo criarLeitor() => plataforma.criarLeitorDaPlataforma();

class LeitorFalso implements LeitorDeCodigo {
  LeitorFalso([this.respostas = const []]);
  final List<Analise> respostas;
  int _i = 0;

  @override
  bool get aoVivo => true;
  @override
  Future<void> iniciar() async {}
  @override
  Future<Analise> analisar(QuadroCamera quadro) async =>
      respostas.isEmpty ? Analise.vazia : respostas[_i++ % respostas.length];
  @override
  Future<void> encerrar() async {}
}
