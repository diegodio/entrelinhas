// Página do livro: capa e título em destaque no topo, seções de dados abaixo e a ação
// principal fixa no rodapé. Busca o livro (catálogo, depois APIs) ao abrir.

import 'package:material_ui/material_ui.dart';

import '../l10n/textos.dart';
import '../nucleo/tema/tema.dart';
import 'busca_livros.dart';
import 'catalogo.dart';
import 'componentes.dart';

class TelaLivroSimples extends StatefulWidget {
  const TelaLivroSimples({
    super.key,
    required this.isbn,
    required this.busca,
    this.aoEscanearOutro,
  });

  final String isbn;
  final BuscaLivros busca;
  final VoidCallback? aoEscanearOutro;

  @override
  State<TelaLivroSimples> createState() => _TelaLivroSimplesState();
}

class _TelaLivroSimplesState extends State<TelaLivroSimples> {
  late Future<ResultadoBusca> _resultado = widget.busca.buscar(widget.isbn);

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final c = context.cores;
    return Scaffold(
      appBar: AppBar(backgroundColor: c.superficieSuave),
      body: FutureBuilder<ResultadoBusca>(
        future: _resultado,
        builder: (context, s) {
          final r = s.data;
          if (r == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: Espaco.m),
                  Text(t.simplesProcurando, style: context.estilos.corpoFraco),
                ],
              ),
            );
          }
          return _Conteudo(
            isbn: widget.isbn,
            resultado: r,
            aoTentarDeNovo: () {
              final novo = widget.busca.buscar(widget.isbn);
              setState(() {
                _resultado = novo;
              });
            },
          );
        },
      ),
      bottomNavigationBar: widget.aoEscanearOutro == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Espaco.l, Espaco.xs, Espaco.l, Espaco.m),
                child: FilledButton.icon(
                  onPressed: widget.aoEscanearOutro,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(t.simplesEscanearOutro),
                ),
              ),
            ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.isbn, required this.resultado, required this.aoTentarDeNovo});

  final String isbn;
  final ResultadoBusca resultado;
  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final e = context.estilos;
    final c = context.cores;
    final l = switch (resultado) {
      Encontrado(:final livro) => livro,
      _ => null,
    };
    final (etiqueta, corEtiqueta) = switch (resultado) {
      Encontrado(livro: Livro(fonte: FonteLivro.catalogo)) => (t.simplesCadastrado, c.marca),
      Encontrado(livro: Livro(fonte: FonteLivro.brasilApi)) => (t.simplesFonteBrasilApi, c.marca),
      Encontrado(livro: Livro(fonte: FonteLivro.googleBooks)) => (t.simplesFonteGoogle, c.marca),
      NaoEncontrado() => (t.simplesNaoEncontrado, c.alertaForte),
      FalhaConsulta() => (t.simplesSemConexao, c.alertaForte),
    };
    return ListView(
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
                  l?.titulo ?? t.simplesNaoEncontrado,
                  textAlign: TextAlign.center,
                  style: e.tituloObra,
                ),
              ),
              if (l != null && l.autor.isNotEmpty) ...[
                const SizedBox(height: Espaco.xxs),
                Text(l.autor, textAlign: TextAlign.center, style: e.corpoFraco),
              ],
              const SizedBox(height: Espaco.s),
              _Etiqueta(texto: etiqueta, cor: corEtiqueta),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Espaco.l, 0, Espaco.l, Espaco.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (resultado is NaoEncontrado) ...[
                const SizedBox(height: Espaco.l),
                Text(t.simplesNaoEncontradoTexto(isbn), style: e.corpo),
              ],
              if (resultado is FalhaConsulta) ...[
                const SizedBox(height: Espaco.l),
                Text(t.simplesSemConexaoTexto, style: e.corpo),
                const SizedBox(height: Espaco.s),
                OutlinedButton.icon(
                  onPressed: aoTentarDeNovo,
                  icon: const Icon(Icons.refresh),
                  label: Text(t.botaoTentarDeNovo),
                ),
              ],
              if (l != null && l.sinopse.isNotEmpty) ...[
                TituloSecao(t.simplesSinopse),
                Text(l.sinopse, style: e.corpo),
              ],
              TituloSecao(t.simplesDadosLivro),
              _CartaoDados(
                linhas: [
                  if (l != null) (t.simplesCampoTitulo, l.titulo),
                  if (l != null && l.autor.isNotEmpty) (t.simplesCampoAutor, l.autor),
                  if (l != null && l.editora.isNotEmpty) (t.simplesCampoEditora, l.editora),
                  if (l != null && l.ano.isNotEmpty) (t.simplesCampoAno, l.ano),
                  (t.simplesCampoIsbn, isbn),
                ],
              ),
            ],
          ),
        ),
      ],
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
