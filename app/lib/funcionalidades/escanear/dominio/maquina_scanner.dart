// Máquina de estados do scanner (seção 6.4). Pura: sem câmera, sem relógio próprio.
//
// procurando -> detectado -> estavel -> capturando -> enviando -> resultado
//                     \________________________________________/-> erro
//
// A captura dispara quando o contorno fica estável por ~0,7 s, ocupa parte razoável do
// quadro e a imagem está nítida. A captura manual está sempre disponível.

import 'dart:ui' show Offset, Rect;

import 'deteccao.dart';

enum FaseScanner { procurando, detectado, estavel, capturando, enviando, resultado, erro }

class ParametrosScanner {
  const ParametrosScanner({
    this.tempoEstavel = const Duration(milliseconds: 700),
    this.areaMinima = 0.12,
    this.areaMinimaCodigo = 0.015,
    this.iouMinimo = 0.75,
    this.nitidezMinima = 60,
    this.luminanciaBaixa = 45,
    this.tolerancia = const Duration(milliseconds: 350),
  });

  final Duration tempoEstavel;

  /// Fração mínima do quadro que a capa deve ocupar.
  final double areaMinima;

  /// Códigos de barras são pequenos: limite próprio.
  final double areaMinimaCodigo;

  /// Quanto a caixa pode mudar entre quadros e ainda contar como "parada".
  final double iouMinimo;
  final double nitidezMinima;
  final double luminanciaBaixa;

  /// Quadros sem detecção tolerados antes de voltar a procurar (evita piscar).
  final Duration tolerancia;
}

class EstadoScanner {
  const EstadoScanner({
    required this.fase,
    this.regiao,
    this.estavelDesde,
    this.ultimaDeteccao,
    this.poucaLuz = false,
    this.variasRegioes = false,
    this.toque,
    this.mensagemErro,
  });

  final FaseScanner fase;
  final Regiao? regiao;
  final Duration? estavelDesde;
  final Duration? ultimaDeteccao;
  final bool poucaLuz;
  final bool variasRegioes;
  final Offset? toque;
  final String? mensagemErro;

  static const inicial = EstadoScanner(fase: FaseScanner.procurando);

  bool get analisando =>
      fase == FaseScanner.procurando ||
      fase == FaseScanner.detectado ||
      fase == FaseScanner.estavel;

  /// Progresso da estabilização (0 a 1), para o contorno mudar de cor aos poucos.
  double progresso(Duration agora, ParametrosScanner p) {
    if (estavelDesde == null) return 0;
    return ((agora - estavelDesde!).inMilliseconds / p.tempoEstavel.inMilliseconds).clamp(0.0, 1.0);
  }

  EstadoScanner copiar({
    FaseScanner? fase,
    Regiao? regiao,
    bool limparRegiao = false,
    Duration? estavelDesde,
    bool limparEstavel = false,
    Duration? ultimaDeteccao,
    bool? poucaLuz,
    bool? variasRegioes,
    Offset? toque,
    bool limparToque = false,
    String? mensagemErro,
  }) => EstadoScanner(
    fase: fase ?? this.fase,
    regiao: limparRegiao ? null : (regiao ?? this.regiao),
    estavelDesde: limparEstavel ? null : (estavelDesde ?? this.estavelDesde),
    ultimaDeteccao: ultimaDeteccao ?? this.ultimaDeteccao,
    poucaLuz: poucaLuz ?? this.poucaLuz,
    variasRegioes: variasRegioes ?? this.variasRegioes,
    toque: limparToque ? null : (toque ?? this.toque),
    mensagemErro: mensagemErro,
  );
}

/// Transições puras. [agora] é o tempo desde o início da sessão de câmera.
class MaquinaScanner {
  const MaquinaScanner([this.p = const ParametrosScanner()]);
  final ParametrosScanner p;

  bool _grandeOSuficiente(Regiao r) =>
      r.area >= (r.tipo == TipoRegiao.codigoDeBarras ? p.areaMinimaCodigo : p.areaMinima);

