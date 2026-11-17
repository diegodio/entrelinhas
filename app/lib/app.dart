import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'l10n/textos.dart';
import 'nucleo/navegacao/rotas.dart';
import 'nucleo/tema/tema.dart';

class AppEntrelinhas extends ConsumerWidget {
  const AppEntrelinhas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
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
      routerConfig: ref.watch(roteadorProvider),
    );
  }
}
