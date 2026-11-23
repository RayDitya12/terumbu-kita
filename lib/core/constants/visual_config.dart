import '../../data/models/app_settings.dart';

/// Satu sumber angka konfigurasi efek terumbu per mode kualitas.
abstract final class VisualConfig {
  /// Penuh: 30-40 gelembung; dipilih 36.
  static const fullBubbleCount = 36;

  /// Hemat: separuh dari jumlah Penuh.
  static const hematBubbleFraction = 0.5;

  /// Gelembung tersebar di tiga lapis kedalaman (parallax).
  static const bubbleParallaxLayers = 3;

  /// Panjang loop waktu scene dalam detik (satu periode animasi ambient).
  static const loopSeconds = 120.0;

  /// Durasi efek feedback, dalam detik scene.
  static const burstSeconds = 1.4;
  static const popSeconds = 0.9;
  static const flashSeconds = 0.9;

  /// Lama animasi berjalan pada mode Minimal saat aksi dicatat.
  static const minimalFeedbackSeconds = 1.6;

  /// Waktu scene untuk satu frame statis (terumbu tampil utuh).
  static const staticFrameSeconds = 12.0;

  static int bubblesFor(EffectQuality quality) => switch (quality) {
    EffectQuality.full => fullBubbleCount,
    EffectQuality.hemat => (fullBubbleCount * hematBubbleFraction).round(),
    EffectQuality.minimal => 0,
  };

  static bool causticsFor(EffectQuality quality) =>
      quality != EffectQuality.minimal;

  static bool raysFor(EffectQuality quality) => quality == EffectQuality.full;

  /// Shader hanya dipakai pada mode Penuh; Hemat selalu pakai fallback.
  static bool shaderFor(EffectQuality quality) => quality == EffectQuality.full;
}
