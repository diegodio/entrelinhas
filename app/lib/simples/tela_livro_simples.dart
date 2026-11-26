// Página do livro: capa e título em destaque no topo, seções de dados abaixo e a ação
// principal fixa no rodapé.

import 'package:material_ui/material_ui.dart';

import '../l10n/textos.dart';
import '../nucleo/tema/tema.dart';
import 'catalogo.dart';
import 'componentes.dart';

class TelaLivroSimples extends StatelessWidget {
  const TelaLivroSimples({super.key, this.livro, required this.isbn, this.aoEscanearOutro});

  /// Null quando o ISBN não está no catálogo.
  final Livro? livro;
  final String isbn;
  final VoidCallback? aoEscanearOutro;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final e = context.estilos;
    final c = context.cores;
    final l = livro;
    return Scaffold(
      appBar: AppBar(backgroundColor: c.superficieSuave),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Cabeçalho: faixa de cor com a capa e o título.
          Container(
            color: c.superficieSuave,
            padding: const EdgeInsets.fromLTRB(Espaco.l, 0, Espaco.l, Espaco.l),
            child: Column(
              children: [
                CapaGerada(livro: l, largura: 132),
                const SizedBox(height: Espaco.m),
                Semantics(
                  header: true,
                  child: Text(
                    l?.titulo ?? t.simplesNaoCadastrado,
                    textAlign: TextAlign.center,
                    style: e.tituloObra,
                  ),
                ),
                if (l != null && l.autor.isNotEmpty) ...[
                  const SizedBox(height: Espaco.xxs),
                  Text(l.autor, textAlign: TextAlign.center, style: e.corpoFraco),
                ],
                const SizedBox(height: Espaco.s),
                _Etiqueta(
                  texto: l != null ? t.simplesCadastrado : t.simplesForaDoCatalogo,
                  cor: l != null ? c.marca : c.alertaForte,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Espaco.l, 0, Espaco.l, Espaco.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (l == null) ...[
                  const SizedBox(height: Espaco.l),
                  Text(t.simplesNaoCadastradoTexto(isbn), style: e.corpo),
                ],
                TituloSecao(t.simplesDadosLivro),
                _CartaoDados(
                  linhas: [
                    if (l != null) (t.simplesCampoTitulo, l.titulo),
                    if (l != null && l.autor.isNotEmpty) (t.simplesCampoAutor, l.autor),
                    if (l != null && l.editora.isNotEmpty) (t.simplesCampoEditora, l.editora),
                    (t.simplesCampoIsbn, isbn),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: aoEscanearOutro == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Espaco.l, Espaco.xs, Espaco.l, Espaco.m),
                child: FilledButton.icon(
                  onPressed: aoEscanearOutro,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(t.simplesEscanearOutro),
                ),
              ),
            ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto, required this.cor});
  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: Espaco.s, vertical: Espaco.xxs),
    decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(Raio.pilula)),
    child: Text(texto, style: context.estilos.rotulo.copyWith(color: context.cores.sobreMarca)),
  );
}

class _CartaoDados extends StatelessWidget {
  const _CartaoDados({required this.linhas});
  final List<(String, String)> linhas;

  @override
  Widget build(BuildContext context) {
    final e = context.estilos;
    final c = context.cores;
    return Container(
      decoration: BoxDecoration(
        color: c.superficie,
        border: Border.all(color: c.pauta),
        borderRadius: BorderRadius.circular(Raio.cartao),
      ),
      child: Column(
        children: [
          for (var i = 0; i < linhas.length; i++) ...[
            if (i > 0) Divider(height: 1, indent: Espaco.m, endIndent: Espaco.m, color: c.pauta),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Espaco.m, vertical: Espaco.s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 88, child: Text(linhas[i].$1, style: e.apoio)),
                  Expanded(child: Text(linhas[i].$2, style: e.corpo)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
