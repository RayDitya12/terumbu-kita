import 'json_utils.dart';

/// Kualitas efek visual terumbu: Penuh = shader caustics + gelembung penuh
/// berparallax + light rays; Hemat = fallback pita cahaya, separuh gelembung,
/// tanpa light rays; Minimal = terumbu statis, animasi hanya feedback aksi.
enum EffectQuality {
  full,
  hemat,
  minimal;

  static EffectQuality fromName(String name) => EffectQuality.values.firstWhere(
    (q) => q.name == name,
    orElse: () => EffectQuality.full,
  );
}

/// Pengaturan aplikasi, termasuk Demo Mode (spec.md §7.3, §8).
class AppSettings {
  const AppSettings({
    this.demoMode = false,
    this.simulatedDateOffsetDays = 0,
    this.notificationsEnabled = true,
    this.effectQuality = EffectQuality.full,
    this.lastChestDate,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    demoMode: asBool(json, 'demoMode'),
    simulatedDateOffsetDays: asInt(json, 'simulatedDateOffsetDays'),
    notificationsEnabled: asBool(json, 'notificationsEnabled', fallback: true),
    effectQuality: EffectQuality.fromName(asString(json, 'effectQuality')),
    lastChestDate: asDate(json, 'lastChestDate'),
  );

  final bool demoMode;

  /// Pergeseran hari untuk Demo Mode; dibaca ulang oleh Clock provider.
  final int simulatedDateOffsetDays;
  final bool notificationsEnabled;
  final EffectQuality effectQuality;

  /// Hari terakhir Mystery Chest dibuka (spec.md §7.2: 1x/hari).
  final DateTime? lastChestDate;

  AppSettings copyWith({
    bool? demoMode,
    int? simulatedDateOffsetDays,
    bool? notificationsEnabled,
    EffectQuality? effectQuality,
    DateTime? lastChestDate,
  }) => AppSettings(
    demoMode: demoMode ?? this.demoMode,
    simulatedDateOffsetDays:
        simulatedDateOffsetDays ?? this.simulatedDateOffsetDays,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    effectQuality: effectQuality ?? this.effectQuality,
    lastChestDate: lastChestDate ?? this.lastChestDate,
  );

  Map<String, dynamic> toJson() => {
    'demoMode': demoMode,
    'simulatedDateOffsetDays': simulatedDateOffsetDays,
    'notificationsEnabled': notificationsEnabled,
    'effectQuality': effectQuality.name,
    'lastChestDate': lastChestDate?.toIso8601String(),
  };
}
