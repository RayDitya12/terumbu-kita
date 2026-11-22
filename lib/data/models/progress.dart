import 'json_utils.dart';

/// Progres game pengguna (spec.md §7.3).
class Progress {
  const Progress({
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.longestStreak = 0,
    this.lastActionDate,
    this.freezes = 0,
    this.reefHealth = 100,
    this.totalActions = 0,
  });

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
    xp: asInt(json, 'xp'),
    level: asInt(json, 'level', fallback: 1),
    streak: asInt(json, 'streak'),
    longestStreak: asInt(json, 'longestStreak'),
    lastActionDate: asDate(json, 'lastActionDate'),
    freezes: asInt(json, 'freezes'),
    reefHealth: asInt(json, 'reefHealth', fallback: 100),
    totalActions: asInt(json, 'totalActions'),
  );

  final int xp;
  final int level;
  final int streak;
  final int longestStreak;

  /// Tanggal kalender aksi terakhir (tanpa komponen jam), null bila belum ada.
  final DateTime? lastActionDate;

  /// Jumlah streak freeze yang dimiliki, maks. 2 (spec.md §7.2).
  final int freezes;

  /// 0–100; turun saat karang memudar, pulih penuh dengan 1 aksi (CD8, tidak menghukum).
  final int reefHealth;
  final int totalActions;

  Progress copyWith({
    int? xp,
    int? level,
    int? streak,
    int? longestStreak,
    DateTime? lastActionDate,
    int? freezes,
    int? reefHealth,
    int? totalActions,
  }) => Progress(
    xp: xp ?? this.xp,
    level: level ?? this.level,
    streak: streak ?? this.streak,
    longestStreak: longestStreak ?? this.longestStreak,
    lastActionDate: lastActionDate ?? this.lastActionDate,
    freezes: freezes ?? this.freezes,
    reefHealth: reefHealth ?? this.reefHealth,
    totalActions: totalActions ?? this.totalActions,
  );

  Map<String, dynamic> toJson() => {
    'xp': xp,
    'level': level,
    'streak': streak,
    'longestStreak': longestStreak,
    'lastActionDate': lastActionDate?.toIso8601String(),
    'freezes': freezes,
    'reefHealth': reefHealth,
    'totalActions': totalActions,
  };
}
