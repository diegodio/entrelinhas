import 'package:material_ui/material_ui.dart';

import '../l10n/textos.dart';
import '../nucleo/tema/tema.dart';
import 'busca_livros.dart';
import 'componentes.dart';
import 'historico.dart';

/// Histórico: livros escaneados, do mais recente ao mais antigo.
class TelaHistoricoSimples extends StatelessWidget {
  const TelaHistoricoSimples({
    super.key,
    required this.busca,
    required this.historico,
    required this.aoAbrir,
    this.agora,
  });

  final BuscaLivros busca;
  final Historico historico;
  final void Function(String isbn) aoAbrir;
  final DateTime Function()? agora;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final e = context.estilos;
    return SafeArea(
      child: ListenableBuilder(
        listenable: Listenable.merge([historico, busca]),
        builder: (context, _) {
          final itens = historico.itens;
          final hoje = (agora ?? DateTime.now)();
          return ListView(
            // Espaço no fim para o botão central da barra não cobrir o último item.
            padding: const EdgeInsets.fromLTRB(Espaco.l, Espaco.m, Espaco.l, 112),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(t.simplesHistorico, style: e.tituloObra),
                    ),
                  ),
                  if (itens.isNotEmpty)
                    TextButton(onPressed: historico.limpar, child: Text(t.simplesLimparHistorico)),
                ],
              ),
              const SizedBox(height: Espaco.s),
              if (itens.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Espaco.xl),
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: context.cores.tintaFraca),
                      const SizedBox(height: Espaco.s),
                      Text(
                        t.simplesHistoricoVazio,
                        textAlign: TextAlign.center,
                        style: e.corpoFraco,
                      ),
                    ],
                  ),
                ),
              for (final item in itens)
                () {
                  final livro = busca.conhecido(item.isbn);
                  return LinhaLivroSimples(
                    livro: livro,
                    titulo: livro?.titulo ?? t.simplesNaoEncontrado,
                    apoio: '${quandoLegivel(item.quando, hoje)} · ${t.simplesIsbn(item.isbn)}',
                    aoTocar: () => aoAbrir(item.isbn),
                  );
                }(),
            ],
          );
        },
      ),
    );
  }
}
