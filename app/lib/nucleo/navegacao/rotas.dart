import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../funcionalidades/busca/tela_busca.dart';
import '../../funcionalidades/conta/apresentacao/tela_entrar.dart';
import '../../funcionalidades/ficha/tela_ficha.dart';
import '../../funcionalidades/inicio/tela_inicio.dart';
import 'casca.dart';

final chaveRaiz = GlobalKey<NavigatorState>();

final roteadorProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: chaveRaiz,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => CascaNavegacao(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (_, _) => const TelaInicio()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/listas', builder: (_, _) => const _Provisoria('Listas')),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/perfil', builder: (_, _) => const _Provisoria('Perfil')),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/acervo', builder: (_, _) => const _Provisoria('Acervo')),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/revisao', builder: (_, _) => const _Provisoria('Revisão')),
          ]),
        ],
      ),
      GoRoute(
        path: '/busca',
        parentNavigatorKey: chaveRaiz,
        builder: (_, s) => TelaBusca(termoInicial: s.uri.queryParameters['q'] ?? ''),
      ),
      GoRoute(
        path: '/obra/:id',
        parentNavigatorKey: chaveRaiz,
        builder: (_, s) => TelaFicha(
          obraId: s.pathParameters['id']!,
          confirmarReconhecimento: s.uri.queryParameters['reconhecido'] == '1',
        ),
      ),
      GoRoute(
        path: '/entrar',
        parentNavigatorKey: chaveRaiz,
        builder: (_, s) => TelaEntrar(depois: s.uri.queryParameters['depois']),
      ),
      GoRoute(
        path: '/cadastro',
        parentNavigatorKey: chaveRaiz,
        builder: (_, s) => TelaEntrar(cadastro: true, depois: s.uri.queryParameters['depois']),
      ),
      GoRoute(
        path: '/recuperar-senha',
        parentNavigatorKey: chaveRaiz,
        builder: (_, _) => const TelaRecuperarSenha(),
      ),
      GoRoute(
        path: '/redefinir-senha',
        parentNavigatorKey: chaveRaiz,
        builder: (_, s) => TelaRecuperarSenha(token: s.uri.queryParameters['token']),
      ),
    ],
  );
});

class _Provisoria extends StatelessWidget {
  const _Provisoria(this.nome);
  final String nome;
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text(nome)));
}
