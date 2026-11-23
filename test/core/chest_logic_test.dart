import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/utils/chest.dart';
import 'package:terumbu_kita/core/utils/game_logic.dart';
import 'package:terumbu_kita/data/models/progress.dart';

void main() {
  group('applyXp (level-up berantai, spec.md §7.2)', () {
    test('XP di bawah ambang tidak menaikkan level', () {
      final outcome = applyXp(const Progress(xp: 10, level: 1), 20);
      expect(outcome.progress.xp, 30);
      expect(outcome.progress.level, 1);
      expect(outcome.leveledUp, isFalse);
    });

    test('XP 100 dari level 1: 50 + 75 → level 3 sisa 0', () {
      final outcome = applyXp(const Progress(xp: 0, level: 1), 125);
      expect(outcome.progress.level, 3);
      expect(outcome.progress.xp, 0);
      expect(outcome.leveledUp, isTrue);
    });
  });

  group('dailyQuestFor (spec.md §6.1 layar 5)', () {
    test('id deterministik per tanggal kalender', () {
      final a = dailyQuestFor(DateTime(2026, 11, 23, 9));
      final b = dailyQuestFor(DateTime(2026, 11, 23, 21));
      expect(a.id, b.id);
      expect(a.targetCount, 3);
      expect(a.rewardXp, 15);
    });
  });

  group('chest (spec.md §7.2, CD7)', () {
    test('hanya tersedia setelah quest selesai dan belum dibuka hari ini', () {
      final today = DateTime(2026, 11, 23);
      expect(
        chestAvailable(
          dailyQuestCompleted: false,
          lastChestDate: null,
          today: today,
        ),
        isFalse,
      );
      expect(
        chestAvailable(
          dailyQuestCompleted: true,
          lastChestDate: null,
          today: today,
        ),
        isTrue,
      );
      expect(
        chestAvailable(
          dailyQuestCompleted: true,
          lastChestDate: today,
          today: today,
        ),
        isFalse,
      );
      expect(
        chestAvailable(
          dailyQuestCompleted: true,
          lastChestDate: today.subtract(const Duration(days: 1)),
          today: today,
        ),
        isTrue,
      );
    });

    test('undian dengan seed menghasilkan distribusi berbobot', () {
      final rng = math.Random(42);
      final counts = <ChestRewardType, int>{};
      for (var i = 0; i < 1000; i++) {
        final reward = pickChestReward(rng);
        counts[reward.type] = (counts[reward.type] ?? 0) + 1;
      }
      expect(counts[ChestRewardType.xp], greaterThan(400));
      expect(counts[ChestRewardType.freeze], greaterThan(120));
      expect(counts[ChestRewardType.decoration], greaterThan(80));
      expect(counts[ChestRewardType.fact], greaterThan(80));
    });

    test('freeze tidak melebihi maks 2', () {
      expect(
        freezesAfterOpen(2, const ChestReward(ChestRewardType.freeze, 1)),
        2,
      );
      expect(
        freezesAfterOpen(0, const ChestReward(ChestRewardType.freeze, 1)),
        1,
      );
      expect(freezesAfterOpen(1, const ChestReward(ChestRewardType.xp, 10)), 1);
    });
  });
}
