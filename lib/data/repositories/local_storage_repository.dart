import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/action_log.dart';
import '../models/app_settings.dart';
import '../models/collection.dart';
import '../models/progress.dart';
import '../models/quest.dart';
import '../models/user_profile.dart';

/// Satu-satunya lapisan yang menyentuh penyimpanan lokal (agent.md §4).
///
/// Semua pembacaan tahan data kosong/korup: mengembalikan default,
/// tidak pernah melempar (spec.md §9 non-fungsional).
class LocalStorageRepository {
  LocalStorageRepository(this._prefs);

  static const _kProfile = 'terumbu.profile';
  static const _kProgress = 'terumbu.progress';
  static const _kActionLogs = 'terumbu.actionLogs';
  static const _kQuests = 'terumbu.quests';
  static const _kCollection = 'terumbu.collection';
  static const _kSettings = 'terumbu.settings';
  static const _kActionSnapshot = 'terumbu.lastActionSnapshot';

  final SharedPreferences _prefs;

  static Future<LocalStorageRepository> create() async =>
      LocalStorageRepository(await SharedPreferences.getInstance());

  Future<UserProfile?> loadProfile() async =>
      _decodeObject(_kProfile, UserProfile.fromJson);

  Future<void> saveProfile(UserProfile value) =>
      _encodeObject(_kProfile, value.toJson());

  Future<void> removeProfile() => _prefs.remove(_kProfile);

  Future<Progress> loadProgress() async =>
      _decodeObject(_kProgress, Progress.fromJson) ?? const Progress();

  Future<void> saveProgress(Progress value) =>
      _encodeObject(_kProgress, value.toJson());

  Future<List<ActionLog>> loadActionLogs() async =>
      _decodeList(_kActionLogs, ActionLog.fromJson);

  Future<void> saveActionLogs(List<ActionLog> values) =>
      _encodeList(_kActionLogs, [for (final v in values) v.toJson()]);

  Future<List<Quest>> loadQuests() async =>
      _decodeList(_kQuests, Quest.fromJson);

  Future<void> saveQuests(List<Quest> values) =>
      _encodeList(_kQuests, [for (final v in values) v.toJson()]);

  Future<Collection> loadCollection() async =>
      _decodeObject(_kCollection, Collection.fromJson) ?? const Collection();

  Future<void> saveCollection(Collection value) =>
      _encodeObject(_kCollection, value.toJson());

  Future<AppSettings> loadSettings() async =>
      _decodeObject(_kSettings, AppSettings.fromJson) ?? const AppSettings();

  Future<void> saveSettings(AppSettings value) =>
      _encodeObject(_kSettings, value.toJson());

  /// Snapshot sebelum aksi terakhir (logId + Progress + badge yang diberi-
  /// kan) — dipakai tombol "Batalkan" hari yang sama (spec.md §7.2 Unit A).
  Future<Map<String, dynamic>?> loadActionSnapshot() async =>
      _readMap(_kActionSnapshot);

  Future<void> saveActionSnapshot(Map<String, dynamic> value) =>
      _encodeObject(_kActionSnapshot, value);

  Future<void> clearActionSnapshot() => _prefs.remove(_kActionSnapshot);

  /// Reset total: dipakai Demo Mode (spec.md §8).
  Future<void> clearAll() async {
    for (final key in [
      _kProfile,
      _kProgress,
      _kActionLogs,
      _kQuests,
      _kCollection,
      _kSettings,
      _kActionSnapshot,
    ]) {
      await _prefs.remove(key);
    }
  }

  Map<String, dynamic>? _readMap(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  T? _decodeObject<T>(String key, T Function(Map<String, dynamic>) parse) {
    final map = _readMap(key);
    if (map == null) return null;
    try {
      return parse(map);
    } on Object {
      return null;
    }
  }

  List<T> _decodeList<T>(String key, T Function(Map<String, dynamic>) parse) {
    final raw = _prefs.getString(key);
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(parse)
          .toList(growable: false);
    } on FormatException {
      return const [];
    }
  }

  Future<void> _encodeObject(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  Future<void> _encodeList(String key, List<Map<String, dynamic>> value) =>
      _prefs.setString(key, jsonEncode(value));
}
