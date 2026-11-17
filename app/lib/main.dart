import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';

void main() {
  usePathUrlStrategy(); // URLs legíveis na web: /obra/{id}, /ficha/{slug}
  runApp(
    ProviderScope(
      // Sem nova tentativa automática: as telas oferecem "Tentar de novo".
      retry: (_, _) => null,
      child: const AppEntrelinhas(),
    ),
  );
}
