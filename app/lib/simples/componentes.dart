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
    final url = livro?.capaUrl;
    return ExcludeSemantics(
      child: url == null
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
              child: Image.network(
                url,
                fit: BoxFit.cover,
                // Sem imagem (rede, CORS, link quebrado): a capa desenhada.
                errorBuilder: (_, _, _) => desenhada,
                loadingBuilder: (_, filho, progresso) => progresso == null ? filho : desenhada,
              ),
            ),
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
