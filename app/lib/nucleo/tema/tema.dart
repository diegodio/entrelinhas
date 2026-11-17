// Tema Entrelinhas: única fonte de cor, tipografia, espaço e forma (seção 7).
// Nada de cor fora deste arquivo. Um tema escuro entra depois trocando só os tokens.

import 'package:material_ui/material_ui.dart';

/// Tokens de cor. Para um tema escuro, crie outra instância e troque no [TemaEntrelinhas].
@immutable
class CoresEntrelinhas extends ThemeExtension<CoresEntrelinhas> {
  const CoresEntrelinhas({
    required this.papel,
    required this.superficie,
    required this.superficieSuave,
    required this.tinta,
    required this.tintaFraca,
    required this.pauta,
    required this.pautaForte,
    required this.marca,
    required this.sobreMarca,
    required this.acento,
    required this.alertaForte,
    required this.faixas,
    required this.sobreFaixa,
  });

  final Color papel;
  final Color superficie;
  final Color superficieSuave;
  final Color tinta;
  final Color tintaFraca;
  final Color pauta;
  final Color pautaForte;
  final Color marca;
  final Color sobreMarca;

  /// Destaque pontual. O prompt pedia #B4532A; escurecido para #B05129 (mesma família)
  /// porque #B4532A ficava em 4,4:1 sobre [papel]. Ver docs/decisoes.md.
  final Color acento;
  final Color alertaForte;

  /// Escala de faixas: a única família saturada da interface.
  final Map<String, Color> faixas;
  final Color sobreFaixa;

  static const claro = CoresEntrelinhas(
    papel: Color(0xFFF6F1E7),
    superficie: Color(0xFFFFFBF3),
    superficieSuave: Color(0xFFEDE5D4),
    tinta: Color(0xFF23302B),
    tintaFraca: Color(0xFF5E6A63),
    pauta: Color(0xFFE3DAC8),
    pautaForte: Color(0xFFCFC4AE),
    marca: Color(0xFF2F5D50),
    sobreMarca: Color(0xFFFFFBF3),
    acento: Color(0xFFB05129),
    alertaForte: Color(0xFF8C2F1B),
    faixas: {
      'Livre': Color(0xFF2F5D50),
      '10+': Color(0xFF2F6F8F),
      '12+': Color(0xFF8F6410),
      '14+': Color(0xFFB05129),
      '16+': Color(0xFF8C2F1B),
      '18+': Color(0xFF2B2430),
    },
    sobreFaixa: Color(0xFFFFFBF3),
  );

  Color corDaFaixa(String? faixa) => faixas[faixa] ?? tintaFraca;

  @override
  CoresEntrelinhas copyWith() => this;

  @override
  CoresEntrelinhas lerp(ThemeExtension<CoresEntrelinhas>? other, double t) =>
      other is CoresEntrelinhas && t >= 0.5 ? other : this;
}

abstract final class Fontes {
  static const editorial = 'Fraunces';
  static const interface = 'NunitoSans';
}

/// Escala tipográfica (seção 7).
abstract final class Tamanhos {
  static const marca = 34.0;
  static const tituloObra = 26.0;
  static const tituloSecao = 20.0;
  static const destaque = 17.0;
  static const corpo = 16.0;
  static const corpoMenor = 15.0;
  static const apoio = 14.0;
  static const apoioMenor = 13.0;
  static const legenda = 12.0;
}

/// Espaçamentos em múltiplos de 4.
abstract final class Espaco {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const s = 12.0;
  static const m = 16.0;
  static const l = 24.0;
  static const xl = 36.0;
  static const margemLateral = 24.0;
  static const larguraLeitura = 720.0;
  static const larguraLarga = 900.0;
}

abstract final class Raio {
  static const campo = 12.0;
  static const cartao = 16.0;
  static const pilula = 999.0;
  static const capa = 4.0;
}

abstract final class Movimento {
  static const curto = Duration(milliseconds: 150);
  static const medio = Duration(milliseconds: 250);
}

/// Estilos de texto nomeados. Use estes, não TextStyle avulsos.
@immutable
class EstilosTexto extends ThemeExtension<EstilosTexto> {
  const EstilosTexto(this.c);
  final CoresEntrelinhas c;

