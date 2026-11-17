import 'package:material_ui/material_ui.dart';

import '../../../l10n/textos.dart';
import '../../../nucleo/tema/tema.dart';
import '../dominio/maquina_scanner.dart';

bool mostrarGuia(EstadoScanner estado, bool aoVivo) =>
    !aoVivo || estado.regiao == null || estado.fase == FaseScanner.procurando;

/// Moldura-guia no espaço da TELA (a prévia pode estar cortada nas laterais).
class MolduraGuia extends StatelessWidget {
  const MolduraGuia({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: Textos.of(context).enquadre,
    child: CustomPaint(painter: _Pintor(guia: true, caixa: null, cor: Colors.white)),
  );
}

/// Contorno que acompanha o livro, no espaço da PRÉVIA. Passa do branco para a cor de
/// marca conforme a estabilização avança.
class SobreposicaoScanner extends StatelessWidget {
  const SobreposicaoScanner({
    super.key,
    required this.estado,
    required this.progresso,
    required this.aoVivo,
  });

  final EstadoScanner estado;
  final double progresso;
  final bool aoVivo;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final regiao = estado.regiao?.caixa;
    if (mostrarGuia(estado, aoVivo)) return const SizedBox.expand();
    final cor = Color.lerp(Colors.white, cores.faixas['Livre']!, progresso)!;
    return Semantics(
      label: null,
      child: CustomPaint(
        painter: _Pintor(
          guia: false,
          caixa: regiao,
          cor: estado.fase == FaseScanner.capturando || estado.fase == FaseScanner.enviando
              ? cores.faixas['Livre']!
              : cor,
        ),
      ),
    );
  }
}

class _Pintor extends CustomPainter {
  _Pintor({required this.guia, required this.caixa, required this.cor});
  final bool guia;
  final Rect? caixa;
  final Color cor;

  @override
  void paint(Canvas canvas, Size s) {
    final traco = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.shortestSide * 0.012
      ..color = cor;
    if (guia || caixa == null) {
      // Moldura no formato de um livro em pé (2:3), com cantos marcados.
      final h = (s.width * 0.66 * 1.45).clamp(0.0, s.height * 0.8);
      final w = h / 1.45;
      final r = Rect.fromCenter(center: s.center(Offset.zero), width: w, height: h);
      final canto = w * 0.12;
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
      canvas.drawPath(p, traco..color = Colors.white);
      return;
    }
    final r = Rect.fromLTRB(
      caixa!.left * s.width,
      caixa!.top * s.height,
      caixa!.right * s.width,
      caixa!.bottom * s.height,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(s.shortestSide * 0.02)), traco);
  }

  @override
  bool shouldRepaint(_Pintor velho) =>
      velho.guia != guia || velho.caixa != caixa || velho.cor != cor;
}
