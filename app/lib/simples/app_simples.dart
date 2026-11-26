import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart';

import '../l10n/textos.dart';
import '../nucleo/tema/tema.dart';
import 'catalogo.dart';
import 'historico.dart';
import 'tela_historico_simples.dart';
import 'tela_inicio_simples.dart';
import 'tela_leitor_simples.dart';
import 'tela_livro_simples.dart';

/// App do modo simples: Início e Histórico em abas, com o botão de escanear no centro da
/// barra inferior. Ler um código abre a página do livro.
class AppSimples extends StatelessWidget {
  const AppSimples({super.key, this.catalogo, this.historico, this.abrirLeitor});

  /// Injetáveis nos testes.
  final Catalogo? catalogo;
  final Historico? historico;
  final Future<String?> Function(BuildContext)? abrirLeitor;

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (c) => Textos.of(c).nomeProduto,
    debugShowCheckedModeBanner: false,
    theme: TemaEntrelinhas.construir(),
    themeMode: ThemeMode.light,
    locale: const Locale('pt'),
    supportedLocales: Textos.supportedLocales,
    localizationsDelegates: const [
      Textos.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: TelaPrincipalSimples(catalogo: catalogo, historico: historico, abrirLeitor: abrirLeitor),
  );
}

class TelaPrincipalSimples extends StatefulWidget {
  const TelaPrincipalSimples({super.key, this.catalogo, this.historico, this.abrirLeitor});

  final Catalogo? catalogo;
  final Historico? historico;
  final Future<String?> Function(BuildContext)? abrirLeitor;

  @override
  State<TelaPrincipalSimples> createState() => _TelaPrincipalSimplesState();
}

class _TelaPrincipalSimplesState extends State<TelaPrincipalSimples> {
  Catalogo? _catalogo;
  late final Historico _historico = widget.historico ?? Historico();
  int _aba = 0;

  @override
  void initState() {
    super.initState();
    _catalogo = widget.catalogo;
    if (_catalogo == null) {
      Catalogo.carregar().then((c) => mounted ? setState(() => _catalogo = c) : null);
    }
    if (widget.historico == null) _historico.carregar();
  }

  Future<String?> _abrirLeitorPadrao(BuildContext context) =>
      Navigator.of(context)
          .push<String>(MaterialPageRoute(builder: (_) => const TelaLeitorSimples()));

  Future<void> _escanear() async {
    final isbn = await (widget.abrirLeitor ?? _abrirLeitorPadrao)(context);
    if (isbn == null || !mounted) return;
    await _historico.registrar(isbn);
    if (mounted) _abrir(isbn);
  }

  void _abrir(String isbn) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (c) => TelaLivroSimples(
          livro: _catalogo?.buscar(isbn),
          isbn: isbn,
          aoEscanearOutro: () {
            Navigator.of(c).pop();
            _escanear();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Textos.of(context);
    final c = context.cores;
    final catalogo = _catalogo;
    return Scaffold(
      body: catalogo == null
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _aba,
              children: [
                TelaInicioSimples(
                  catalogo: catalogo,
                  historico: _historico,
                  aoEscanear: _escanear,
                  aoAbrir: _abrir,
                  aoVerHistorico: () => setState(() => _aba = 1),
                ),
                TelaHistoricoSimples(catalogo: catalogo, historico: _historico, aoAbrir: _abrir),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.large(
        onPressed: _escanear,
        tooltip: t.simplesEscanear,
        backgroundColor: c.marca,
        foregroundColor: c.sobreMarca,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, size: 36),
      ),
      bottomNavigationBar: BottomAppBar(
        color: c.superficie,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 72,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            Expanded(
              child: _Aba(
                icone: Icons.home_outlined,
                iconeAtivo: Icons.home,
                rotulo: t.simplesInicio,
                ativa: _aba == 0,
                aoTocar: () => setState(() => _aba = 0),
              ),
            ),
            const SizedBox(width: 96), // espaço do botão central
            Expanded(
              child: _Aba(
                icone: Icons.history_outlined,
                iconeAtivo: Icons.history,
                rotulo: t.simplesHistorico,
                ativa: _aba == 1,
                aoTocar: () => setState(() => _aba = 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Aba extends StatelessWidget {
  const _Aba({
    required this.icone,
    required this.iconeAtivo,
    required this.rotulo,
    required this.ativa,
    required this.aoTocar,
  });

  final IconData icone;
  final IconData iconeAtivo;
  final String rotulo;
  final bool ativa;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final cor = ativa ? c.marca : c.tintaFraca;
    return Semantics(
      selected: ativa,
      button: true,
      child: InkWell(
        onTap: aoTocar,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ativa ? iconeAtivo : icone, color: cor),
            const SizedBox(height: 2),
            Text(
              rotulo,
              style: context.estilos.legenda.copyWith(
                color: cor,
                fontWeight: ativa ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
