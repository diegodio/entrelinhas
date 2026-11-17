import 'package:material_ui/material_ui.dart';

import '../../l10n/textos.dart';
import '../tema/tema.dart';

/// Selo de faixa. A faixa nunca é comunicada só pela cor: o selo sempre traz o texto.
class SeloFaixa extends StatelessWidget {
  const SeloFaixa({super.key, required this.faixa, this.tamanho = 76});

  /// Ficha: 76. Cartões: 48.
  final String faixa;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final texto = faixa == 'Livre' ? Textos.of(context).faixaLivre : faixa;
    return Semantics(
      label: Textos.of(context).semanticaSelo(texto),
      excludeSemantics: true,
      child: Container(
        width: tamanho,
        height: tamanho,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: c.corDaFaixa(faixa), shape: BoxShape.circle),
        child: FittedBox(
          child: Padding(
            padding: EdgeInsets.all(tamanho * 0.14),
            child: Text(
              texto,
              textScaler: TextScaler.noScaling, // o selo escala pelo próprio tamanho
              style: TextStyle(
                fontFamily: Fontes.editorial,
                fontWeight: FontWeight.w600,
                fontSize: tamanho * (texto.length > 3 ? 0.27 : 0.37),
                color: c.sobreFaixa,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Versão em pílula com contorno, para listas.
class PilulaFaixa extends StatelessWidget {
  const PilulaFaixa({super.key, required this.faixa});
  final String faixa;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final cor = c.corDaFaixa(faixa);
    final texto = faixa == 'Livre' ? Textos.of(context).faixaLivre : faixa;
    return Semantics(
      label: Textos.of(context).semanticaSelo(texto),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Espaco.s, vertical: Espaco.xxs),
        decoration: BoxDecoration(
          border: Border.all(color: cor, width: 1.5),
          borderRadius: BorderRadius.circular(Raio.pilula),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontFamily: Fontes.editorial,
            fontWeight: FontWeight.w600,
            fontSize: Tamanhos.corpo,
            color: cor,
          ),
        ),
      ),
    );
  }
}
