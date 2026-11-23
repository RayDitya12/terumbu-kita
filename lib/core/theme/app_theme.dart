import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema Material 3 terpusat bernuansa laut (spec.md §9).
/// Semua warna bersumber dari [AppColors]; widget tidak boleh hardcode.

/// Varian tema (unit tema): A = latar pucat + header gradien (default),
/// B = gelap penuh. Tukar lewat satu konstanta [kTerumbuThemeVariant].
enum TerumbuThemeVariant { a, b }

const TerumbuThemeVariant kTerumbuThemeVariant = TerumbuThemeVariant.a;

abstract final class AppTheme {
  /// Tema aktif untuk varian terpilih; dipakai app.dart.
  static ThemeData forVariant(TerumbuThemeVariant variant) =>
      variant == TerumbuThemeVariant.b ? dark() : light();

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
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkCard : AppColors.warmWhite,
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // Koral khusus untuk CTA; foreground gelap agar lolos AA.
          backgroundColor: AppColors.coral,
          foregroundColor: AppColors.ink,
          minimumSize: const Size(0, 52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.teal,
        linearTrackColor: isDark ? AppColors.darkCard : AppColors.seafoam,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        // Bar gelap menyatukan transisi Home imersif ke layar lain.
        backgroundColor: AppColors.deepOcean,
        indicatorColor: AppColors.seafoam,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.teal
                : AppColors.foam.withValues(alpha: 0.75),
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12.5,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? AppColors.foam
                : AppColors.foam.withValues(alpha: 0.75),
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

/// Gradien pita header layar sekunder (deep ocean → teal).
const LinearGradient seaHeaderGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [AppColors.deepOcean, AppColors.teal],
);
