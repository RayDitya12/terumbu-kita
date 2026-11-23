import 'json_utils.dart';

/// Catatan satu aksi bebas plastik (spec.md §7.3).
class ActionLog {
  const ActionLog({
    required this.id,
    required this.actionType,
    required this.timestamp,
    required this.xpGained,
    required this.plasticGrams,
    this.note,
  });

  factory ActionLog.fromJson(Map<String, dynamic> json) => ActionLog(
    id: asString(json, 'id'),
    actionType: asString(json, 'actionType'),
    timestamp: asDateOr(json, 'timestamp', DateTime(2026)),
    xpGained: asInt(json, 'xpGained'),
    plasticGrams: asDouble(json, 'plasticGrams'),
    note: json['note'] is String ? json['note'] as String : null,
  );

  final String id;

  /// [ActionType.id] dari aksi yang dicatat.
  final String actionType;
  final DateTime timestamp;

  /// XP yang benar-benar diberikan aksi ini (termasuk bonus Hari Sempurna).
  final int xpGained;
  final double plasticGrams;
  final String? note;

  ActionLog copyWith({int? xpGained, String? note}) => ActionLog(
    id: id,
    actionType: actionType,
    timestamp: timestamp,
    xpGained: xpGained ?? this.xpGained,
    plasticGrams: plasticGrams,
    note: note ?? this.note,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'actionType': actionType,
    'timestamp': timestamp.toIso8601String(),
    'xpGained': xpGained,
    'plasticGrams': plasticGrams,
    if (note != null) 'note': note,
  };
}
