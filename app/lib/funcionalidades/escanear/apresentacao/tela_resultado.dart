import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../l10n/textos.dart';
import '../../../nucleo/componentes/estados.dart';
import '../../../nucleo/componentes/livros.dart';
import '../../../nucleo/tema/tema.dart';
import '../../obras/dominio/modelos.dart';
import '../dados/reconhecimento_repositorio.dart';

/// Resultado do reconhecimento quando não há identificação direta (seção 6.3).
class TelaResultadoReconhecimento extends ConsumerWidget {
  const TelaResultadoReconhecimento({super.key, required this.resultado, this.excluirObraId});

  final ResultadoReconhecimento resultado;

  /// Em "Não é este": a obra recusada não volta como candidata.
  final String? excluirObraId;

  Future<void> _escolher(BuildContext context, WidgetRef ref, ObraResumo obra) async {
    final amostra = resultado.amostraId;
    if (amostra != null) {
      // Com consentimento, a escolha vira correção para treinar o reconhecimento.
      ref.read(reconhecimentoRepositorioProvider).corrigir(amostra, obra.id).ignore();
    }
    context.pushReplacement('/obra/${obra.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Textos.of(context);
    final e = context.estilos;
    final candidatos = resultado.candidatos.where((c) => c.obra.id != excluirObraId).toList();
    final acoes = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/escanear'),
          child: Text(t.botaoEscanearDeNovo),
        ),
        const SizedBox(height: Espaco.xs),
        OutlinedButton(
          onPressed: () => context.pushReplacement('/busca'),
          child: Text(t.botaoBuscarTitulo),
        ),
        const SizedBox(height: Espaco.xs),
        OutlinedButton(
          onPressed: () => context.pushReplacement('/escanear?isbn=1'),
          child: Text(t.botaoDigitarIsbn),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: LarguraLeitura(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (resultado.status == 'nao_e_livro') ...[
                EstadoVazio(mensagem: t.naoELivro, icone: Icons.qr_code_2),
                acoes,
              ] else if (candidatos.isEmpty) ...[
                EstadoVazio(mensagem: t.naoReconhecemos, icone: Icons.search_off),
                acoes,
              ] else ...[
                Semantics(header: true, child: Text(t.encontramosOpcoes, style: e.tituloSecao)),
                const SizedBox(height: Espaco.s),
                const Divider(),
                for (final c in candidatos) ...[
                  LinhaLivro(obra: c.obra, aoTocar: () => _escolher(context, ref, c.obra)),
                  const Divider(),
                ],
                const SizedBox(height: Espaco.m),
                OutlinedButton(
                  onPressed: () => context.pushReplacement('/busca'),
                  child: Text(t.nenhumaDestas),
                ),
                const SizedBox(height: Espaco.xs),
                TextButton(
                  onPressed: () => context.canPop() ? context.pop() : context.go('/escanear'),
                  child: Text(t.botaoEscanearDeNovo),
                ),
              ],
              const SizedBox(height: Espaco.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Não é este" a partir da ficha: mostra os outros candidatos do último reconhecimento.
class TelaCorrecaoReconhecimento extends ConsumerWidget {
  const TelaCorrecaoReconhecimento({super.key, required this.obraRecusadaId});
  final String obraRecusadaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ultimo =
        ref.watch(ultimoReconhecimentoProvider) ??
        const ResultadoReconhecimento(status: 'nao_identificado');
    return TelaResultadoReconhecimento(resultado: ultimo, excluirObraId: obraRecusadaId);
  }
}
