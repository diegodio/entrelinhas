import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/textos.dart';
import '../../nucleo/componentes/estados.dart';
import '../../nucleo/componentes/selo_faixa.dart';
import '../../nucleo/provedores.dart';
import '../../nucleo/rede/erro_api.dart';
import '../../nucleo/tema/tema.dart';
import '../../nucleo/textos/rotulos.dart';
import '../obras/dominio/modelos.dart';

final filaRevisaoProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) async =>
      (await ref.watch(clienteApiProvider).get<List<dynamic>>('/v1/revisao/fila'))
          .cast<Map<String, dynamic>>(),
);

final fichaRevisaoProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, obraId) =>
      ref.watch(clienteApiProvider).get<Map<String, dynamic>>('/v1/revisao/fichas/$obraId'),
);

const vocabularioAlertas = [
  'morte_de_personagem_principal',
  'luto',
  'morte_ou_maus_tratos_de_animal',
  'doenca_terminal',
  'bullying',
  'violencia_escolar',
  'gravidez_indesejada',
  'aborto',
  'violencia_sexual_fora_de_cena',
  'sequestro_ou_carcere',
  'automutilacao',
  'suicidio',
  'transtorno_alimentar',
  'dependencia_quimica',
  'relacao_abusiva_romantizada',
  'diferenca_de_poder_em_relacao_afetiva',
  'discriminacao_sem_critica_narrativa',
  'conteudo_religioso_sensivel',
  'final_tragico',
  'acidente_grave',
  'arma_de_fogo',
];
const alertasComJustificativa = [
  'relacao_abusiva_romantizada',
  'discriminacao_sem_critica_narrativa',
];
const marcadores = [
  'empatia',
  'repertorio_cultural',
  'pensamento_critico',
  'qualidade_estetica',
  'conhecimento_historico',
  'desenvolvimento_moral',
];

class TelaFilaRevisao extends ConsumerWidget {
  const TelaFilaRevisao({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Textos.of(context);
    final fila = ref.watch(filaRevisaoProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.revisaoTitulo)),
      body: switch (fila) {
        AsyncData(:final value) when value.isEmpty => EstadoVazio(mensagem: t.filaVazia),
        AsyncData(:final value) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(filaRevisaoProvider),
          child: ListView(
            padding: const EdgeInsets.all(Espaco.m),
            children: [
              Text(t.filaRevisao, style: context.estilos.tituloSecao),
              const SizedBox(height: Espaco.s),
              for (final f in value) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: PilulaFaixa(faixa: f['faixa_final'] as String),
                  title: Text('${f['titulo']}'),
                  subtitle: Text(
                    [
                      t.consultasN((f['consultas'] as num).toInt()),
                      '${t.confiancaAnalise}: ${t.rotuloConfianca((f['confianca'] as num).toDouble())}',
                      if ((f['contestacoes_abertas'] as num) > 0)
                        '${t.contestacoesAbertas}: ${f['contestacoes_abertas']}',
                    ].join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/revisao/${f['obra_id']}'),
                ),
                const Divider(),
              ],
            ],
          ),
        ),
        AsyncError(:final error) => EstadoErro(erro: error),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// Edição da ficha pelo revisor. A faixa é recalculada pelo servidor (prévia) com a mesma
/// regra pública; o revisor nunca digita faixa.
class TelaRevisarFicha extends ConsumerStatefulWidget {
  const TelaRevisarFicha({super.key, required this.obraId});
  final String obraId;

  @override
  ConsumerState<TelaRevisarFicha> createState() => _TelaRevisarFichaState();
}

class _TelaRevisarFichaState extends ConsumerState<TelaRevisarFicha> {
  Map<String, dynamic>? _ed; // cópia editável (formato da saída do classificador)
  final _motivo = TextEditingController();
  String? _previa;
  List<String> _erros = const [];
  bool _enviando = false;

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  Map<String, dynamic> _corpo() => {
    'camada_a': _ed!['camada_a'],
    'evidencias': _ed!['evidencias'],
    'camada_b': _ed!['camada_b'],
    'camada_c': _ed!['camada_c'],
    'motivo': _motivo.text.trim().isEmpty ? 'prévia' : _motivo.text.trim(),
  };

