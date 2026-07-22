import 'package:flutter/material.dart';

/// Identidade visual do app: uma cor-semente em tom de framboesa/vinho —
/// energética e confiante sem cair no rosa infantilizado, e que funciona
/// tanto para os perfis de hipertrofia/performance quanto para menopausa e
/// terceira idade (ver briefing do produto). Nome/paleta finais da marca
/// ainda não decididos; esta é uma primeira identidade visual coerente
/// para o app parar de depender da semente padrão do Material.
const _corSemente = Color(0xFFB0305A);

TextTheme _ajustarTipografia(TextTheme base) {
  return base.copyWith(
    headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
    headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
    titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
  );
}

ThemeData get temaClaro {
  final colorScheme = ColorScheme.fromSeed(seedColor: _corSemente, brightness: Brightness.light);
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: _ajustarTipografia(ThemeData(brightness: Brightness.light).textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: colorScheme.primaryContainer,
    ),
  );
}

ThemeData get temaEscuro {
  final colorScheme = ColorScheme.fromSeed(seedColor: _corSemente, brightness: Brightness.dark);
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: _ajustarTipografia(ThemeData(brightness: Brightness.dark).textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: colorScheme.primaryContainer,
    ),
  );
}
