import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../l10n/textos.dart';
import '../../../nucleo/componentes/estados.dart';
import '../../../nucleo/tema/tema.dart';
import '../dados/reconhecimento_repositorio.dart';

/// Quando a foto não levou a um livro: código que não é de livro ou nenhum código legível.
class TelaResultadoReconhecimento extends StatelessWidget {
  const TelaResultadoReconhecimento({super.key, required this.resultado});

  final ResultadoReconhecimento resultado;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final naoELivro = resultado.status == 'nao_e_livro';
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: LarguraLeitura(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EstadoVazio(
                mensagem: naoELivro ? t.naoELivro : t.semCodigoNaFoto,
                icone: naoELivro ? Icons.qr_code_2 : Icons.search_off,
              ),
              FilledButton(
                onPressed: () => context.canPop() ? context.pop() : context.go('/escanear'),
                child: Text(t.botaoEscanearDeNovo),
              ),
              const SizedBox(height: Espaco.xs),
              OutlinedButton(
                onPressed: () => context.pushReplacement('/escanear?isbn=1'),
                child: Text(t.botaoDigitarIsbn),
              ),
              const SizedBox(height: Espaco.xs),
              OutlinedButton(
                onPressed: () => context.pushReplacement('/busca'),
                child: Text(t.botaoBuscarTitulo),
              ),
              const SizedBox(height: Espaco.xl),
            ],
          ),
        ),
      ),
    );
  }
}
