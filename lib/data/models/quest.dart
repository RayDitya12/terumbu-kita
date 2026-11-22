import 'json_utils.dart';

/// Misi harian/mingguan (spec.md §7.3).
/// CD2 + CD8: target harian memberi pencapaian sekaligus alasan kembali.
class Quest {
  const Quest({
    required this.id,
    required this.title,
    required this.targetCount,
    this.progress = 0,
    required this.date,
    this.completed = false,
    this.rewardXp = 0,
  });

  factory Quest.fromJson(Map<String, dynamic> json) => Quest(
    id: asString(json, 'id'),
    title: asString(json, 'title'),
    targetCount: asInt(json, 'targetCount', fallback: 1),
    progress: asInt(json, 'progress'),
    date: asDateOr(json, 'date', DateTime(2026)),
    completed: asBool(json, 'completed'),
    rewardXp: asInt(json, 'rewardXp'),
  );

  final String id;
  final String title;
  final int targetCount;
  final int progress;

  /// Tanggal kalender quest ini berlaku.
  final DateTime date;
  final bool completed;
  final int rewardXp;

  Quest copyWith({int? progress, bool? completed}) => Quest(
    id: id,
    title: title,
    targetCount: targetCount,
    progress: progress ?? this.progress,
    date: date,
    completed: completed ?? this.completed,
    rewardXp: rewardXp,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetCount': targetCount,
    'progress': progress,
    'date': date.toIso8601String(),
    'completed': completed,
    'rewardXp': rewardXp,
  };
}
