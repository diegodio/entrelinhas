// Início: marca e saudação, busca, atalho grande para escanear, recentes em carrossel e a
// lista de livros cadastrados (filtrada pela busca).

import 'package:material_ui/material_ui.dart';

import '../l10n/textos.dart';
import '../nucleo/tema/tema.dart';
import 'busca_livros.dart';
import 'componentes.dart';
import 'historico.dart';

class TelaInicioSimples extends StatefulWidget {
  const TelaInicioSimples({
    super.key,
    required this.busca,
    required this.historico,
    required this.aoEscanear,
    required this.aoAbrir,
    required this.aoVerHistorico,
  });

  final BuscaLivros busca;
  final Historico historico;
  final VoidCallback aoEscanear;
  final void Function(String isbn) aoAbrir;
  final VoidCallback aoVerHistorico;

  @override
  State<TelaInicioSimples> createState() => _TelaInicioSimplesState();
}

class _TelaInicioSimplesState extends State<TelaInicioSimples> {
  String _termo = '';

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final e = context.estilos;
    final c = context.cores;
    final resultados = widget.busca.catalogo.filtrar(_termo);
    return SafeArea(
      child: ListView(
        // Espaço no fim para o botão central da barra não cobrir o último item.
        padding: const EdgeInsets.fromLTRB(Espaco.l, Espaco.m, Espaco.l, 112),
        children: [
          Text(t.nomeProduto, style: e.marca.copyWith(fontSize: 26)),
          const SizedBox(height: Espaco.xxs),
          Text(t.simplesSaudacao, style: e.corpoFraco),
          const SizedBox(height: Espaco.m),
          TextField(
            onChanged: (v) => setState(() => _termo = v),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: t.simplesBuscarDica,
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: c.superficie,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Raio.pilula),
                borderSide: BorderSide(color: c.pauta),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Raio.pilula),
                borderSide: BorderSide(color: c.pauta),
              ),
            ),
          ),
          if (_termo.trim().isEmpty) ...[
            const SizedBox(height: Espaco.m),
            _CartaoEscanear(aoTocar: widget.aoEscanear),
            ListenableBuilder(
              listenable: Listenable.merge([widget.historico, widget.busca]),
              builder: (context, _) {
                final recentes = widget.historico.itens.take(10).toList();
                if (recentes.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TituloSecao(
                      t.simplesRecentes,
                      acao: t.simplesVerTudo,
                      aoTocarAcao: widget.aoVerHistorico,
                    ),
                    SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: recentes.length,
                        separatorBuilder: (_, _) => const SizedBox(width: Espaco.s),
                        itemBuilder: (context, i) {
                          final isbn = recentes[i].isbn;
                          final livro = widget.busca.conhecido(isbn);
                          return Semantics(
                            button: true,
                            label: livro?.titulo ?? t.simplesNaoEncontrado,
                            child: InkWell(
                              onTap: () => widget.aoAbrir(isbn),
                              child: SizedBox(
                                width: 84,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CapaGerada(livro: livro, largura: 84),
                                    const SizedBox(height: Espaco.xxs),
                                    Expanded(
                                      child: Text(
                                        livro?.titulo ?? isbn,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: e.legenda,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
          TituloSecao(
            _termo.trim().isEmpty ? t.simplesVerCatalogo : t.simplesResultados(resultados.length),
          ),
          if (resultados.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Espaco.m),
              child: Text(t.simplesNadaEncontrado, style: e.corpoFraco),
            ),
          for (final l in resultados)
            LinhaLivroSimples(
              livro: l,
              titulo: l.titulo,
              apoio: [l.autor, l.editora].where((s) => s.isNotEmpty).join(' · '),
              aoTocar: () => widget.aoAbrir(l.isbn),
            ),
        ],
      ),
    );
  }
}

/// Atalho principal: cartão grande na cor da marca.
class _CartaoEscanear extends StatelessWidget {
  const _CartaoEscanear({required this.aoTocar});
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final c = context.cores;
    final e = context.estilos;
    return Material(
      color: c.marca,
      borderRadius: BorderRadius.circular(Raio.cartao),
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(Raio.cartao),
        child: Padding(
          padding: const EdgeInsets.all(Espaco.m),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: c.sobreMarca.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Raio.campo),
                ),
                child: Icon(Icons.qr_code_scanner, color: c.sobreMarca, size: 30),
              ),
              const SizedBox(width: Espaco.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.simplesEscanearTitulo, style: e.destaque.copyWith(color: c.sobreMarca)),
                    const SizedBox(height: 2),
                    Text(
                      t.simplesEscanearTexto,
                      style: e.apoio.copyWith(color: c.sobreMarca.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: c.sobreMarca),
            ],
          ),
        ),
      ),
    );
  }
}
