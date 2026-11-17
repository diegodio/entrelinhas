import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/textos.dart';
import '../../../nucleo/arquivos/salvar_arquivo.dart';
import '../../../nucleo/componentes/estados.dart';
import '../../../nucleo/config/ambiente.dart';
import '../../../nucleo/provedores.dart';
import '../../../nucleo/rede/erro_api.dart';
import '../../../nucleo/tema/tema.dart';
import '../../../nucleo/textos/rotulos.dart';
import '../dados/conta_repositorio.dart';
import '../dominio/usuario.dart';

const iconesLeitor = {
  'livro': Icons.menu_book_outlined,
  'estrela': Icons.star_outline,
  'lua': Icons.nightlight_outlined,
  'folha': Icons.eco_outlined,
  'barco': Icons.sailing_outlined,
  'pipa': Icons.toys_outlined,
};

class TelaPerfil extends ConsumerWidget {
  const TelaPerfil({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Textos.of(context);
    final e = context.estilos;
    final sessao = ref.watch(sessaoProvider);
    final usuario = sessao.value;
    return Scaffold(
      appBar: AppBar(title: Text(t.perfilTitulo)),
      body: ListView(
        children: [
          LarguraLeitura(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (sessao.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(Espaco.l),
                    child: BlocoEsqueleto(altura: 80),
                  )
                else if (usuario == null) ...[
                  Text(t.naoConectado, style: e.corpo),
                  const SizedBox(height: Espaco.s),
                  FilledButton(
                    onPressed: () => context.push('/entrar'),
                    child: Text(t.botaoEntrar),
                  ),
                  const SizedBox(height: Espaco.xs),
                  OutlinedButton(
                    onPressed: () => context.push('/cadastro'),
                    child: Text(t.botaoCriarConta),
                  ),
                ] else ...[
                  _Secao(t.conta),
                  Text(usuario.nome.isEmpty ? usuario.email : usuario.nome, style: e.destaque),
                  if (usuario.nome.isNotEmpty) Text(usuario.email, style: e.apoio),
                  _Secao(t.leitores),
                  const _ListaLeitores(),
                  _Secao(t.plano),
                  _BlocoPlano(usuario: usuario),
                  _Secao(t.privacidade),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: usuario.contribuirImagens,
                    title: Text(t.contribuirImagens, style: e.corpo),
                    subtitle: Text(t.contribuirImagensExplicacao, style: e.apoio),
                    onChanged: (v) =>
                        ref.read(sessaoProvider.notifier).atualizar(contribuirImagens: v),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.download_outlined),
                    title: Text(t.exportarDados),
                    onTap: () => _exportar(context, ref),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.delete_outline, color: context.cores.alertaForte),
                    title: Text(
                      t.excluirConta,
                      style: e.corpo.copyWith(color: context.cores.alertaForte),
                    ),
                    onTap: () => _excluir(context, ref),
                  ),
                ],
                _Secao(t.comoClassificamos),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.comoClassificamos),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/metodologia'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.termos),
                  onTap: () => launchUrl(Uri.parse(Ambiente.urlTermos)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.politica),
                  onTap: () => launchUrl(Uri.parse(Ambiente.urlPolitica)),
                ),
                if (usuario != null) ...[
                  const SizedBox(height: Espaco.m),
                  OutlinedButton(
                    onPressed: () => ref.read(sessaoProvider.notifier).sair(),
                    child: Text(t.sair),
                  ),
                ],
                const SizedBox(height: Espaco.l),
                Text(t.avisoIndependencia, style: e.legenda),
                const SizedBox(height: Espaco.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportar(BuildContext context, WidgetRef ref) async {
    final t = Textos.of(context);
    final mensageiro = ScaffoldMessenger.of(context);
    try {
      final dados = await ref.read(contaRepositorioProvider).exportarDados();
      await salvarArquivo(
        utf8.encode(const JsonEncoder.withIndent('  ').convert(dados)),
        'entrelinhas-meus-dados.json',
        'application/json',
      );
      mensageiro.showSnackBar(SnackBar(content: Text(t.dadosExportados)));
    } catch (e) {
      if (context.mounted) {
        mensageiro.showSnackBar(SnackBar(content: Text(mensagemDeErro(context, e))));
      }
    }
  }

  Future<void> _excluir(BuildContext context, WidgetRef ref) async {
    final t = Textos.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(t.excluirConta),
        content: Text(t.excluirContaConfirmar),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t.cancelar)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: context.cores.alertaForte),
            onPressed: () => Navigator.pop(c, true),
            child: Text(t.excluir),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(sessaoProvider.notifier).excluirConta();
  }
}

