import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../l10n/textos.dart';
import '../../../nucleo/arquivos/salvar_arquivo.dart';
import '../../../nucleo/componentes/estados.dart';
import '../../../nucleo/componentes/selo_faixa.dart';
import '../../../nucleo/rede/erro_api.dart';
import '../../../nucleo/tema/tema.dart';
import '../../../nucleo/textos/rotulos.dart';
import '../../conta/dados/conta_repositorio.dart';
import '../../ficha/acoes_ficha.dart';
import '../../obras/dominio/modelos.dart';
import '../dados/acervo_repositorio.dart';

void _avisar(BuildContext context, Object e) {
  final t = Textos.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensagemDeErro(context, e)),
      action: e is ErroApi && e.codigo == 'plano_necessario'
          ? SnackBarAction(label: t.botaoVerPlanos, onPressed: () => context.push('/planos'))
          : null,
    ),
  );
}

/// Painel da instituição: listas de acervo e de turma, membros e plano.
class TelaAcervo extends ConsumerWidget {
  const TelaAcervo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Textos.of(context);
    final usuario = ref.watch(sessaoProvider).value;
    if (usuario == null) {
      return Scaffold(body: EstadoVazio(mensagem: t.naoConectado));
    }
    if (usuario.organizacoes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(t.acervoTitulo)),
        body: EstadoVazio(
          mensagem: t.semOrganizacao,
          icone: Icons.local_library_outlined,
          acao: FilledButton(
            onPressed: () async {
              final nome = await pedirTexto(context, t.criarOrganizacao, t.nomeOrganizacao);
              if (nome == null || nome.trim().length < 2) return;
              try {
                await ref.read(acervoRepositorioProvider).criarOrganizacao(nome.trim(), 'escola');
                await ref.read(sessaoProvider.notifier).recarregar();
              } catch (e) {
                if (context.mounted) _avisar(context, e);
              }
            },
            child: Text(t.criarOrganizacao),
          ),
        ),
      );
    }
    final orgId = usuario.organizacoes.first.organizacaoId;
    final org = ref.watch(organizacaoProvider(orgId));
    return Scaffold(
      appBar: AppBar(title: Text(org.value?['nome'] as String? ?? t.acervoTitulo)),
      body: switch (org) {
        AsyncData(:final value) => _PainelOrganizacao(org: value),
        AsyncError(:final error) => EstadoErro(
          erro: error,
          aoTentarDeNovo: () => ref.invalidate(organizacaoProvider(orgId)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _PainelOrganizacao extends ConsumerWidget {
  const _PainelOrganizacao({required this.org});
  final Map<String, dynamic> org;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Textos.of(context);
    final e = context.estilos;
    final id = org['id'] as String;
    final gestor = org['meu_papel'] == 'gestor';
    final listas = (org['listas'] as List).cast<Map<String, dynamic>>();
    final membros = (org['membros'] as List).cast<Map<String, dynamic>>();
    return SingleChildScrollView(
      child: LarguraLeitura(
        largura: 1100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (org['plano_escola_ativo'] != true)
              Aviso(texto: t.planoEscolaDescricao, icone: Icons.workspace_premium_outlined),
            Padding(
              padding: const EdgeInsets.only(top: Espaco.l, bottom: Espaco.xs),
              child: Row(
                children: [
                  Expanded(child: Text(t.listasTitulo, style: e.tituloSecao)),
                  OutlinedButton.icon(
                    onPressed: () => _novaLista(context, ref, id, org['meu_papel'] as String),
                    icon: const Icon(Icons.add),
                    label: Text(t.novaListaAcervo),
                  ),
                ],
              ),
            ),
            const Divider(),
            for (final l in listas) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l['nome'] as String, style: e.destaque),
                subtitle: Text(
                  [
                    t.itensN((l['quantidade'] as num).toInt()),
                    if (l['tipo'] == 'turma') t.tipoTurma,
                    if (l['idade_referencia'] != null)
                      '${t.idadeReferencia}: ${l['idade_referencia']}',
                  ].join(' · '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/acervo/$id/lista/${l['id']}'),
              ),
              const Divider(),
            ],
            Padding(
              padding: const EdgeInsets.only(top: Espaco.l, bottom: Espaco.xs),
              child: Row(
                children: [
                  Expanded(child: Text(t.membros, style: e.tituloSecao)),
                  if (gestor)
                    OutlinedButton.icon(
                      onPressed: () => _novoMembro(context, ref, id),
                      icon: const Icon(Icons.person_add_alt),
                      label: Text(t.convidarMembro),
                    ),
                ],
              ),
            ),
            for (final m in membros)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  (m['nome'] as String).isEmpty ? m['email'] as String : m['nome'] as String,
                ),
                subtitle: Text('${m['email']} · ${t.papelOrganizacao(m['papel'] as String)}'),
                trailing: gestor
                    ? IconButton(
                        tooltip: t.removerMembro,
                        icon: const Icon(Icons.close),
                        onPressed: () async {
                          try {
                            await ref
                                .read(acervoRepositorioProvider)
                                .removerMembro(id, m['usuario_id'] as String);
                            ref.invalidate(organizacaoProvider(id));
                          } catch (e) {
                            if (context.mounted) _avisar(context, e);
                          }
                        },
                      )
                    : null,
              ),
            const SizedBox(height: Espaco.xl),
          ],
        ),
      ),
    );
  }

  Future<void> _novaLista(BuildContext context, WidgetRef ref, String org, String papel) async {
    final t = Textos.of(context);
    final nome = TextEditingController();
    final idade = TextEditingController();
    final ano = TextEditingController();
    var tipo = papel == 'professor' ? 'turma' : 'acervo';
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: Text(t.novaListaAcervo),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: [
                  if (papel != 'professor')
                    ButtonSegment(value: 'acervo', label: Text(t.tipoAcervo)),
                  ButtonSegment(value: 'turma', label: Text(t.tipoTurma)),
                ],
                selected: {tipo},
                onSelectionChanged: (s) => setState(() => tipo = s.first),
              ),
              TextField(
                controller: nome,
                decoration: InputDecoration(labelText: t.nomeDaLista),
              ),
              TextField(
                controller: idade,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t.idadeReferencia),
              ),
              if (tipo == 'turma')
                TextField(
                  controller: ano,
                  decoration: InputDecoration(labelText: t.anoEscolar),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t.cancelar)),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(t.salvar)),
          ],
        ),
      ),
    );
    if (ok != true || nome.text.trim().isEmpty) return;
    try {
      await ref
          .read(acervoRepositorioProvider)
          .criarLista(
            org,
            nome: nome.text.trim(),
            tipo: tipo,
            idade: int.tryParse(idade.text),
            ano: ano.text.trim().isEmpty ? null : ano.text.trim(),
          );
      ref.invalidate(organizacaoProvider(org));
    } catch (e) {
      if (context.mounted) _avisar(context, e);
    }
  }

  Future<void> _novoMembro(BuildContext context, WidgetRef ref, String org) async {
    final t = Textos.of(context);
    final email = TextEditingController();
    var papel = 'professor';
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: Text(t.convidarMembro),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: email,
                decoration: InputDecoration(labelText: t.email),
              ),
              const SizedBox(height: Espaco.s),
              DropdownMenu<String>(
                initialSelection: papel,
                onSelected: (v) => setState(() => papel = v ?? 'professor'),
                dropdownMenuEntries: [
                  for (final p in ['gestor', 'bibliotecario', 'professor'])
                    DropdownMenuEntry(value: p, label: t.papelOrganizacao(p)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t.cancelar)),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(t.salvar)),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(acervoRepositorioProvider).adicionarMembro(org, email.text.trim(), papel);
      ref.invalidate(organizacaoProvider(org));
    } catch (e) {
      if (context.mounted) _avisar(context, e);
    }
  }
}

