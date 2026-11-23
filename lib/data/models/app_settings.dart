import 'json_utils.dart';

/// Pengaturan aplikasi, termasuk Demo Mode (spec.md §7.3, §8).
class AppSettings {
  const AppSettings({
    this.demoMode = false,
    this.simulatedDateOffsetDays = 0,
    this.notificationsEnabled = true,
    this.lastChestDate,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    demoMode: asBool(json, 'demoMode'),
    simulatedDateOffsetDays: asInt(json, 'simulatedDateOffsetDays'),
    notificationsEnabled: asBool(json, 'notificationsEnabled', fallback: true),
    lastChestDate: asDate(json, 'lastChestDate'),
  );

  final bool demoMode;

  /// Pergeseran hari untuk Demo Mode; dibaca ulang oleh Clock provider.
  final int simulatedDateOffsetDays;
  final bool notificationsEnabled;

  /// Hari terakhir Mystery Chest dibuka (spec.md §7.2: 1x/hari).
  final DateTime? lastChestDate;

  AppSettings copyWith({
    bool? demoMode,
    int? simulatedDateOffsetDays,
    bool? notificationsEnabled,
    DateTime? lastChestDate,
  }) => AppSettings(
    demoMode: demoMode ?? this.demoMode,
    simulatedDateOffsetDays:
        simulatedDateOffsetDays ?? this.simulatedDateOffsetDays,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    lastChestDate: lastChestDate ?? this.lastChestDate,
  );

  Map<String, dynamic> toJson() => {
    'demoMode': demoMode,
    'simulatedDateOffsetDays': simulatedDateOffsetDays,
    'notificationsEnabled': notificationsEnabled,
    'lastChestDate': lastChestDate?.toIso8601String(),
  };
}