  Future<void> _enviar({required bool publicar}) async {
    final t = Textos.of(context);
    if (publicar && _motivo.text.trim().length < 5) {
      setState(() => _erros = [t.motivoObrigatorio]);
      return;
    }
    setState(() {
      _enviando = true;
      _erros = const [];
    });
    try {
      final api = ref.read(clienteApiProvider);
      final caminho = '/v1/revisao/fichas/${widget.obraId}${publicar ? '' : '/previa'}';
      final r = await api.post<Map<String, dynamic>>(caminho, dados: _corpo());
      setState(() => _previa = r['faixa_final'] as String);
      if (publicar && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.revisaoPublicada)));
        ref.invalidate(filaRevisaoProvider);
        ref.invalidate(fichaRevisaoProvider(widget.obraId));
      }
    } on ErroApi catch (e) {
      setState(
        () =>
            _erros = (e.detalhes['erros'] as List?)?.cast<String>() ?? [mensagemDeErro(context, e)],
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _responder(Map<String, dynamic> c) async {
    final t = Textos.of(context);
    final resposta = TextEditingController();
    var decisao = 'recusada';
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (d, setState) => AlertDialog(
          title: Text(t.responderContestacao),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${c['texto']}'),
              const SizedBox(height: Espaco.s),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'aceita', label: Text(t.aceitarContestacao)),
                  ButtonSegment(value: 'recusada', label: Text(t.recusarContestacao)),
                ],
                selected: {decisao},
                onSelectionChanged: (s) => setState(() => decisao = s.first),
              ),
              TextField(
                controller: resposta,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(labelText: t.resposta),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d, false), child: Text(t.cancelar)),
            FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(t.botaoEnviar)),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await ref
          .read(clienteApiProvider)
          .post<dynamic>(
            '/v1/revisao/contestacoes/${c['id']}',
            dados: {'decisao': decisao, 'resposta': resposta.text.trim()},
          );
      ref.invalidate(fichaRevisaoProvider(widget.obraId));
      ref.invalidate(filaRevisaoProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(mensagemDeErro(context, e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final dados = ref.watch(fichaRevisaoProvider(widget.obraId));
    return Scaffold(
      appBar: AppBar(title: Text(dados.value?['obra']?['titulo'] as String? ?? t.revisaoTitulo)),
      body: switch (dados) {
        AsyncData(:final value) => () {
          _ed ??= jsonDecode(jsonEncode(value['editavel'])) as Map<String, dynamic>;
          return _formulario(context, value);
        }(),
        AsyncError(:final error) => EstadoErro(erro: error),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _formulario(BuildContext context, Map<String, dynamic> dados) {
    final t = Textos.of(context);
    final e = context.estilos;
    final ficha = dados['ficha'] as Map<String, dynamic>;
    final a = _ed!['camada_a'] as Map<String, dynamic>;
    final b = _ed!['camada_b'] as Map<String, dynamic>;
    final c = _ed!['camada_c'] as Map<String, dynamic>;
    final vf = c['valor_formativo'] as Map<String, dynamic>;
    final flags = (b['flags'] as List).cast<String>();
    final contestacoes = (dados['contestacoes'] as List).cast<Map<String, dynamic>>();
    Widget secao(String s) => Padding(
      padding: const EdgeInsets.only(top: Espaco.l, bottom: Espaco.xs),
      child: Text(s, style: e.tituloSecao),
    );
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: (MediaQuery.sizeOf(context).width - 960).clamp(Espaco.m, double.infinity) / 2,
        vertical: Espaco.m,
      ),
      children: [
        Row(
          children: [
            SeloFaixa(faixa: ficha['faixa_final'] as String, tamanho: 48),
            const SizedBox(width: Espaco.s),
            if (_previa != null) ...[
              const Icon(Icons.arrow_forward),
              const SizedBox(width: Espaco.s),
              SeloFaixa(faixa: _previa!, tamanho: 48),
              const SizedBox(width: Espaco.s),
              Text(t.faixaRecalculada(_previa!), style: e.corpo),
            ],
          ],
        ),
        if (contestacoes.isNotEmpty) ...[
          secao(t.contestacoesAbertas),
          for (final ct in contestacoes)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '${idsEixos.contains(ct['campo']) ? t.eixo('${ct['campo']}') : ct['campo']}: ${ct['texto']}',
              ),
              subtitle: Text(
                '${t.statusContestacao('${ct['status']}')}${ct['resposta'] != null ? ' · ${ct['resposta']}' : ''}',
              ),
              trailing: ct['status'] == 'aberta'
                  ? TextButton(onPressed: () => _responder(ct), child: Text(t.responderContestacao))
                  : null,
            ),
        ],
        secao(t.conteudoSensivel),
        for (final eixo in idsEixos) ...[
          Row(
            children: [
              Expanded(child: Text(t.eixo(eixo), style: e.corpo)),
              DropdownMenu<int>(
                width: 170,
                initialSelection: (a[eixo]['nivel'] as num).toInt(),
                onSelected: (v) => setState(() => a[eixo]['nivel'] = v ?? 0),
                dropdownMenuEntries: [
                  for (var n = 0; n <= 4; n++)
                    DropdownMenuEntry(value: n, label: '$n · ${t.nivel(n)}'),
                ],
              ),
            ],
          ),
          TextFormField(
            initialValue: a[eixo]['justificativa'] as String,
            decoration: InputDecoration(labelText: t.justificativa),
            onChanged: (v) => a[eixo]['justificativa'] = v,
          ),
          const SizedBox(height: Espaco.s),
        ],
        secao(t.alertasConteudo),
        Wrap(
          spacing: Espaco.xs,
          runSpacing: Espaco.xs,
          children: [
            for (final f in vocabularioAlertas)
              FilterChip(
                label: Text(t.alerta(f)),
                selected: flags.contains(f),
                onSelected: (s) => setState(() {
                  s ? flags.add(f) : flags.remove(f);
                  b['flags'] = flags;
                }),
              ),
          ],
        ),
        for (final f in alertasComJustificativa.where(flags.contains))
          TextFormField(
            initialValue: (b['justificativas'] as Map)[f] as String? ?? '',
            decoration: InputDecoration(labelText: '${t.justificativa}: ${t.alerta(f)}'),
            onChanged: (v) => (b['justificativas'] as Map)[f] = v,
          ),
        secao(t.perfilLeitura),
        for (final (chave, rotulo) in [
          ('vocabulario', t.dimensaoVocabulario),
          ('estrutura_narrativa', t.dimensaoEstrutura),
          ('densidade_tematica', t.dimensaoDensidade),
        ])
          Row(
            children: [
              Expanded(child: Text(rotulo, style: e.corpo)),
              DropdownMenu<int>(
                width: 110,
                initialSelection: (c[chave] as num).toInt(),
                onSelected: (v) => setState(() => c[chave] = v ?? 1),
                dropdownMenuEntries: [
                  for (var n = 1; n <= 5; n++) DropdownMenuEntry(value: n, label: '$n'),
                ],
              ),
            ],
          ),
        secao(t.valorFormativo),
        SegmentedButton<String>(
          segments: [
            for (final n in ['Baixo', 'Médio', 'Alto']) ButtonSegment(value: n, label: Text(n)),
          ],
          selected: {vf['nivel'] as String},
          onSelectionChanged: (s) => setState(() => vf['nivel'] = s.first),
        ),
        Wrap(
          spacing: Espaco.xs,
          children: [
            for (final m in marcadores)
              FilterChip(
                label: Text(t.marcador(m)),
                selected: (vf['marcadores'] as List).contains(m),
                onSelected: (s) => setState(() {
                  final lista = (vf['marcadores'] as List).cast<String>().toList();
                  s ? lista.add(m) : lista.remove(m);
                  vf['marcadores'] = lista;
                }),
              ),
          ],
        ),
        TextFormField(
          initialValue: vf['justificativa'] as String,
          decoration: InputDecoration(labelText: t.justificativa),
          onChanged: (v) => vf['justificativa'] = v,
        ),
        secao(t.motivoMudanca),
        TextField(
          controller: _motivo,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(hintText: t.motivoObrigatorio),
        ),
        for (final erro in _erros)
          Padding(
            padding: const EdgeInsets.only(top: Espaco.xs),
            child: Text(erro, style: e.corpo.copyWith(color: context.cores.alertaForte)),
          ),
        const SizedBox(height: Espaco.m),
        Wrap(
          spacing: Espaco.s,
          children: [
            OutlinedButton(
              onPressed: _enviando ? null : () => _enviar(publicar: false),
              child: Text(t.botaoPrevia),
            ),
            FilledButton(
              onPressed: _enviando ? null : () => _enviar(publicar: true),
              child: Text(t.publicarRevisao),
            ),
          ],
        ),
        const SizedBox(height: Espaco.xl),
      ],
    );
  }
}
