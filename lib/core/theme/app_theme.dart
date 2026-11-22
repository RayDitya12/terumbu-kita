import 'package:flutter/material.dart';

/// Tema Material 3 terpusat bernuansa laut (spec.md §9).
/// Jangan hardcode warna di widget — pakai colorScheme/token di sini.
abstract final class AppTheme {
  /// Biji warna: biru laut dalam.
  static const Color _seed = Color(0xFF0B6E8C);

  /// Warna latar terumbu (dekoratif, dipakai lewat gradient).
  static const Color reefGradientTop = Color(0xFF062A3A);
  static const Color reefGradientBottom = Color(0xFF0E5E78);
  static const Color coralAccent = Color(0xFFFF8A65);
  static const Color healthWarn = Color(0xFFFFC96B);

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Gradient latar untuk layar terumbu (Home).
const LinearGradient reefBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppTheme.reefGradientTop, AppTheme.reefGradientBottom],
);
