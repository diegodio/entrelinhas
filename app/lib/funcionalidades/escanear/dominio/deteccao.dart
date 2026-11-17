// Tipos da detecção no aparelho e funções puras (nitidez, escolha da região principal).

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Offset, Rect;

enum TipoRegiao { capa, codigoDeBarras }

/// Região detectada num quadro, com coordenadas normalizadas (0 a 1) no quadro já rodado
/// para a orientação da tela.
class Regiao {
  const Regiao({required this.tipo, required this.caixa, required this.confianca, this.valor});

  final TipoRegiao tipo;
  final Rect caixa;
  final double confianca;

  /// Valor lido (ISBN) quando o detector de código conseguiu decodificar.
  final String? valor;

  double get area => caixa.width * caixa.height;
}

/// Quadro analisado: regiões encontradas e nitidez (variância do laplaciano).
class Analise {
  const Analise({required this.regioes, required this.nitidez, this.luminancia = 128});
  final List<Regiao> regioes;
  final double nitidez;

  /// Média de luminância (0 a 255): abaixo de ~50, sugerir a lanterna.
  final double luminancia;

  static const vazia = Analise(regioes: [], nitidez: 0);
}

/// Interseção sobre união entre duas caixas (estabilidade do contorno).
double iou(Rect a, Rect b) {
  final i = a.intersect(b);
  if (i.width <= 0 || i.height <= 0) return 0;
  final inter = i.width * i.height;
  return inter / (a.width * a.height + b.width * b.height - inter);
}

/// Escolhe a região principal: com toque, a que contém o ponto; sem toque, o código
/// de barras lido (se houver) ou a maior e mais central.
Regiao? escolherPrincipal(List<Regiao> regioes, {Offset? toque}) {
  if (regioes.isEmpty) return null;
  if (toque != null) {
    final tocadas = regioes.where((r) => r.caixa.contains(toque)).toList();
    if (tocadas.isNotEmpty) {
      tocadas.sort((a, b) => a.area.compareTo(b.area)); // a mais específica
      return tocadas.first;
    }
  }
  final lidos = regioes.where((r) => r.valor != null).toList();
  if (lidos.isNotEmpty) return lidos.first;
  double nota(Regiao r) {
    final centro = r.caixa.center;
    final distancia = (centro - const Offset(0.5, 0.5)).distance; // 0 a ~0.7
    return r.area * (1 - distancia) * r.confianca;
  }

  return regioes.reduce((a, b) => nota(a) >= nota(b) ? a : b);
}

/// Variância do laplaciano numa imagem em tons de cinza (medida simples de foco).
/// [passo] subamostra para caber no orçamento de tempo por quadro.
double nitidezLaplaciano(Uint8List cinza, int largura, int altura, {int passo = 2}) {
  var soma = 0.0, soma2 = 0.0;
  var n = 0;
  for (var y = passo; y < altura - passo; y += passo) {
    final linha = y * largura;
    for (var x = passo; x < largura - passo; x += passo) {
      final c = cinza[linha + x];
      final l =
          cinza[linha + x - passo] +
          cinza[linha + x + passo] +
          cinza[linha - passo * largura + x] +
          cinza[linha + passo * largura + x] -
          4 * c;
      soma += l;
      soma2 += l * l;
      n++;
    }
  }
  if (n == 0) return 0;
  final media = soma / n;
  return math.max(0, soma2 / n - media * media);
}

double luminanciaMedia(Uint8List cinza, {int passo = 16}) {
  if (cinza.isEmpty) return 0;
  var soma = 0, n = 0;
  for (var i = 0; i < cinza.length; i += passo) {
    soma += cinza[i];
    n++;
  }
  return soma / n;
}