class _Secao extends StatelessWidget {
  const _Secao(this.titulo);
  final String titulo;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: Espaco.l, bottom: Espaco.xs),
    child: Semantics(header: true, child: Text(titulo, style: context.estilos.tituloSecao)),
  );
}

class _BlocoPlano extends StatelessWidget {
  const _BlocoPlano({required this.usuario});
  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final uso = usuario.uso;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.nomePlano(uso?.plano ?? 'gratuito'), style: context.estilos.destaque),
        if (uso?.consultasLimite != null)
          Text(
            '${t.usoDoMes}: ${t.usoMes(uso!.consultasUsadas, uso.consultasLimite!)}',
            style: context.estilos.apoio,
          ),
        if (uso?.validaAte != null)
          Text(t.planoValidoAte(uso!.validaAte!.substring(0, 10)), style: context.estilos.apoio),
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () => context.push('/planos'),
          child: Text(t.botaoVerPlanos),
        ),
      ],
    );
  }
}

class _ListaLeitores extends ConsumerWidget {
  const _ListaLeitores();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Textos.of(context);
    final leitores = ref.watch(leitoresProvider);
    final hoje = ref.watch(relogioProvider)();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.leitoresExplicacao, style: context.estilos.apoio),
        ...switch (leitores) {
          AsyncData(:final value) => [
            for (final l in value)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(iconesLeitor[l.icone] ?? Icons.menu_book_outlined),
                title: Text(l.apelido),
                subtitle: Text(t.faixaAnos('${l.idadeEm(hoje)}')),
                trailing: const Icon(Icons.edit_outlined, size: 20),
                onTap: () => editarLeitor(context, ref, l),
              ),
          ],
          AsyncError(:final error) => [EstadoErro(erro: error)],
          _ => [const SizedBox.shrink()],
        },
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => editarLeitor(context, ref, null),
            icon: const Icon(Icons.add),
            label: Text(t.adicionarLeitor),
          ),
        ),
      ],
    );
  }
}

Future<void> editarLeitor(BuildContext context, WidgetRef ref, PerfilLeitor? leitor) async {
  final t = Textos.of(context);
  final apelido = TextEditingController(text: leitor?.apelido ?? '');
  final ano = TextEditingController(text: leitor?.anoNascimento.toString() ?? '');
  var icone = leitor?.icone ?? 'livro';
  final mensageiro = ScaffoldMessenger.of(context);
  final acao = await showDialog<String>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) => AlertDialog(
        title: Text(leitor == null ? t.adicionarLeitor : t.editarLeitor),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: apelido,
              decoration: InputDecoration(labelText: t.apelido),
            ),
            const SizedBox(height: Espaco.s),
            TextField(
              controller: ano,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: t.anoNascimento),
            ),
            const SizedBox(height: Espaco.s),
            Text(t.icone, style: c.estilos.rotulo),
            Wrap(
              spacing: 4,
              children: [
                for (final MapEntry(:key, :value) in iconesLeitor.entries)
                  IconButton(
                    tooltip: key,
                    isSelected: icone == key,
                    onPressed: () => setState(() => icone = key),
                    icon: Icon(value),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          if (leitor != null)
            TextButton(onPressed: () => Navigator.pop(c, 'excluir'), child: Text(t.excluir)),
          TextButton(onPressed: () => Navigator.pop(c), child: Text(t.cancelar)),
          FilledButton(onPressed: () => Navigator.pop(c, 'salvar'), child: Text(t.salvar)),
        ],
      ),
    ),
  );
  if (acao == null) return;
  try {
    final notifier = ref.read(leitoresProvider.notifier);
    if (acao == 'excluir') {
      await notifier.excluir(leitor!.id);
    } else {
      final anoNum = int.tryParse(ano.text);
      if (apelido.text.trim().isEmpty || anoNum == null) {
        mensageiro.showSnackBar(SnackBar(content: Text(t.campoObrigatorio)));
        return;
      }
      await notifier.salvar(
        id: leitor?.id,
        apelido: apelido.text.trim(),
        ano: anoNum,
        icone: icone,
      );
    }
  } on ErroApi catch (e) {
    if (!context.mounted) return;
    if (e.codigo == 'plano_necessario') {
      mensageiro.showSnackBar(
        SnackBar(
          content: Text(t.limitePerfis),
          action: SnackBarAction(label: t.botaoVerPlanos, onPressed: () => context.push('/planos')),
        ),
      );
    } else {
      mensageiro.showSnackBar(SnackBar(content: Text(mensagemDeErro(context, e))));
    }
  }
}
