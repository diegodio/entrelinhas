import 'package:material_ui/material_ui.dart';

import '../../l10n/textos.dart';
import '../tema/tema.dart';
import '../textos/rotulos.dart';

/// Barra de segmentos (0 a [maximo]). Preenchidos em tinta; do [nivelForte] em diante, em
/// alertaForte; vazios em pauta.
class BarraSegmentos extends StatelessWidget {
  const BarraSegmentos({
    super.key,
    required this.valor,
    required this.maximo,
    this.nivelForte,
    this.largura = 120,
  });

  final int valor;
  final int maximo;
  final int? nivelForte;
  final double largura;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final cheio = nivelForte != null && valor >= nivelForte! ? c.alertaForte : c.tinta;
    return ExcludeSemantics(
      child: SizedBox(
        width: largura,
        height: 8,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < maximo; i++) ...[
              if (i > 0) const SizedBox(width: 3),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: i < valor ? cheio : c.pauta,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Linha de eixo: nome, barra de cinco segmentos (0 a 4) e rótulo do nível.
class LinhaEixo extends StatelessWidget {
  const LinhaEixo({
    super.key,
    required this.eixo,
    required this.nivel,
    this.determinante = false,
    this.aoTocar,
    this.aberto = false,
  });

  final String eixo;
  final int nivel;
  final bool determinante;
  final VoidCallback? aoTocar;
  final bool aberto;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final e = context.estilos;
    final c = context.cores;
    final rotulo = t.nivel(nivel);
    return Semantics(
      button: aoTocar != null,
      expanded: aoTocar != null ? aberto : null,
      label:
          t.semanticaEixo(t.eixo(eixo), nivel, rotulo) +
          (determinante ? '. ${t.defineAFaixa}' : ''),
      excludeSemantics: true,
      child: InkWell(
        onTap: aoTocar,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Espaco.xs),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: Espaco.xs,
                    runSpacing: Espaco.xxs,
                    children: [
                      Text(t.eixo(eixo), style: e.corpo),
                      if (determinante)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: c.superficieSuave,
                            borderRadius: BorderRadius.circular(Raio.pilula),
                          ),
                          child: Text(
                            t.defineAFaixa,
                            style: e.legenda.copyWith(color: c.tinta, fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: Espaco.s),
                BarraSegmentos(valor: nivel, maximo: 4, nivelForte: 3, largura: 88),
                const SizedBox(width: Espaco.s),
                SizedBox(
                  width: 76,
                  child: Text(
                    rotulo,
                    textAlign: TextAlign.end,
                    style: e.rotulo.copyWith(color: nivel >= 3 ? c.alertaForte : c.tintaFraca),
                  ),
                ),
                if (aoTocar != null)
                  Icon(
                    aberto ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: c.tintaFraca,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip de alerta: pílula com contorno em pautaForte e texto em tinta.
class ChipAlerta extends StatelessWidget {
  const ChipAlerta({super.key, required this.rotulo, this.aoTocar});
  final String rotulo;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final conteudo = Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: Espaco.xs),
      decoration: BoxDecoration(
        color: c.superficie,
        border: Border.all(color: c.pautaForte),
        borderRadius: BorderRadius.circular(Raio.pilula),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(rotulo, style: context.estilos.corpo.copyWith(fontSize: 14))),
          if (aoTocar != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.info_outline, size: 16, color: c.tintaFraca),
          ],
        ],
      ),
    );
    if (aoTocar == null) return conteudo;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(Raio.pilula),
        child: conteudo,
      ),
    );
  }
}

/// Barra de confiança: barra fina com o valor em texto ao lado.
class BarraConfianca extends StatelessWidget {
  const BarraConfianca({super.key, required this.confianca});
  final double confianca;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final c = context.cores;
    final rotulo = t.rotuloConfianca(confianca);
    return Semantics(
      label: t.semanticaConfianca(rotulo),
      excludeSemantics: true,
      child: Row(
        children: [
          // Com texto ampliado, o rótulo quebra linha em vez de empurrar a barra.
          Flexible(flex: 3, child: Text(t.confiancaAnalise, style: context.estilos.apoio)),
          const SizedBox(width: Espaco.s),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: confianca.clamp(0, 1),
                minHeight: 4,
                backgroundColor: c.pauta,
                color: c.tinta,
              ),
            ),
          ),
          const SizedBox(width: Espaco.s),
          Text(rotulo, style: context.estilos.rotulo.copyWith(color: c.tinta)),
        ],
      ),
    );
  }
}