  TextStyle get marca => TextStyle(
      fontFamily: Fontes.editorial, fontWeight: FontWeight.w600, fontSize: Tamanhos.marca,
      letterSpacing: -0.5, color: c.tinta, height: 1.1);
  TextStyle get tituloObra => TextStyle(
      fontFamily: Fontes.editorial, fontWeight: FontWeight.w600, fontSize: Tamanhos.tituloObra,
      color: c.tinta, height: 1.15);
  TextStyle get tituloSecao => TextStyle(
      fontFamily: Fontes.editorial, fontWeight: FontWeight.w600, fontSize: Tamanhos.tituloSecao,
      color: c.tinta, height: 1.2);
  TextStyle get destaque => TextStyle(
      fontFamily: Fontes.editorial, fontWeight: FontWeight.w500, fontSize: Tamanhos.destaque,
      color: c.tinta, height: 1.25);
  TextStyle get corpo => TextStyle(
      fontFamily: Fontes.interface, fontSize: Tamanhos.corpoMenor, color: c.tinta, height: 1.5);
  TextStyle get corpoFraco => corpo.copyWith(color: c.tintaFraca);
  TextStyle get apoio => TextStyle(
      fontFamily: Fontes.interface, fontSize: Tamanhos.apoio, color: c.tintaFraca, height: 1.4);
  TextStyle get rotulo => TextStyle(
      fontFamily: Fontes.interface, fontSize: Tamanhos.apoioMenor, fontWeight: FontWeight.w700,
      color: c.tintaFraca);
  TextStyle get rotuloMaiusculo => TextStyle(
      fontFamily: Fontes.interface, fontSize: Tamanhos.legenda, fontWeight: FontWeight.w700,
      letterSpacing: 1, color: c.tintaFraca);
  TextStyle get legenda => TextStyle(
      fontFamily: Fontes.interface, fontSize: Tamanhos.legenda, color: c.tintaFraca, height: 1.4);
  TextStyle get botao => const TextStyle(
      fontFamily: Fontes.interface, fontSize: Tamanhos.corpoMenor, fontWeight: FontWeight.w700);
  TextStyle get slogan => TextStyle(
      fontFamily: Fontes.interface, fontSize: Tamanhos.corpoMenor, fontStyle: FontStyle.italic,
      color: c.tintaFraca);

  @override
  EstilosTexto copyWith() => this;

  @override
  EstilosTexto lerp(ThemeExtension<EstilosTexto>? other, double t) =>
      other is EstilosTexto && t >= 0.5 ? other : this;
}

extension TemaContexto on BuildContext {
  CoresEntrelinhas get cores => Theme.of(this).extension<CoresEntrelinhas>()!;
  EstilosTexto get estilos => Theme.of(this).extension<EstilosTexto>()!;
}

abstract final class TemaEntrelinhas {
  static ThemeData construir([CoresEntrelinhas c = CoresEntrelinhas.claro]) {
    final estilos = EstilosTexto(c);
    final esquema = ColorScheme(
      brightness: Brightness.light,
      primary: c.marca,
      onPrimary: c.sobreMarca,
      secondary: c.acento,
      onSecondary: c.sobreMarca,
      error: c.alertaForte,
      onError: c.sobreMarca,
      surface: c.papel,
      onSurface: c.tinta,
      surfaceContainerLowest: c.superficie,
      surfaceContainerLow: c.superficie,
      surfaceContainer: c.superficie,
      surfaceContainerHigh: c.superficieSuave,
      surfaceContainerHighest: c.superficieSuave,
      onSurfaceVariant: c.tintaFraca,
      outline: c.pautaForte,
      outlineVariant: c.pauta,
    );
    final bordaCampo = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Raio.campo),
      borderSide: BorderSide(color: c.pautaForte),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: c.papel,
      fontFamily: Fontes.interface,
      extensions: [c, estilos],
      textTheme: TextTheme(
        displaySmall: estilos.marca,
        headlineSmall: estilos.tituloObra,
        titleLarge: estilos.tituloSecao,
        titleMedium: estilos.destaque,
        bodyLarge: estilos.corpo.copyWith(fontSize: Tamanhos.corpo),
        bodyMedium: estilos.corpo,
        bodySmall: estilos.apoio,
        labelLarge: estilos.botao,
        labelMedium: estilos.rotulo,
        labelSmall: estilos.legenda,
      ),
      dividerTheme: DividerThemeData(color: c.pauta, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: c.papel,
        foregroundColor: c.tinta,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: estilos.destaque,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.superficie,
        contentPadding: const EdgeInsets.symmetric(horizontal: Espaco.m, vertical: Espaco.m),
        border: bordaCampo,
        enabledBorder: bordaCampo,
        focusedBorder: bordaCampo.copyWith(borderSide: BorderSide(color: c.marca, width: 2)),
        errorBorder: bordaCampo.copyWith(borderSide: BorderSide(color: c.alertaForte)),
        hintStyle: estilos.corpoFraco,
        labelStyle: estilos.rotulo,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.marca,
          foregroundColor: c.sobreMarca,
          minimumSize: const Size(64, 52),
          textStyle: estilos.botao,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Raio.cartao)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.tinta,
          minimumSize: const Size(44, 44),
          side: BorderSide(color: c.pautaForte),
          textStyle: estilos.botao,
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.marca,
          minimumSize: const Size(44, 44),
          textStyle: estilos.botao,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.superficie,
        side: BorderSide(color: c.pautaForte),
        shape: const StadiumBorder(),
        labelStyle: estilos.corpo.copyWith(fontSize: Tamanhos.apoio),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.superficie,
        indicatorColor: c.superficieSuave,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => estilos.rotulo.copyWith(
            color: s.contains(WidgetState.selected) ? c.marca : c.tintaFraca,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? c.marca : c.tintaFraca),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.superficie,
        indicatorColor: c.superficieSuave,
        selectedIconTheme: IconThemeData(color: c.marca),
        unselectedIconTheme: IconThemeData(color: c.tintaFraca),
        selectedLabelTextStyle: estilos.rotulo.copyWith(color: c.marca),
        unselectedLabelTextStyle: estilos.rotulo,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.tinta,
        contentTextStyle: estilos.corpo.copyWith(color: c.superficie),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.marca),
      pageTransitionsTheme: const PageTransitionsTheme(),
    );
  }
}
