import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/textos.dart';
import '../../nucleo/componentes/estados.dart';
import '../../nucleo/componentes/livros.dart';
import '../../nucleo/provedores.dart';
import '../../nucleo/tema/tema.dart';
import '../conta/dados/conta_repositorio.dart';
import '../obras/dados/obras_repositorio.dart';

class TelaInicio extends ConsumerWidget {
  const TelaInicio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Textos.of(context);
    final e = context.estilos;
    final cfg = ref.watch(configuracaoProvider);
    final historico = ref.watch(historicoProvider);
    final usuario = ref.watch(sessaoProvider).value;
    final uso = usuario?.uso;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(historicoProvider);
            ref.invalidate(sessaoProvider);
          },
          child: ListView(
            padding: const EdgeInsets.only(top: Espaco.xl, bottom: Espaco.xl),
            children: [
              LarguraLeitura(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(header: true, child: Text(t.nomeProduto, style: e.marca)),
                    const SizedBox(height: 6),
                    Text(t.slogan, style: e.slogan),
                    const SizedBox(height: Espaco.l),
                    if (cfg.podeExibir('busca_titulo')) ...[
                      const CampoBusca(),
                      const SizedBox(height: Espaco.m + 4),
                    ],
                    if (cfg.podeExibir('scanner'))
                      BotaoEscanear(aoTocar: () => context.push('/escanear')),
                    const _SeletorLeitor(),
                    if (uso != null && uso.consultasLimite != null) ...[
                      const SizedBox(height: Espaco.s),
                      Text(t.usoMes(uso.consultasUsadas, uso.consultasLimite!), style: e.legenda),
                    ],
                    const SizedBox(height: Espaco.l),
                    Semantics(header: true, child: Text(t.consultasRecentes, style: e.tituloSecao)),
                    const SizedBox(height: 6),
                    const Divider(),
                    switch (historico) {
                      AsyncData(:final value) when value.isEmpty => EstadoVazio(
                        mensagem: t.semConsultasRecentes,
                      ),
                      AsyncData(:final value) => Column(
                        children: [
                          for (final obra in value) ...[
                            LinhaLivro(obra: obra, aoTocar: () => context.push('/obra/${obra.id}')),
                            const Divider(),
                          ],
                        ],
                      ),
                      AsyncError(:final error) => EstadoErro(erro: error),
                      _ => const SizedBox.shrink(),
                    },
                    const SizedBox(height: Espaco.l),
                    Text(t.avisoIndependencia, style: e.legenda),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Campo de busca do Início: envia para a tela de busca.
class CampoBusca extends StatelessWidget {
  const CampoBusca({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.rotuloBuscar, style: context.estilos.rotulo),
        const SizedBox(height: 6),
        TextField(
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(hintText: t.dicaBusca, prefixIcon: const Icon(Icons.search)),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) context.push('/busca?q=${Uri.encodeQueryComponent(v)}');
          },
          onTap: () {},
        ),
      ],
    );
  }
}

class _SeletorLeitor extends ConsumerWidget {
  const _SeletorLeitor();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leitores = ref.watch(leitoresProvider).value ?? const [];
    if (leitores.isEmpty) return const SizedBox.shrink();
    final t = Textos.of(context);
    final selecionado = ref.watch(leitorSelecionadoProvider);
    return Padding(
      padding: const EdgeInsets.only(top: Espaco.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.paraQuemELeitura, style: context.estilos.rotulo),
          const SizedBox(height: 6),
          Wrap(
            spacing: Espaco.xs,
            runSpacing: Espaco.xs,
            children: [
              ChoiceChip(
                label: Text(t.leitorNenhum),
                selected: selecionado == null,
                onSelected: (_) => ref.read(leitorSelecionadoProvider.notifier).escolher(null),
              ),
              for (final l in leitores)
                ChoiceChip(
                  label: Text(l.apelido),
                  selected: selecionado == l.id,
                  onSelected: (_) => ref.read(leitorSelecionadoProvider.notifier).escolher(l.id),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
