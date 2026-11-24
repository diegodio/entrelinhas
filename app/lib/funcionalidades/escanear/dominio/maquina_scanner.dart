// Máquina de estados do scanner de código de barras. Pura: sem câmera, sem relógio próprio.
//
// procurando -> consultando -> resultado
//      ^             \-> erro
//      '-- reiniciar --'
//
// No celular, o ML Kit decodifica o EAN-13 ao vivo: se for ISBN de livro, consulta na
// hora. Na web (ou quando o código não é lido ao vivo), a captura é manual e o servidor
// lê o código na foto.

import 'dart:ui' show Rect;

/// Código de barras visto num quadro, com caixa normalizada (0 a 1) na orientação da tela.
class CodigoLido {
  const CodigoLido({required this.caixa, this.valor});
  final Rect caixa;

  /// Texto decodificado; null quando o detector viu o código mas não conseguiu ler.
  final String? valor;
}

/// Resultado da análise de um quadro.
class Analise {
  const Analise({this.codigos = const [], this.luminancia = 128});
  final List<CodigoLido> codigos;

  /// Média de luminância (0 a 255): abaixo do limite, sugerir a lanterna.
  final double luminancia;

  static const vazia = Analise();
}

/// EAN-13 com dígito verificador correto e prefixo de livro (978/979), como no servidor.
bool eIsbnDeLivro(String? codigo) {
  if (codigo == null || !RegExp(r'^(978|979)\d{10}$').hasMatch(codigo)) return false;
  var soma = 0;
  for (var i = 0; i < 12; i++) {
    soma += int.parse(codigo[i]) * (i.isEven ? 1 : 3);
  }
  return (10 - soma % 10) % 10 == int.parse(codigo[12]);
}

enum FaseScanner { procurando, consultando, resultado, erro }

class ParametrosScanner {
  const ParametrosScanner({
    this.luminanciaBaixa = 45,
    this.tolerancia = const Duration(milliseconds: 600),
  });

  final double luminanciaBaixa;

  /// Tempo sem ver o código antes de apagar a caixa (evita piscar).
  final Duration tolerancia;
}

class EstadoScanner {
  const EstadoScanner({
    required this.fase,
    this.caixa,
    this.isbn,
    this.naoELivro = false,
    this.poucaLuz = false,
    this.ultimaDeteccao,
    this.mensagemErro,
  });

  final FaseScanner fase;

  /// Caixa do código visto por último (para desenhar o contorno).
  final Rect? caixa;

  /// ISBN lido ao vivo; null na captura manual (o servidor lê na foto).
  final String? isbn;

  /// O código visto é um EAN, mas não de livro (produto, revista etc.).
  final bool naoELivro;
  final bool poucaLuz;
  final Duration? ultimaDeteccao;
  final String? mensagemErro;

  static const inicial = EstadoScanner(fase: FaseScanner.procurando);

  bool get analisando => fase == FaseScanner.procurando;
}

class MaquinaScanner {
  const MaquinaScanner([this.p = const ParametrosScanner()]);
  final ParametrosScanner p;

  /// Novo quadro analisado. [agora] é o tempo desde o início da sessão de câmera.
  EstadoScanner aoAnalisar(EstadoScanner e, Analise a, Duration agora) {
    if (!e.analisando) return e; // consultando/resultado/erro: ignora quadros
    final poucaLuz = a.luminancia < p.luminanciaBaixa;
    for (final c in a.codigos) {
      if (eIsbnDeLivro(c.valor)) {
        return EstadoScanner(
          fase: FaseScanner.consultando,
          caixa: c.caixa,
          isbn: c.valor,
          poucaLuz: poucaLuz,
          ultimaDeteccao: agora,
        );
      }
    }
    if (a.codigos.isNotEmpty) {
      final c = a.codigos.first;
      return EstadoScanner(
        fase: FaseScanner.procurando,
        caixa: c.caixa,
        naoELivro: a.codigos.any((c) => c.valor != null),
        poucaLuz: poucaLuz,
        ultimaDeteccao: agora,
      );
    }
    final perdeu = e.ultimaDeteccao == null || agora - e.ultimaDeteccao! > p.tolerancia;
    if (perdeu) return EstadoScanner(fase: FaseScanner.procurando, poucaLuz: poucaLuz);
    return EstadoScanner(
      fase: FaseScanner.procurando,
      caixa: e.caixa,
      naoELivro: e.naoELivro,
      poucaLuz: poucaLuz,
      ultimaDeteccao: e.ultimaDeteccao,
    );
  }

  /// Botão de captura: sempre disponível enquanto a câmera analisa.
  EstadoScanner aoCapturarManual(EstadoScanner e) =>
      e.analisando ? EstadoScanner(fase: FaseScanner.consultando, poucaLuz: e.poucaLuz) : e;

  EstadoScanner aoReceberResultado(EstadoScanner e) =>
      EstadoScanner(fase: FaseScanner.resultado, isbn: e.isbn, poucaLuz: e.poucaLuz);

  EstadoScanner aoFalhar(EstadoScanner e, String mensagem) => EstadoScanner(
    fase: FaseScanner.erro,
    isbn: e.isbn,
    poucaLuz: e.poucaLuz,
    mensagemErro: mensagem,
  );

  /// Voltar a escanear (depois de erro ou ao voltar da ficha).
  EstadoScanner reiniciar(EstadoScanner e) =>
      EstadoScanner(fase: FaseScanner.procurando, poucaLuz: e.poucaLuz);
}
