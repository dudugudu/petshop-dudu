import 'package:flutter/material.dart';

// Cor principal (teal 700). Texto branco sobre ela tem contraste suficiente.
const Color corPrincipal = Color(0xFF00796B);

const List<Color> _coresPets = [
  Color(0xFF00897B),
  Color(0xFFF4511E),
  Color(0xFF8E24AA),
  Color(0xFF1E88E5),
  Color(0xFFF9A825),
  Color(0xFFD81B60),
];

// Cor de fundo e do texto do avatar. O mesmo nome sempre ganha a mesma cor.
({Color fundo, Color texto}) estiloAvatar(String nome, Brightness brilho) {
  final int soma = nome.codeUnits.fold(0, (total, codigo) => total + codigo);
  final Color base = _coresPets[soma % _coresPets.length];

  if (brilho == Brightness.dark) {
    return (
      fundo: base.withValues(alpha: 0.28),
      texto: Color.lerp(base, Colors.white, 0.4)!,
    );
  }
  return (
    fundo: base.withValues(alpha: 0.16),
    texto: Color.lerp(base, Colors.black, 0.15)!,
  );
}

// Tema claro e escuro. As cores vêm do ColorScheme, então funcionam nos dois.
ThemeData criarTema(Brightness brilho) {
  final ColorScheme esquema = ColorScheme.fromSeed(
    seedColor: corPrincipal,
    brightness: brilho,
  );
  final bool escuro = brilho == Brightness.dark;
  final TextTheme base = ThemeData(useMaterial3: true, colorScheme: esquema).textTheme;

  final OutlineInputBorder bordaSuave = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: esquema.outlineVariant.withValues(alpha: 0.7)),
  );
  OutlineInputBorder destaque(Color cor, double largura) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: cor, width: largura),
    );
  }

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: esquema.surfaceContainerLow,
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        for (final plataforma in TargetPlatform.values)
          plataforma: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    textTheme: base.copyWith(
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: corPrincipal,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: escuro ? esquema.surfaceContainerHigh : esquema.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: esquema.outlineVariant.withValues(alpha: escuro ? 0.25 : 0.4),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: esquema.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(color: esquema.onSurfaceVariant),
      prefixIconColor: esquema.onSurfaceVariant,
      suffixIconColor: esquema.onSurfaceVariant,
      border: bordaSuave,
      enabledBorder: bordaSuave,
      focusedBorder: destaque(esquema.primary, 1.6),
      errorBorder: destaque(esquema.error, 1.2),
      focusedErrorBorder: destaque(esquema.error, 1.6),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: corPrincipal,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 56),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: corPrincipal,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: esquema.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}
