import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/textos.dart';
import '../../nucleo/componentes/estados.dart';
import '../../nucleo/componentes/livros.dart';
import '../../nucleo/provedores.dart';
import '../../nucleo/tema/tema.dart';
import '../../nucleo/textos/rotulos.dart';
import '../obras/dominio/modelos.dart';
import 'tela_ficha.dart' show BlocoSelo;

final fichaPublicaProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, slug) =>
      ref.watch(clienteApiProvider).get<Map<String, dynamic>>('/v1/publico/fichas/$slug'),
);

/// Página pública do resumo (link compartilhável): selo, recomendação e procedência.
class TelaFichaPublica extends ConsumerWidget {
  const TelaFichaPublica({super.key, required this.slug});
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Textos.of(context);
    final dados = ref.watch(fichaPublicaProvider(slug));
    return Scaffold(
      appBar: AppBar(title: Text(t.nomeProduto)),
      body: switch (dados) {
        AsyncData(:final value) => () {
          final obra = ObraResumo.fromJson(value['obra'] as Map<String, dynamic>);
          final r = ResumoFicha.fromJson(value['resumo'] as Map<String, dynamic>);
          return SingleChildScrollView(
            child: LarguraLeitura(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CapaLivro(
                        url: obra.capaUrl,
                        titulo: obra.titulo,
                        largura: 96,
                        altura: 140,
                        sombra: true,
                      ),
                      const SizedBox(width: Espaco.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(obra.titulo, style: context.estilos.tituloObra),
                            Text(obra.autores.join(', '), style: context.estilos.apoio),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Espaco.l),
                  if (r.faixaFinal != null)
                    BlocoSelo(faixa: r.faixaFinal!, texto: r.textoRecomendacao ?? ''),
                  const SizedBox(height: Espaco.s),
                  if (r.fonteDaAnalise != null)
                    Text(t.fonteAnalise(r.fonteDaAnalise!), style: context.estilos.apoio),
                  if (r.revisadaPorHumano)
                    Text(
                      t.revisadoHumano,
                      style: context.estilos.rotulo.copyWith(color: context.cores.marca),
                    ),
                  const SizedBox(height: Espaco.l),
                  FilledButton(
                    onPressed: () => context.go('/obra/${obra.id}'),
                    child: Text(t.verFichaCompleta),
                  ),
                  const SizedBox(height: Espaco.l),
                  Text(t.avisoIndependencia, style: context.estilos.legenda),
                ],
              ),
            ),
          );
        }(),
        AsyncError(:final error) => Center(child: EstadoErro(erro: error)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
