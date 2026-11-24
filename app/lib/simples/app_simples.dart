import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart';

import '../l10n/textos.dart';
import '../nucleo/tema/tema.dart';
import 'tela_leitor_simples.dart';

/// App do modo simples: uma tela só, que lê o código de barras e mostra o nome do livro.
class AppSimples extends StatelessWidget {
  const AppSimples({super.key});

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
    home: const TelaLeitorSimples(),
  );
}
