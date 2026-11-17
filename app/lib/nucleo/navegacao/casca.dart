import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../funcionalidades/conta/dados/conta_repositorio.dart';
import '../../l10n/textos.dart';
import '../provedores.dart';
import '../tema/tema.dart';

class _Destino {
  const _Destino(this.rotulo, this.icone, this.iconeAtivo, this.caminho, {this.ramo});
  final String rotulo;
  final IconData icone;
  final IconData iconeAtivo;
  final String caminho;

  /// Índice do ramo no StatefulShellRoute; null = abre em tela cheia (Escanear).
  final int? ramo;
}

/// Casca de navegação: barra inferior no celular; trilho lateral a partir de ~900 px.
class CascaNavegacao extends ConsumerWidget {
  const CascaNavegacao({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Textos.of(context);
    final usuario = ref.watch(sessaoProvider).value;
    final larga = MediaQuery.sizeOf(context).width >= Espaco.larguraLarga;
    final mostraExtras = kIsWeb || larga;
    final destinos = <_Destino>[
      _Destino(t.navInicio, Icons.home_outlined, Icons.home, '/', ramo: 0),
      if (ref.watch(configuracaoProvider).podeExibir('scanner'))
        _Destino(t.navEscanear, Icons.qr_code_scanner, Icons.qr_code_scanner, '/escanear'),
      _Destino(t.navListas, Icons.bookmarks_outlined, Icons.bookmarks, '/listas', ramo: 1),
      _Destino(t.navPerfil, Icons.person_outline, Icons.person, '/perfil', ramo: 2),
      if (mostraExtras && (usuario?.temOrganizacao ?? false))
        _Destino(t.navAcervo, Icons.local_library_outlined, Icons.local_library, '/acervo',
            ramo: 3),
      if (mostraExtras && (usuario?.revisor ?? false))
        _Destino(t.navRevisao, Icons.rate_review_outlined, Icons.rate_review, '/revisao',
            ramo: 4),
    ];
    final selecionado = destinos.indexWhere((d) => d.ramo == shell.currentIndex);

    void ir(int i) {
      final d = destinos[i];
      if (d.ramo == null) {
        context.push(d.caminho);
      } else {
        shell.goBranch(d.ramo!, initialLocation: d.ramo == shell.currentIndex);
      }
    }

    if (larga) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selecionado < 0 ? null : selecionado,
              onDestinationSelected: ir,
              labelType: NavigationRailLabelType.all,
              minWidth: 88,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: Espaco.m),
                child: Text('E', style: context.estilos.marca.copyWith(fontSize: 28)),
              ),
              destinations: [
                for (final d in destinos)
                  NavigationRailDestination(
                    icon: Icon(d.icone),
                    selectedIcon: Icon(d.iconeAtivo),
                    label: Text(d.rotulo),
                  ),
              ],
            ),
            VerticalDivider(width: 1, color: context.cores.pauta),
            Expanded(child: shell),
          ],
        ),
      );
    }
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: context.cores.pauta))),
        child: NavigationBar(
          selectedIndex: selecionado < 0 ? 0 : selecionado,
          onDestinationSelected: ir,
          height: 64,
          destinations: [
            for (final d in destinos)
              NavigationDestination(
                icon: Icon(d.icone),
                selectedIcon: Icon(d.iconeAtivo),
                label: d.rotulo,
              ),
          ],
        ),
      ),
    );
  }
}
