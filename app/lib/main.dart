import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'simples/app_simples.dart';

/// Por enquanto o app roda no modo simples: lê o código de barras e mostra o nome do livro
/// a partir de um catálogo fixo, sem servidor. O app completo (fichas, contas, listas...)
/// continua no código e é ligado com `--dart-define=MODO_COMPLETO=true`.
const modoCompleto = bool.fromEnvironment('MODO_COMPLETO');

void main() {
  if (!modoCompleto) {
    runApp(const AppSimples());
    return;
  }
  usePathUrlStrategy(); // URLs legíveis na web: /obra/{id}, /ficha/{slug}
  runApp(
    ProviderScope(
      // Sem nova tentativa automática: as telas oferecem "Tentar de novo".
      retry: (_, _) => null,
      child: const AppEntrelinhas(),
    ),
  );
}
