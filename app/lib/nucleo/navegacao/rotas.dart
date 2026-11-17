import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../funcionalidades/acervo/apresentacao/tela_acervo.dart';
import '../../funcionalidades/busca/tela_busca.dart';
import '../../funcionalidades/busca/tela_cadastrar_obra.dart';
import '../../funcionalidades/conta/apresentacao/tela_entrar.dart';
import '../../funcionalidades/conta/apresentacao/tela_perfil.dart';
import '../../funcionalidades/contestacao/tela_contestar.dart';
import '../../funcionalidades/escanear/apresentacao/tela_escanear.dart';
import '../../funcionalidades/escanear/apresentacao/tela_resultado.dart';
import '../../funcionalidades/escanear/dados/reconhecimento_repositorio.dart';
import '../../funcionalidades/ficha/tela_ficha.dart';
import '../../funcionalidades/ficha/tela_ficha_publica.dart';
import '../../funcionalidades/inicio/tela_inicio.dart';
import '../../funcionalidades/listas/apresentacao/tela_listas.dart';
import '../../funcionalidades/metodologia/tela_metodologia.dart';
import '../../funcionalidades/planos/tela_planos.dart';
import '../../funcionalidades/primeiro_uso/tela_boas_vindas.dart';
import '../../funcionalidades/revisao/tela_revisao.dart';
import 'casca.dart';

final chaveRaiz = GlobalKey<NavigatorState>();

/// Avisa o roteador quando o estado do primeiro uso fica conhecido.
class _AvisoPrimeiroUso extends ChangeNotifier {
  void avisar() => notifyListeners();
}

GoRoute _tela(String caminho, Widget Function(GoRouterState s) construir) =>
    GoRoute(path: caminho, parentNavigatorKey: chaveRaiz, builder: (_, s) => construir(s));

final roteadorProvider = Provider<GoRouter>((ref) {
  final aviso = _AvisoPrimeiroUso();
  ref.listen(primeiroUsoConcluidoProvider, (_, _) => aviso.avisar());
  ref.onDispose(aviso.dispose);
  return GoRouter(
    navigatorKey: chaveRaiz,
    initialLocation: '/',
    refreshListenable: aviso,
    redirect: (_, estado) {
      final concluido = ref.read(primeiroUsoConcluidoProvider).value;
      if (concluido == false && estado.matchedLocation == '/') return '/boas-vindas';
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => CascaNavegacao(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (_, _) => const TelaInicio())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/listas', builder: (_, _) => const TelaListas())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/perfil', builder: (_, _) => const TelaPerfil())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/acervo', builder: (_, _) => const TelaAcervo())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/revisao', builder: (_, _) => const TelaFilaRevisao())],
          ),
        ],
      ),
      _tela('/boas-vindas', (_) => const TelaBoasVindas()),
      _tela('/busca', (s) => TelaBusca(termoInicial: s.uri.queryParameters['q'] ?? '')),
      _tela(
        '/obra/:id',
        (s) => TelaFicha(
          obraId: s.pathParameters['id']!,
          confirmarReconhecimento: s.uri.queryParameters['reconhecido'] == '1',
        ),
      ),
      _tela('/obra/:id/contestar', (s) => TelaContestar(obraId: s.pathParameters['id']!)),
      _tela('/ficha/:slug', (s) => TelaFichaPublica(slug: s.pathParameters['slug']!)),
      _tela('/escanear', (s) => TelaEscanear(abrirIsbn: s.uri.queryParameters['isbn'] == '1')),
      _tela(
        '/reconhecimento',
        (s) => TelaResultadoReconhecimento(
          resultado:
              s.extra as ResultadoReconhecimento? ??
              const ResultadoReconhecimento(status: 'nao_identificado'),
        ),
      ),
      _tela(
        '/reconhecimento/correcao',
        (s) => TelaCorrecaoReconhecimento(obraRecusadaId: s.extra as String? ?? ''),
      ),
      _tela('/cadastrar-obra', (s) => TelaCadastrarObra(isbn: s.uri.queryParameters['isbn'] ?? '')),
      _tela('/lista/:id', (s) => TelaLista(listaId: s.pathParameters['id']!)),
      _tela('/planos', (_) => const TelaPlanos()),
      _tela('/metodologia', (_) => const TelaMetodologia()),
      _tela(
        '/acervo/:org/lista/:lista',
        (s) =>
            TelaListaAcervo(orgId: s.pathParameters['org']!, listaId: s.pathParameters['lista']!),
      ),
      _tela(
        '/acervo/:org/lista/:lista/relatorio',
        (s) => TelaRelatorio(orgId: s.pathParameters['org']!, listaId: s.pathParameters['lista']!),
      ),
      _tela('/revisao/:obraId', (s) => TelaRevisarFicha(obraId: s.pathParameters['obraId']!)),
      _tela('/entrar', (s) => TelaEntrar(depois: s.uri.queryParameters['depois'])),
      _tela(
        '/cadastro',
        (s) => TelaEntrar(cadastro: true, depois: s.uri.queryParameters['depois']),
      ),
      _tela('/recuperar-senha', (_) => const TelaRecuperarSenha()),
      _tela('/redefinir-senha', (s) => TelaRecuperarSenha(token: s.uri.queryParameters['token'])),
    ],
  );
});
