import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/textos.dart';
import '../../nucleo/arquivos/salvar_arquivo.dart';
import '../../nucleo/componentes/estados.dart';
import '../../nucleo/config/ambiente.dart';
import '../../nucleo/provedores.dart';
import '../../nucleo/rede/erro_api.dart';
import '../../nucleo/tema/tema.dart';
import '../conta/dados/conta_repositorio.dart';
import '../listas/dados/listas_repositorio.dart';
import '../obras/dominio/modelos.dart';
import 'estado_ficha.dart';

/// "Salvar na lista": escolhe a lista (e o leitor, quando houver).
Future<void> salvarNaLista(BuildContext context, WidgetRef ref, ObraResumo obra) async {
  final t = Textos.of(context);
  if (ref.read(sessaoProvider).value == null) {
    await context.push('/entrar?depois=/obra/${obra.id}');
    return;
  }
  final mensageiro = ScaffoldMessenger.of(context);
  final escolha = await showModalBottomSheet<ResumoLista>(
    context: context,
    showDragHandle: true,
    builder: (_) => const _EscolherLista(),
  );
  if (escolha == null) return;
  try {
    await ref.read(listasRepositorioProvider)
        .adicionar(escolha.id, obra.id, perfilId: ref.read(leitorSelecionadoProvider));
    ref.invalidate(listasProvider);
    mensageiro.showSnackBar(SnackBar(content: Text(t.salvoEm(escolha.nome))));
  } catch (e) {
    if (context.mounted) {
      mensageiro.showSnackBar(SnackBar(content: Text(mensagemDeErro(context, e))));
    }
  }
}

class _EscolherLista extends ConsumerWidget {
  const _EscolherLista();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Textos.of(context);
    final listas = ref.watch(listasProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Espaco.l, 0, Espaco.l, Espaco.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.escolherLista, style: context.estilos.tituloSecao),
            const SizedBox(height: Espaco.s),
            switch (listas) {
              AsyncData(:final value) => Column(children: [
                  for (final l in value.where((l) => l.tipo == 'pessoal'))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l.nome),
                      subtitle: Text(t.itensN(l.quantidade)),
                      onTap: () => Navigator.pop(context, l),
                    ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.add),
                    title: Text(t.novaLista),
                    onTap: () async {
                      final nome = await pedirTexto(context, t.novaLista, t.nomeDaLista);
                      if (nome == null || nome.trim().isEmpty) return;
                      final nova = await ref.read(listasRepositorioProvider).criar(nome.trim());
                      if (context.mounted) Navigator.pop(context, nova);
                    },
                  ),
                ]),
              AsyncError(:final error) => EstadoErro(erro: error),
              _ => const Padding(
                  padding: EdgeInsets.all(Espaco.l),
                  child: Center(child: CircularProgressIndicator()),
                ),
            },
          ],
        ),
      ),
    );
  }
}

Future<String?> pedirTexto(BuildContext context, String titulo, String rotulo,
    {String inicial = '', TextInputType? teclado}) {
  final controle = TextEditingController(text: inicial);
  final t = Textos.of(context);
  return showDialog<String>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(titulo),
      content: TextField(
        controller: controle,
        autofocus: true,
        keyboardType: teclado,
        decoration: InputDecoration(labelText: rotulo),
        onSubmitted: (v) => Navigator.pop(contexto, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(contexto), child: Text(t.cancelar)),
        FilledButton(
            onPressed: () => Navigator.pop(contexto, controle.text), child: Text(t.salvar)),
      ],
    ),
  );
}

class MenuFicha extends ConsumerWidget {
  const MenuFicha({super.key, required this.estado});
  final FichaPronta estado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Textos.of(context);
    final cfg = ref.watch(configuracaoProvider);
    return MenuAnchor(
      builder: (_, controle, _) => IconButton(
        tooltip: t.maisOpcoes,
        icon: const Icon(Icons.more_vert),
        onPressed: () => controle.isOpen ? controle.close() : controle.open(),
      ),
      menuChildren: [
        if (cfg.podeExibir('compartilhar') && estado.ficha.slug != null)
          MenuItemButton(
            leadingIcon: const Icon(Icons.ios_share),
            onPressed: () => _compartilhar(context),
            child: Text(t.compartilhar),
          ),
        if (cfg.podeExibir('exportar_pdf'))
          MenuItemButton(
            leadingIcon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _exportarPdf(context, ref),
            child: Text(t.exportarPdf),
          ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.flag_outlined),
          onPressed: () => context.push('/obra/${estado.obra.id}/contestar'),
          child: Text(t.contestar),
        ),
      ],
    );
  }

  Future<void> _compartilhar(BuildContext context) async {
    final url = '${Ambiente.urlApp}/ficha/${estado.ficha.slug}';
    final texto = '${estado.obra.titulo}: ${estado.ficha.textoRecomendacao}\n$url';
    try {
      await SharePlus.instance.share(ShareParams(text: texto, subject: estado.obra.titulo));
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: url));
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(Textos.of(context).copiado)));
      }
    }
  }

  Future<void> _exportarPdf(BuildContext context, WidgetRef ref) async {
    final mensageiro = ScaffoldMessenger.of(context);
    try {
      final bytes =
          await ref.read(clienteApiProvider).baixar('/v1/obras/${estado.obra.id}/ficha/pdf');
      await salvarArquivo(bytes, 'entrelinhas-${estado.ficha.slug ?? estado.obra.id}.pdf',
          'application/pdf');
    } catch (e) {
      if (!context.mounted) return;
      if (e is ErroApi && e.codigo == 'plano_necessario') {
        await context.push('/planos');
        return;
      }
      mensageiro.showSnackBar(SnackBar(content: Text(mensagemDeErro(context, e))));
    }
  }
}