  /// Novo quadro analisado.
  EstadoScanner aoAnalisar(EstadoScanner e, Analise a, Duration agora) {
    if (!e.analisando) return e; // capturando/enviando/resultado: ignora quadros
    final poucaLuz = a.luminancia < p.luminanciaBaixa;
    final principal = escolherPrincipal(a.regioes, toque: e.toque);
    final varias = a.regioes.where((r) => r.tipo == TipoRegiao.capa).length > 1;

    if (principal == null) {
      // Tolera falhas curtas do detector antes de voltar a procurar.
      final perdeu = e.ultimaDeteccao == null || agora - e.ultimaDeteccao! > p.tolerancia;
      if (perdeu) {
        return EstadoScanner(fase: FaseScanner.procurando, poucaLuz: poucaLuz, toque: e.toque);
      }
      return e.copiar(poucaLuz: poucaLuz);
    }

    final parado =
        e.regiao != null &&
        e.regiao!.tipo == principal.tipo &&
        iou(e.regiao!.caixa, principal.caixa) >= p.iouMinimo;
    final apto = _grandeOSuficiente(principal) && a.nitidez >= p.nitidezMinima;
    // Código de barras já decodificado no aparelho: não precisa esperar.
    if (principal.valor != null) {
      return e.copiar(
        fase: FaseScanner.capturando,
        regiao: principal,
        ultimaDeteccao: agora,
        poucaLuz: poucaLuz,
        variasRegioes: varias,
      );
    }
    if (!apto) {
      return e.copiar(
        fase: FaseScanner.detectado,
        regiao: principal,
        limparEstavel: true,
        ultimaDeteccao: agora,
        poucaLuz: poucaLuz,
        variasRegioes: varias,
      );
    }
    final desde = parado && e.estavelDesde != null ? e.estavelDesde! : agora;
    final pronto = agora - desde >= p.tempoEstavel;
    return e.copiar(
      fase: pronto ? FaseScanner.capturando : FaseScanner.estavel,
      regiao: principal,
      estavelDesde: desde,
      ultimaDeteccao: agora,
      poucaLuz: poucaLuz,
      variasRegioes: varias,
    );
  }

  /// Toque na tela: escolhe outro livro quando há vários.
  EstadoScanner aoTocar(EstadoScanner e, Offset pontoNormalizado) =>
      e.analisando ? e.copiar(toque: pontoNormalizado, limparEstavel: true) : e;

  /// Botão de captura manual: sempre disponível enquanto a câmera analisa.
  EstadoScanner aoCapturarManual(EstadoScanner e) =>
      e.analisando ? e.copiar(fase: FaseScanner.capturando) : e;

  EstadoScanner aoEnviar(EstadoScanner e) => e.copiar(fase: FaseScanner.enviando);

  EstadoScanner aoReceberResultado(EstadoScanner e) => e.copiar(fase: FaseScanner.resultado);

  EstadoScanner aoFalhar(EstadoScanner e, String mensagem) =>
      e.copiar(fase: FaseScanner.erro, mensagemErro: mensagem);

  /// Voltar a escanear (depois de erro, "Não é este" etc.).
  EstadoScanner reiniciar(EstadoScanner e) =>
      EstadoScanner(fase: FaseScanner.procurando, poucaLuz: e.poucaLuz);
}

/// Região a recortar da foto, com margem, em coordenadas normalizadas.
Rect recorteComMargem(Rect caixa, {double margem = 0.06}) {
  final dx = caixa.width * margem, dy = caixa.height * margem;
  return Rect.fromLTRB(
    (caixa.left - dx).clamp(0.0, 1.0),
    (caixa.top - dy).clamp(0.0, 1.0),
    (caixa.right + dx).clamp(0.0, 1.0),
    (caixa.bottom + dy).clamp(0.0, 1.0),
  );
}
