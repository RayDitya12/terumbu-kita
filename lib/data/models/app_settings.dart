import 'json_utils.dart';

/// Pengaturan aplikasi, termasuk Demo Mode (spec.md §7.3, §8).
class AppSettings {
  const AppSettings({
    this.demoMode = false,
    this.simulatedDateOffsetDays = 0,
    this.notificationsEnabled = true,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    demoMode: asBool(json, 'demoMode'),
    simulatedDateOffsetDays: asInt(json, 'simulatedDateOffsetDays'),
    notificationsEnabled: asBool(json, 'notificationsEnabled', fallback: true),
  );

  final bool demoMode;

  /// Pergeseran hari untuk Demo Mode; dibaca ulang oleh Clock provider.
  final int simulatedDateOffsetDays;
  final bool notificationsEnabled;

  AppSettings copyWith({
    bool? demoMode,
    int? simulatedDateOffsetDays,
    bool? notificationsEnabled,
  }) => AppSettings(
    demoMode: demoMode ?? this.demoMode,
    simulatedDateOffsetDays:
        simulatedDateOffsetDays ?? this.simulatedDateOffsetDays,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
  );

  Map<String, dynamic> toJson() => {
    'demoMode': demoMode,
    'simulatedDateOffsetDays': simulatedDateOffsetDays,
    'notificationsEnabled': notificationsEnabled,
  };
}
