import 'package:flutter/material.dart';

/// Satu-satunya sumber warna aplikasi (unit tema, spec.md §9).
/// Widget dilarang memakai literal Color(0x...) atau Colors.* —
/// pakai token di sini atau colorScheme dari AppTheme.
abstract final class AppColors {
  // Palet inti.
  static const Color deepOcean = Color(0xFF0B3C49);
  static const Color teal = Color(0xFF0F766E);
  static const Color seaGreen = Color(0xFF2BB5A0);
  static const Color seafoam = Color(0xFFE3F4F0);
  static const Color foam = Color(0xFFF4FBF9);
  static const Color coral = Color(0xFFFF7F66);
  static const Color sunYellow = Color(0xFFFFD166);
  static const Color ink = Color(0xFF0B2E33);

  // Turunan untuk kontras AA di latar terang (teks/ikon kecil).
  static const Color coralInk = Color(0xFFC24A2E);
  static const Color amberInk = Color(0xFF8A5A00);
  static const Color inkSoft = Color(0xFF456068);

  // Putih hangat untuk kartu di atas latar Foam.
  static const Color warmWhite = Color(0xFFFFFDF8);

  // Tint kartu informatif (pemetaan ulang poles kecil ke palet baru).
  static const Color seaTint = seafoam;
  static const Color coralTint = Color(0xFFFFE9E1);
  static const Color amberTint = Color(0xFFFFF1D0);

  // Latar kartu pada varian tema gelap.
  static const Color darkCard = Color(0xFF0F4452);

  // Cahaya glow splash (dipindah dari hardcode).
  static const Color splashGlow = Color(0x6629E6FF);

  // Warna latar scene Home; terikat visual reef_painter, bukan palet UI.
  static const Color reefSceneTop = Color(0xFF062A3A);
  static const Color reefSceneBottom = Color(0xFF0E5E78);
}
