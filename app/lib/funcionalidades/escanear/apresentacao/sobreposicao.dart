import 'package:material_ui/material_ui.dart';

import '../../../l10n/textos.dart';
import '../../../nucleo/tema/tema.dart';
import '../dominio/maquina_scanner.dart';

/// A moldura-guia aparece enquanto nenhum código está sendo acompanhado.
bool mostrarGuia(EstadoScanner estado, bool aoVivo) => !aoVivo || estado.caixa == null;

/// Moldura-guia no espaço da TELA (a prévia pode estar cortada nas laterais), no formato
/// de um código de barras deitado.
class MolduraGuia extends StatelessWidget {
  const MolduraGuia({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: Textos.of(context).enquadre,
    child: CustomPaint(painter: _Pintor(caixa: null, cor: Colors.white)),
  );
}

/// Contorno que acompanha o código, no espaço da PRÉVIA: branco quando visto, na cor de
/// marca quando lido como ISBN, em tom de alerta quando o código não é de livro.
class SobreposicaoScanner extends StatelessWidget {
  const SobreposicaoScanner({super.key, required this.estado, required this.aoVivo});

  final EstadoScanner estado;
  final bool aoVivo;

  @override
  Widget build(BuildContext context) {
    final caixa = estado.caixa;
    if (mostrarGuia(estado, aoVivo) || caixa == null) return const SizedBox.expand();
    final cores = context.cores;
    final cor = estado.fase == FaseScanner.consultando
        ? cores.faixas['Livre']!
        : (estado.naoELivro ? cores.alertaForte : Colors.white);
    return CustomPaint(
      painter: _Pintor(caixa: caixa, cor: cor),
    );
  }
}

class _Pintor extends CustomPainter {
  _Pintor({required this.caixa, required this.cor});
  final Rect? caixa;
  final Color cor;

  @override
  void paint(Canvas canvas, Size s) {
    final traco = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.shortestSide * 0.012
      ..color = cor;
    if (caixa == null) {
      // Retângulo deitado (~2:1), com cantos marcados.
      final w = s.width * 0.78;
      final h = (w * 0.5).clamp(0.0, s.height * 0.5);
      final r = Rect.fromCenter(center: s.center(Offset.zero), width: w, height: h);
      final canto = h * 0.22;
      final p = Path();
      for (final (c, dx, dy) in [
        (r.topLeft, 1.0, 1.0),
        (r.topRight, -1.0, 1.0),
        (r.bottomRight, -1.0, -1.0),
        (r.bottomLeft, 1.0, -1.0),
      ]) {
        p
          ..moveTo(c.dx + dx * canto, c.dy)
          ..lineTo(c.dx, c.dy)
          ..lineTo(c.dx, c.dy + dy * canto);
      }
      canvas.drawPath(p, traco);
      return;
    }
    final r = Rect.fromLTRB(
      caixa!.left * s.width,
      caixa!.top * s.height,
      caixa!.right * s.width,
      caixa!.bottom * s.height,
    ).inflate(s.shortestSide * 0.02);
    canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(s.shortestSide * 0.02)), traco);
  }

  @override
  bool shouldRepaint(_Pintor velho) => velho.caixa != caixa || velho.cor != cor;
}
