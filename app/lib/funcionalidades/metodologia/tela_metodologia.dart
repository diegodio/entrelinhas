import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/textos.dart';
import '../../nucleo/componentes/estados.dart';
import '../../nucleo/componentes/selo_faixa.dart';
import '../../nucleo/provedores.dart';
import '../../nucleo/tema/tema.dart';

/// "Como classificamos": gerada a partir da rubrica pelo servidor (GET /v1/metodologia).
final metodologiaProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(clienteApiProvider).get<Map<String, dynamic>>('/v1/metodologia'),
);

class TelaMetodologia extends ConsumerWidget {
  const TelaMetodologia({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Textos.of(context);
    final dados = ref.watch(metodologiaProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.metodologiaTitulo)),
      body: switch (dados) {
        AsyncData(:final value) => _Conteudo(m: value),
        AsyncError(:final error) => Center(
          child: EstadoErro(erro: error, aoTentarDeNovo: () => ref.invalidate(metodologiaProvider)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.m});
  final Map<String, dynamic> m;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final e = context.estilos;
    Widget titulo(String s) => Padding(
      padding: const EdgeInsets.only(top: Espaco.l, bottom: Espaco.xs),
      child: Semantics(header: true, child: Text(s, style: e.tituloSecao)),
    );
    final eixos = (m['eixos'] as List).cast<Map<String, dynamic>>();
    return SingleChildScrollView(
      child: LarguraLeitura(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(m['introducao'] as String, style: e.corpo),
            titulo(t.metodologiaRegras),
            for (final r in (m['regras'] as List).cast<String>())
              Padding(
                padding: const EdgeInsets.only(bottom: Espaco.xs),
                child: Text('• $r', style: e.corpo),
              ),
            titulo(t.metodologiaEixos),
            for (final eixo in eixos) ...[
              Padding(
                padding: const EdgeInsets.only(top: Espaco.s),
                child: Text(eixo['nome_completo'] as String, style: e.destaque),
              ),
              if (eixo['escopo'] != null) Text(eixo['escopo'] as String, style: e.apoio),
              const SizedBox(height: Espaco.xs),
              // Tabela acessível: cada linha é lida como "nível, descrição, faixa".
              Table(
                columnWidths: const {
                  0: FixedColumnWidth(84),
                  1: FlexColumnWidth(),
                  2: FixedColumnWidth(64),
                },
                border: TableBorder(horizontalInside: BorderSide(color: context.cores.pauta)),
                children: [
                  TableRow(
                    children: [
                      Text(t.colunaNivel, style: e.rotulo),
                      Text(t.colunaDescricao, style: e.rotulo),
                      Text(t.colunaFaixa, style: e.rotulo),
                    ],
                  ),
                  for (final n in (eixo['niveis'] as List).cast<Map<String, dynamic>>())
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text('${n['nivel']} · ${n['rotulo']}', style: e.apoio),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                          child: Text(
                            n['descricao'] as String,
                            style: e.corpo.copyWith(fontSize: 14),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: PilulaFaixa(faixa: n['faixa'] as String),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
            titulo(t.metodologiaRecomendacoes),
            for (final r in (m['recomendacoes'] as Map).values.cast<String>())
              Text('• $r', style: e.corpo),
            titulo(t.alertasConteudo),
            Text(m['alertas']['descricao'] as String, style: e.corpo),
            const SizedBox(height: Espaco.xs),
            Text((m['alertas']['lista'] as List).join(' · '), style: e.apoio),
            titulo(t.perfilLeitura),
            Text(m['perfil_de_leitura']['descricao'] as String, style: e.corpo),
            titulo(t.valorFormativo),
            Text(m['valor_formativo']['descricao'] as String, style: e.corpo),
            titulo(t.metodologiaFontes),
            for (final f in (m['fontes_de_analise'] as List).cast<Map<String, dynamic>>()) ...[
              Text(f['titulo'] as String, style: e.destaque),
              Text(f['descricao'] as String, style: e.corpo),
              const SizedBox(height: Espaco.xs),
            ],
            titulo(t.metodologiaContestacao),
            Text(m['contestacao'] as String, style: e.corpo),
            const SizedBox(height: Espaco.l),
            Text(m['aviso_independencia'] as String, style: e.legenda),
            const SizedBox(height: Espaco.xl),
          ],
        ),
      ),
    );
  }
}
