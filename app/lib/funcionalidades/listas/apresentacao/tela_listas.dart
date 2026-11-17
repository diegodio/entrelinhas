import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../l10n/textos.dart';
import '../../../nucleo/componentes/estados.dart';
import '../../../nucleo/componentes/livros.dart';
import '../../../nucleo/rede/erro_api.dart';
import '../../../nucleo/tema/tema.dart';
import '../../conta/dados/conta_repositorio.dart';
import '../../ficha/acoes_ficha.dart';
import '../../obras/dominio/modelos.dart';
import '../dados/listas_repositorio.dart';

class TelaListas extends ConsumerWidget {
  const TelaListas({super.key});

  Future<void> _nova(BuildContext context, WidgetRef ref) async {
    final t = Textos.of(context);
    final mensageiro = ScaffoldMessenger.of(context);
    final nome = await pedirTexto(context, t.novaLista, t.nomeDaLista);
    if (nome == null || nome.trim().isEmpty) return;
    try {
      await ref.read(listasRepositorioProvider).criar(nome.trim());
      ref.invalidate(listasProvider);
    } on ErroApi catch (e) {
      if (!context.mounted) return;
      mensageiro.showSnackBar(
        SnackBar(
          content: Text(mensagemDeErro(context, e)),
          action: e.codigo == 'plano_necessario'
              ? SnackBarAction(label: t.botaoVerPlanos, onPressed: () => context.push('/planos'))
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Textos.of(context);
    final logado = ref.watch(sessaoProvider).value != null;
    final listas = ref.watch(listasProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.listasTitulo),
        actions: [
          if (logado)
            IconButton(
              tooltip: t.novaLista,
              onPressed: () => _nova(context, ref),
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: !logado
          ? EstadoVazio(
              mensagem: t.entrarParaListas,
              icone: Icons.bookmarks_outlined,
              acao: FilledButton(
                onPressed: () => context.push('/entrar'),
                child: Text(t.botaoEntrar),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => ref.invalidate(listasProvider),
              child: switch (listas) {
                AsyncData(:final value) when value.isEmpty => ListView(
                  children: [EstadoVazio(mensagem: t.semListas)],
                ),
                AsyncData(:final value) => ListView(
                  children: [
                    for (final l in value)
                      LarguraLeitura(
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(l.nome, style: context.estilos.destaque),
                              subtitle: Text(t.itensN(l.quantidade)),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push('/lista/${l.id}'),
                            ),
                            const Divider(),
                          ],
                        ),
                      ),
                  ],
                ),
                AsyncError(:final error) => ListView(
                  children: [
                    EstadoErro(erro: error, aoTentarDeNovo: () => ref.invalidate(listasProvider)),
                  ],
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
    );
  }
}

/// Itens de uma lista, com filtro por faixa e por leitor.
class TelaLista extends ConsumerStatefulWidget {
  const TelaLista({super.key, required this.listaId});
  final String listaId;

  @override
  ConsumerState<TelaLista> createState() => _TelaListaState();
}

class _TelaListaState extends ConsumerState<TelaLista> {
  String? _faixa;
  String? _leitor;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final lista = ref.watch(listaProvider(widget.listaId));
    final leitores = ref.watch(leitoresProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(lista.value?.resumo.nome ?? '')),
      body: switch (lista) {
        AsyncData(:final value) => ListView(
          children: [
            LarguraLeitura(
              child: Wrap(
                spacing: Espaco.xs,
                runSpacing: Espaco.xs,
                children: [
                  _Filtro(
                    rotulo: t.filtroFaixa,
                    valor: _faixa,
                    todos: t.filtroTodas,
                    opcoes: {for (final f in faixasOrdenadas) f: f},
                    aoMudar: (v) => setState(() => _faixa = v),
                  ),
                  if (leitores.isNotEmpty)
                    _Filtro(
                      rotulo: t.filtroLeitor,
                      valor: _leitor,
                      todos: t.filtroTodos,
                      opcoes: {for (final l in leitores) l.id: l.apelido},
                      aoMudar: (v) => setState(() => _leitor = v),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Espaco.xs),
            ...() {
              final itens = value.itens
                  .where((i) => _faixa == null || i.obra.faixaFinal == _faixa)
                  .where((i) => _leitor == null || i.perfilId == _leitor)
                  .toList();
              if (itens.isEmpty) return [EstadoVazio(mensagem: t.listaVazia)];
              return [
                for (final i in itens)
                  LarguraLeitura(
                    child: Column(
                      children: [
                        Dismissible(
                          key: ValueKey(i.obra.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            color: context.cores.superficieSuave,
                            child: Text(t.removerDaLista),
                          ),
                          onDismissed: (_) async {
                            await ref
                                .read(listasRepositorioProvider)
                                .remover(widget.listaId, i.obra.id);
                            ref.invalidate(listasProvider);
                          },
                          child: LinhaLivro(
                            obra: i.obra,
                            aoTocar: () => context.push('/obra/${i.obra.id}'),
                          ),
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
              ];
            }(),
          ],
        ),
        AsyncError(:final error) => EstadoErro(
          erro: error,
          aoTentarDeNovo: () => ref.invalidate(listaProvider(widget.listaId)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Filtro extends StatelessWidget {
  const _Filtro({
    required this.rotulo,
    required this.valor,
    required this.todos,
    required this.opcoes,
    required this.aoMudar,
  });
  final String rotulo;
  final String? valor;
  final String todos;
  final Map<String, String> opcoes;
  final ValueChanged<String?> aoMudar;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String?>(
      label: Text(rotulo),
      initialSelection: valor,
      width: 160,
      onSelected: aoMudar,
      dropdownMenuEntries: [
        DropdownMenuEntry(value: null, label: todos),
        for (final MapEntry(:key, :value) in opcoes.entries)
          DropdownMenuEntry(value: key, label: value),
      ],
    );
  }
}
