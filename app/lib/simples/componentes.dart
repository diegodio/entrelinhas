import 'package:material_ui/material_ui.dart';

import '../nucleo/tema/tema.dart';
import 'catalogo.dart';

/// Tons da capa gerada, escolhidos pelo ISBN (o mesmo livro sempre tem a mesma cor).
const tonsCapa = [
  Color(0xFF2F5D50),
  Color(0xFF2F6F8F),
  Color(0xFF8F6410),
  Color(0xFFB05129),
  Color(0xFF6B3F7A),
  Color(0xFF3D4F7C),
  Color(0xFF7A4A2E),
];

Color corDaCapa(String isbn) {
  // FNV-1a: espalha bem ISBNs parecidos (mesmo prefixo de país e editora).
  var h = 0x811c9dc5;
  for (final c in isbn.codeUnits) {
    h = ((h ^ c) * 0x01000193) & 0xffffffff;
  }
  return tonsCapa[h % tonsCapa.length];
}

/// Capa desenhada (sem imagem): bloco colorido com título e autor.
class CapaGerada extends StatelessWidget {
  const CapaGerada({super.key, required this.livro, this.largura = 56});

  final Livro? livro;
  final double largura;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final altura = largura * 1.5;
    final grande = largura >= 100;
    final cor = livro == null ? c.superficieSuave : corDaCapa(livro!.isbn);
    final desenhada = Container(
      width: largura,
      height: altura,
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(grande ? 8 : 4),
        boxShadow: grande
            ? [
                BoxShadow(
                  color: c.tinta.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.all(largura * 0.09),
      child: livro == null
          ? Icon(Icons.help_outline, color: c.tintaFraca, size: largura * 0.4)
          : largura < 70
          // Capa pequena: só a inicial, legível.
          ? Center(
              child: Text(
                livro!.titulo.characters.first.toUpperCase(),
                style: TextStyle(
                  fontFamily: Fontes.editorial,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: largura * 0.5,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: largura * 0.025, width: largura * 0.3, color: Colors.white54),
                SizedBox(height: largura * 0.08),
                Expanded(
                  child: Text(
                    livro!.titulo,
                    maxLines: grande ? 5 : 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: Fontes.editorial,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: largura * (grande ? 0.12 : 0.16),
                      height: 1.15,
                    ),
                  ),
                ),
                if (grande && livro!.autor.isNotEmpty)
                  Text(
                    livro!.autor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: Fontes.interface,
                      color: Colors.white70,
                      fontSize: largura * 0.075,
                    ),
                  ),
              ],
            ),
    );
    final l = livro;
    final fontes = l == null ? const <String>[] : fontesDeCapa(l, grande: grande);
    return ExcludeSemantics(
      child: fontes.isEmpty
          ? desenhada
          : Container(
              width: largura,
              height: altura,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(grande ? 8 : 4),
                boxShadow: grande
                    ? [
                        BoxShadow(
                          color: c.tinta.withValues(alpha: 0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: _CapaEmCadeia(fontes: fontes, reserva: desenhada),
            ),
    );
  }
}

/// Onde procurar a capa, em ordem: a do catálogo ou da API, depois a da Open Library pelo
/// ISBN (gratuita, sem chave; `default=false` devolve 404 quando não há capa). A capa
/// desenhada fica por último.
List<String> fontesDeCapa(Livro livro, {bool grande = false}) => [
  if (livro.capaUrl != null && livro.capaUrl!.isNotEmpty) livro.capaUrl!,
  'https://covers.openlibrary.org/b/isbn/${livro.isbn}-${grande ? 'L' : 'M'}.jpg?default=false',
];

/// Tenta cada fonte até uma funcionar; se nenhuma funcionar, mostra [reserva].
class _CapaEmCadeia extends StatefulWidget {
  const _CapaEmCadeia({required this.fontes, required this.reserva});
  final List<String> fontes;
  final Widget reserva;

  @override
  State<_CapaEmCadeia> createState() => _CapaEmCadeiaState();
}

class _CapaEmCadeiaState extends State<_CapaEmCadeia> {
  int _i = 0;

  @override
  void didUpdateWidget(_CapaEmCadeia antigo) {
    super.didUpdateWidget(antigo);
    if (antigo.fontes.join() != widget.fontes.join()) _i = 0;
  }

  void _proxima() {
    // Chamado durante o build do errorBuilder: avança no próximo quadro.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _i < widget.fontes.length) setState(() => _i++);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_i >= widget.fontes.length) return widget.reserva;
    final url = widget.fontes[_i];
    Widget erro(BuildContext _, Object _, StackTrace? _) {
      _proxima();
      return widget.reserva;
    }

    if (url.startsWith('assets/')) {
      return Image.asset(url, fit: BoxFit.cover, errorBuilder: erro);
    }
    return Image.network(
      url,
      key: ValueKey(url),
      fit: BoxFit.cover,
      // Na web, imagens de sites sem CORS (como as capas do Google Books) são mostradas
      // por um elemento <img> em vez de falhar.
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      errorBuilder: erro,
      loadingBuilder: (_, filho, progresso) => progresso == null ? filho : widget.reserva,
    );
  }
}

/// Linha de lista: capa pequena, título, apoio e seta.
class LinhaLivroSimples extends StatelessWidget {
  const LinhaLivroSimples({
    super.key,
    required this.livro,
    required this.titulo,
    this.apoio,
    this.aoTocar,
  });

  final Livro? livro;
  final String titulo;
  final String? apoio;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final e = context.estilos;
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(Raio.campo),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Espaco.xs, horizontal: Espaco.xs),
        child: Row(
          children: [
            CapaGerada(livro: livro, largura: 44),
            const SizedBox(width: Espaco.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: e.destaque, maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (apoio != null && apoio!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(apoio!, style: e.apoio, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.cores.tintaFraca),
          ],
        ),
      ),
    );
  }
}

/// Cabeçalho de seção com ação opcional à direita ("Ver tudo").
class TituloSecao extends StatelessWidget {
  const TituloSecao(this.texto, {super.key, this.acao, this.aoTocarAcao});
  final String texto;
  final String? acao;
  final VoidCallback? aoTocarAcao;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: Espaco.l, bottom: Espaco.xs),
    child: Row(
      children: [
        Expanded(
          child: Semantics(header: true, child: Text(texto, style: context.estilos.tituloSecao)),
        ),
        if (acao != null) TextButton(onPressed: aoTocarAcao, child: Text(acao!)),
      ],
    ),
  );
}