/// Lista de acervo: tabela com ordenação e filtros, importação de CSV e relatório.
class TelaListaAcervo extends ConsumerStatefulWidget {
  const TelaListaAcervo({super.key, required this.orgId, required this.listaId});
  final String orgId;
  final String listaId;

  @override
  ConsumerState<TelaListaAcervo> createState() => _TelaListaAcervoState();
}

class _TelaListaAcervoState extends ConsumerState<TelaListaAcervo> {
  int _coluna = 0;
  bool _crescente = true;
  String? _faixa;
  String? _situacao;
  Map<String, dynamic>? _importacao;
  bool _importando = false;

  (String, String) get _ids => (widget.orgId, widget.listaId);

  Future<void> _importar() async {
    final repo = ref.read(acervoRepositorioProvider);
    final escolha = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'txt'],
    );
    if (escolha.isEmpty) return; // a pessoa cancelou
    final arquivo = escolha.single;
    final bytes = await arquivo.readAsBytes();
    setState(() {
      _importando = true;
      _importacao = null;
    });
    try {
      final tarefa = await repo.importar(widget.orgId, widget.listaId, bytes, arquivo.name);
      // Acompanha o andamento até a tarefa terminar.
      for (var i = 0; i < 120; i++) {
        final a = await repo.andamento(widget.orgId, tarefa);
        if (a['estado'] == 'ok' || a['estado'] == 'erro') {
          if (mounted) setState(() => _importacao = a);
          break;
        }
        await Future<void>.delayed(const Duration(seconds: 1));
      }
      ref.invalidate(listaAcervoProvider(_ids));
    } catch (e) {
      if (mounted) _avisar(context, e);
    } finally {
      if (mounted) setState(() => _importando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final dados = ref.watch(listaAcervoProvider(_ids));
    return Scaffold(
      appBar: AppBar(
        title: Text(dados.value?['nome'] as String? ?? ''),
        actions: [
          TextButton.icon(
            onPressed: _importando ? null : _importar,
            icon: const Icon(Icons.upload_file),
            label: Text(t.importarCsv),
          ),
          TextButton.icon(
            onPressed: () =>
                context.push('/acervo/${widget.orgId}/lista/${widget.listaId}/relatorio'),
            icon: const Icon(Icons.bar_chart),
            label: Text(t.relatorio),
          ),
        ],
      ),
      body: switch (dados) {
        AsyncData(:final value) => _tabela(context, value),
        AsyncError(:final error) => EstadoErro(
          erro: error,
          aoTentarDeNovo: () => ref.invalidate(listaAcervoProvider(_ids)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _tabela(BuildContext context, Map<String, dynamic> lista) {
    final t = Textos.of(context);
    final e = context.estilos;
    final itens = (lista['itens'] as List)
        .cast<Map<String, dynamic>>()
        .map((i) => i['obra'] as Map<String, dynamic>)
        .where((o) => _faixa == null || o['faixa_final'] == _faixa)
        .where((o) => _situacao == null || o['status_ficha'] == _situacao)
        .toList();
    int indice(Map<String, dynamic> o) =>
        o['faixa_final'] == null ? 99 : faixasOrdenadas.indexOf(o['faixa_final'] as String);
    itens.sort((a, b) {
      final r = switch (_coluna) {
        1 => indice(a).compareTo(indice(b)),
        3 => '${a['rotulo_nivel_leitura'] ?? ''}'.compareTo('${b['rotulo_nivel_leitura'] ?? ''}'),
        4 => '${a['status_ficha']}'.compareTo('${b['status_ficha']}'),
        _ => '${a['titulo']}'.toLowerCase().compareTo('${b['titulo']}'.toLowerCase()),
      };
      return _crescente ? r : -r;
    });
    void ordenar(int c, bool asc) => setState(() {
      _coluna = c;
      _crescente = asc;
    });
    return ListView(
      padding: const EdgeInsets.all(Espaco.m),
      children: [
        Text(t.importacaoExplicacao, style: e.apoio),
        if (_importando) ...[
          const SizedBox(height: Espaco.s),
          Aviso(texto: t.importacaoAndamento, icone: Icons.hourglass_top),
        ],
        if (_importacao?['resultado'] case final Map<String, dynamic> r) ...[
          const SizedBox(height: Espaco.s),
          Aviso(
            texto:
                '${t.importacaoAceitos}: ${r['aceitos']} · ${t.importacaoRejeitados}: '
                '${r['rejeitados']} · ${t.importacaoNaoEncontrados}: ${r['nao_encontrados']} · '
                '${t.importacaoPendentes}: ${r['analises_pendentes']}',
            icone: Icons.fact_check_outlined,
          ),
        ],
        const SizedBox(height: Espaco.s),
        Wrap(
          spacing: Espaco.s,
          runSpacing: Espaco.xs,
          children: [
            DropdownMenu<String?>(
              label: Text(t.filtroFaixa),
              initialSelection: _faixa,
              onSelected: (v) => setState(() => _faixa = v),
              dropdownMenuEntries: [
                DropdownMenuEntry(value: null, label: t.filtroTodas),
                for (final f in faixasOrdenadas) DropdownMenuEntry(value: f, label: f),
              ],
            ),
            DropdownMenu<String?>(
              label: Text(t.situacaoFicha),
              initialSelection: _situacao,
              onSelected: (v) => setState(() => _situacao = v),
              dropdownMenuEntries: [
                DropdownMenuEntry(value: null, label: t.filtroTodas),
                DropdownMenuEntry(value: 'publicada', label: t.situacaoPublicada),
                DropdownMenuEntry(value: 'em_analise', label: t.situacaoEmAnalise),
                DropdownMenuEntry(value: 'sem_ficha', label: t.situacaoSemFicha),
                DropdownMenuEntry(value: 'em_revisao', label: t.situacaoEmRevisao),
              ],
            ),
          ],
        ),
        const SizedBox(height: Espaco.s),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            showCheckboxColumn: false,
            sortColumnIndex: _coluna,
            sortAscending: _crescente,
            headingTextStyle: e.rotulo,
            columns: [
              DataColumn(label: Text(t.colunaObra), onSort: ordenar),
              DataColumn(label: Text(t.colunaFaixa), onSort: ordenar),
              DataColumn(label: Text(t.colunaAlertas)),
              DataColumn(label: Text(t.colunaNivelLeitura), onSort: ordenar),
              DataColumn(label: Text(t.situacaoFicha), onSort: ordenar),
            ],
            rows: [
              for (final o in itens)
                DataRow(
                  onSelectChanged: (_) => context.push('/obra/${o['id']}'),
                  cells: [
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Text('${o['titulo']}', overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    DataCell(
                      o['faixa_final'] == null
                          ? Text(t.semFichaAinda, style: e.legenda)
                          : PilulaFaixa(faixa: o['faixa_final'] as String),
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: Text(
                          ((o['alertas'] as List?) ?? const [])
                              .map((a) => t.alerta('$a'))
                              .join(', '),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text('${o['rotulo_nivel_leitura'] ?? '—'}')),
                    DataCell(Text(t.situacao('${o['status_ficha']}'))),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Relatório: distribuição por faixa (gráfico simples + tabela equivalente), alertas
/// frequentes, obras acima da idade de referência e exportação.
class TelaRelatorio extends ConsumerWidget {
  const TelaRelatorio({super.key, required this.orgId, required this.listaId});
  final String orgId;
  final String listaId;

  Future<void> _exportar(BuildContext context, WidgetRef ref, String formato) async {
    try {
      final bytes = await ref
          .read(acervoRepositorioProvider)
          .relatorioArquivo(orgId, listaId, formato);
      await salvarArquivo(
        bytes,
        'relatorio-acervo.$formato',
        formato == 'pdf' ? 'application/pdf' : 'text/csv',
      );
    } catch (e) {
      if (context.mounted) _avisar(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Textos.of(context);
    final e = context.estilos;
    final dados = ref.watch(relatorioProvider((orgId, listaId)));
    return Scaffold(
      appBar: AppBar(
        title: Text(t.relatorio),
        actions: [
          TextButton(onPressed: () => _exportar(context, ref, 'csv'), child: Text(t.exportarCsv)),
          TextButton(onPressed: () => _exportar(context, ref, 'pdf'), child: Text(t.exportarPdf)),
        ],
      ),
      body: switch (dados) {
        AsyncData(:final value) => () {
          final dist = (value['distribuicao_faixa'] as List).cast<Map<String, dynamic>>();
          final maior = dist.fold<int>(
            1,
            (m, d) => (d['quantidade'] as int) > m ? d['quantidade'] as int : m,
          );
          final alertas = (value['alertas_frequentes'] as List).cast<Map<String, dynamic>>();
          final acima = (value['acima_da_idade'] as List).cast<Map<String, dynamic>>();
          return ListView(
            padding: const EdgeInsets.all(Espaco.m),
            children: [
              Text(t.distribuicaoFaixa, style: e.tituloSecao),
              const SizedBox(height: Espaco.s),
              // Gráfico de barras horizontal; os números ficam escritos ao lado (equivalente em texto).
              for (final d in dist)
                Semantics(
                  label:
                      '${d['faixa'] == 'sem_ficha' ? t.semFichaAinda : d['faixa']}: ${d['quantidade']}',
                  excludeSemantics: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            d['faixa'] == 'sem_ficha' ? t.semFichaAinda : '${d['faixa']}',
                            style: e.apoio,
                          ),
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (_, c) => Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 16,
                                width: c.maxWidth * (d['quantidade'] as int) / maior,
                                color: context.cores.corDaFaixa(d['faixa'] as String),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text('${d['quantidade']}', textAlign: TextAlign.end),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: Espaco.l),
              Text(t.alertasFrequentes, style: e.tituloSecao),
              for (final a in alertas)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${a['alerta']}'),
                  trailing: Text('${a['quantidade']}'),
                ),
              if (value['lista']['idade_referencia'] != null) ...[
                const SizedBox(height: Espaco.l),
                Text(t.obrasAcimaIdade, style: e.tituloSecao),
                if (acima.isEmpty) Text(t.nenhumaAcimaIdade, style: e.corpoFraco),
                for (final o in acima)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${o['titulo']}'),
                    trailing: PilulaFaixa(faixa: o['faixa'] as String),
                    onTap: () => context.push('/obra/${o['obra_id']}'),
                  ),
              ],
            ],
          );
        }(),
        AsyncError(:final error) => EstadoErro(erro: error),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
