import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/constants/game_rules.dart';
import 'package:terumbu_kita/data/models/action_log.dart';
import 'package:terumbu_kita/data/models/app_settings.dart';
import 'package:terumbu_kita/data/models/collection.dart';
import 'package:terumbu_kita/data/models/progress.dart';
import 'package:terumbu_kita/data/models/quest.dart';
import 'package:terumbu_kita/data/models/user_profile.dart';

void main() {
  final epoch = DateTime(2026, 11, 23);
  test('UserProfile round-trip json', () {
    final profile = UserProfile(
      nickname: 'Rani',
      avatarId: 2,
      focusHabit: ActionType.tumbler,
      onboardingDone: true,
      createdAt: DateTime(2026, 11, 1),
    );
    final restored = UserProfile.fromJson(profile.toJson());
    expect(restored.nickname, 'Rani');
    expect(restored.avatarId, 2);
    expect(restored.focusHabit, ActionType.tumbler);
    expect(restored.onboardingDone, isTrue);
    expect(restored.createdAt, DateTime(2026, 11, 1));
  });

  test('UserProfile.fromJson toleran data korup', () {
    final restored = UserProfile.fromJson({'nickname': 42, 'avatarId': 'x'});
    expect(restored.nickname, '');
    expect(restored.avatarId, 0);
    expect(restored.focusHabit, isNull);
    expect(restored.onboardingDone, isFalse);
  });

  test('Progress round-trip json', () {
    final progress = Progress(
      xp: 120,
      level: 2,
      streak: 4,
      longestStreak: 6,
      lastActionDate: DateTime(2026, 11, 20),
      freezes: 1,
      reefHealth: 75,
      totalActions: 12,
    );
    final restored = Progress.fromJson(progress.toJson());
    expect(restored.xp, 120);
    expect(restored.level, 2);
    expect(restored.streak, 4);
    expect(restored.longestStreak, 6);
    expect(restored.lastActionDate, DateTime(2026, 11, 20));
    expect(restored.freezes, 1);
    expect(restored.reefHealth, 75);
    expect(restored.totalActions, 12);
  });

  test('Progress default saat json kosong', () {
    const restored = Progress();
    expect(restored.reefHealth, 100);
    expect(restored.level, 1);
    expect(Progress.fromJson({}).lastActionDate, isNull);
  });

  test('ActionLog round-trip json', () {
    final log = ActionLog(
      id: 'a1',
      actionType: 'no_straw',
      timestamp: DateTime(2026, 11, 23, 8),
      xpGained: 5,
      plasticGrams: 1,
      note: 'di kantin',
    );
    final restored = ActionLog.fromJson(log.toJson());
    expect(restored.id, 'a1');
    expect(restored.actionType, 'no_straw');
    expect(restored.timestamp, DateTime(2026, 11, 23, 8));
    expect(restored.xpGained, 5);
    expect(restored.plasticGrams, 1);
    expect(restored.note, 'di kantin');
  });

  test('ActionLog tanpa note tidak menulis kunci note', () {
    final log = ActionLog(
      id: 'a2',
      actionType: 'tote',
      timestamp: epoch,
      xpGained: 10,
      plasticGrams: 8,
    );
    expect(log.toJson().containsKey('note'), isFalse);
  });

  test('Quest round-trip json', () {
    final quest = Quest(
      id: 'q1',
      title: 'Catat 3 aksi hari ini',
      targetCount: 3,
      progress: 2,
      date: DateTime(2026, 11, 23),
      completed: false,
      rewardXp: 20,
    );
    final restored = Quest.fromJson(quest.toJson());
    expect(restored.title, 'Catat 3 aksi hari ini');
    expect(restored.targetCount, 3);
    expect(restored.progress, 2);
    expect(restored.date, DateTime(2026, 11, 23));
    expect(restored.completed, isFalse);
    expect(restored.rewardXp, 20);
  });

  test('Collection round-trip dan saring elemen non-string', () {
    const collection = Collection(
      speciesUnlocked: ['porites'],
      decorationsOwned: ['kerang'],
      badges: ['penyelam-baru'],
    );
    final restored = Collection.fromJson(collection.toJson());
    expect(restored.speciesUnlocked, ['porites']);
    expect(restored.decorationsOwned, ['kerang']);
    expect(restored.badges, ['penyelam-baru']);

    final messy = Collection.fromJson({
      'speciesUnlocked': ['porites', 7, null],
      'badges': 'bukan-list',
    });
    expect(messy.speciesUnlocked, ['porites']);
    expect(messy.badges, isEmpty);
  });

  test('AppSettings round-trip json', () {
    const settings = AppSettings(
      demoMode: true,
      simulatedDateOffsetDays: 7,
      notificationsEnabled: false,
    );
    final restored = AppSettings.fromJson(settings.toJson());
    expect(restored.demoMode, isTrue);
    expect(restored.simulatedDateOffsetDays, 7);
    expect(restored.notificationsEnabled, isFalse);
  });
}
