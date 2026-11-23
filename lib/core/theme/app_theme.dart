import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema Material 3 terpusat bernuansa laut (spec.md §9).
/// Semua warna bersumber dari [AppColors]; widget tidak boleh hardcode.
abstract final class AppTheme {
  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  /// Skema warna sesuai palet: seed teal lalu override per peran.
  /// Kontras AA: teks gelap di atas koral/kuning/sea green (lihat unit tema).
  static ColorScheme _scheme(Brightness brightness) {
    final seed = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: brightness,
    );
    if (brightness == Brightness.dark) {
      return seed.copyWith(
        primary: AppColors.seaGreen,
        onPrimary: AppColors.ink,
        secondary: AppColors.teal,
        onSecondary: AppColors.foam,
        tertiary: AppColors.sunYellow,
        onTertiary: AppColors.ink,
        surface: AppColors.deepOcean,
        onSurface: AppColors.foam,
        surfaceContainerHighest: AppColors.darkCard,
      );
    }
    return seed.copyWith(
      primary: AppColors.teal,
      onPrimary: AppColors.foam,
      secondary: AppColors.seaGreen,
      onSecondary: AppColors.ink,
      tertiary: AppColors.sunYellow,
      onTertiary: AppColors.ink,
      surface: AppColors.foam,
      onSurface: AppColors.ink,
      surfaceContainerHighest: AppColors.seafoam,
      onSurfaceVariant: AppColors.inkSoft,
    );
  }

  static ThemeData _base(Brightness brightness) {
    final scheme = _scheme(brightness);
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

/// Gradient latar untuk layar terumbu (Home) — warna scene, bukan palet UI.
const LinearGradient reefBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppColors.reefSceneTop, AppColors.reefSceneBottom],
);
