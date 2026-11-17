import 'package:material_ui/material_ui.dart';

import '../../funcionalidades/obras/dominio/modelos.dart';
import '../../l10n/textos.dart';
import '../tema/tema.dart';
import 'selo_faixa.dart';

/// Capa do livro, com a única sombra do sistema. Sem imagem, um bloco neutro com o título.
class CapaLivro extends StatelessWidget {
  const CapaLivro({
    super.key,
    required this.url,
    required this.titulo,
    this.largura = 44,
    this.altura = 64,
    this.sombra = false,
  });

  final String? url;
  final String titulo;
  final double largura;
  final double altura;
  final bool sombra;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final reserva = Container(
      color: c.superficieSuave,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      child: Icon(Icons.menu_book_outlined, color: c.tintaFraca, size: largura * 0.4),
    );
    return Semantics(
      image: true,
      label: Textos.of(context).semanticaCapa(titulo),
      excludeSemantics: true,
      child: Container(
        width: largura,
        height: altura,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(largura > 60 ? Raio.capa : 3),
          boxShadow: sombra
              ? [BoxShadow(color: c.tinta.withValues(alpha: 0.22), blurRadius: 14,
                  offset: const Offset(0, 6))]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: url == null
            ? reserva
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => reserva,
                loadingBuilder: (_, filho, progresso) => progresso == null ? filho : reserva,
              ),
      ),
    );
  }
}

/// Linha de livro: capa, título em Fraunces, autor e selo em pílula à direita.
class LinhaLivro extends StatelessWidget {
  const LinhaLivro({super.key, required this.obra, this.aoTocar, this.complemento, this.final_});

  final ObraResumo obra;
  final VoidCallback? aoTocar;
  final String? complemento;
  final Widget? final_;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final e = context.estilos;
    final c = context.cores;
    Widget direita;
    if (final_ != null) {
      direita = final_!;
    } else if (obra.faixaFinal != null) {
      direita = PilulaFaixa(faixa: obra.faixaFinal!);
    } else {
      direita = Text(
        obra.statusFicha == 'em_analise' ? t.emAnaliseCurto : t.semFichaAinda,
        style: e.legenda,
      );
    }
    return InkWell(
      onTap: aoTocar,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 88),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Espaco.s),
          child: Row(
            children: [
              CapaLivro(url: obra.capaUrl, titulo: obra.titulo),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(obra.titulo, style: e.destaque, maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (obra.autores.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(obra.autores.join(', '), style: e.apoio, maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    if (complemento != null || obra.demonstracao)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          [if (obra.demonstracao) t.rotuloDemonstracao, ?complemento].join(' · '),
                          style: e.legenda.copyWith(color: c.tintaFraca),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: Espaco.s),
              direita,
            ],
          ),
        ),
      ),
    );
  }
}

/// Botão grande de escanear do Início (≈104 de altura).
class BotaoEscanear extends StatelessWidget {
  const BotaoEscanear({super.key, required this.aoTocar});
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final c = context.cores;
    return Semantics(
      button: true,
      label: '${t.botaoApontar}. ${t.botaoApontarSub}',
      excludeSemantics: true,
      child: Material(
        color: c.marca,
        borderRadius: BorderRadius.circular(Raio.cartao),
        child: InkWell(
          onTap: aoTocar,
          borderRadius: BorderRadius.circular(Raio.cartao),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 104),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: Espaco.m),
              child: Row(
                children: [
                  Icon(Icons.qr_code_scanner, size: 40, color: c.sobreMarca),
                  const SizedBox(width: Espaco.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t.botaoApontar,
                            style: TextStyle(
                                fontFamily: Fontes.editorial,
                                fontSize: 21,
                                fontWeight: FontWeight.w500,
                                color: c.sobreMarca)),
                        const SizedBox(height: Espaco.xxs),
                        Text(t.botaoApontarSub,
                            style: context.estilos.apoio.copyWith(color: c.sobreMarca)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
