import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/constants/game_rules.dart';
import 'package:terumbu_kita/core/utils/game_logic.dart';
import 'package:terumbu_kita/data/models/progress.dart';

void main() {
  final day0 = DateTime(2026, 11, 1);
  DateTime day(int offset) => day0.add(Duration(days: offset));

  group('reefHealthOn (karang memudar, spec.md §7.2)', () {
    test('belum pernah aksi: kesehatan penuh', () {
      expect(
        reefHealthOn(lastActionDate: null, today: day(30)),
        GameRules.maxReefHealth,
      );
    });

    test('0-3 hari tanpa aksi: masih penuh', () {
      for (var idle = 0; idle <= 3; idle++) {
        expect(reefHealthOn(lastActionDate: day(0), today: day(idle)), 100);
      }
    });

    test('mulai hari ke-4 turun 25 per hari, min 0', () {
      expect(reefHealthOn(lastActionDate: day(0), today: day(4)), 75);
      expect(reefHealthOn(lastActionDate: day(0), today: day(5)), 50);
      expect(reefHealthOn(lastActionDate: day(0), today: day(7)), 0);
      expect(reefHealthOn(lastActionDate: day(0), today: day(40)), 0);
    });
  });

  group('applyAction (spec.md §7.1-7.2)', () {
    test('aksi pertama: XP, streak 1, badge flag, total bertambah', () {
      final outcome = applyAction(
        progress: const Progress(),
        type: ActionType.tumbler,
        today: day(0),
        actionsToday: 0,
      );
      expect(outcome.xpGained, 10);
      expect(outcome.grams, 30); // 1 gelas, ASUMSI di impact_constants.
      expect(outcome.firstAction, isTrue);
      expect(outcome.progress.xp, 10);
      expect(outcome.progress.streak, 1);
      expect(outcome.progress.totalActions, 1);
      expect(outcome.progress.reefHealth, 100);
    });

    test('aksi kedua hari sama: streak tidak bertambah', () {
      final progress = Progress(
        xp: 10,
        streak: 1,
        lastActionDate: day(0),
        totalActions: 1,
      );
      final outcome = applyAction(
        progress: progress,
        type: ActionType.tote,
        today: day(0),
        actionsToday: 1,
      );
      expect(outcome.progress.streak, 1);
      expect(outcome.progress.totalActions, 2);
    });

    test('aksi hari berikutnya: streak +1 dan milestone 3 dilaporkan', () {
      final progress = Progress(
        streak: 2,
        lastActionDate: day(1),
        totalActions: 2,
      );
      final outcome = applyAction(
        progress: progress,
        type: ActionType.noStraw,
        today: day(2),
        actionsToday: 0,
      );
      expect(outcome.progress.streak, 3);
      expect(outcome.streakMilestone, 3);
      expect(outcome.freezeUsed, isFalse);
    });

    test('satu hari terlewat + freeze: streak diselamatkan', () {
      final progress = Progress(
        streak: 5,
        lastActionDate: day(0),
        freezes: 1,
        totalActions: 5,
      );
      final outcome = applyAction(
        progress: progress,
        type: ActionType.tumbler,
        today: day(2),
        actionsToday: 0,
      );
      expect(outcome.freezeUsed, isTrue);
      expect(outcome.progress.streak, 6);
      expect(outcome.progress.freezes, 0);
    });

    test('satu hari terlewat tanpa freeze: streak putus ke 1', () {
      final progress = Progress(
        streak: 9,
        longestStreak: 9,
        lastActionDate: day(0),
        totalActions: 9,
      );
      final outcome = applyAction(
        progress: progress,
        type: ActionType.tumbler,
        today: day(2),
        actionsToday: 0,
      );
      expect(outcome.progress.streak, 1);
      expect(outcome.progress.longestStreak, 9);
    });

    test('dua hari terlewat: freeze tidak menolong', () {
      final progress = Progress(
        streak: 4,
        lastActionDate: day(0),
        freezes: 2,
        totalActions: 4,
      );
      final outcome = applyAction(
        progress: progress,
        type: ActionType.tumbler,
        today: day(3),
        actionsToday: 0,
      );
      expect(outcome.progress.streak, 1);
      expect(outcome.progress.freezes, 2);
    });

    test('batas 10 XP harian: aksi ke-11 dicatat tanpa XP', () {
      final outcome = applyAction(
        progress: const Progress(),
        type: ActionType.tumbler,
        today: day(0),
        actionsToday: GameRules.dailyXpActionCap,
      );
      expect(outcome.xpGained, 0);
      expect(outcome.progress.totalActions, 1);
    });

    test('level up berantai: XP 60 dari level 1 menjadi level 2 XP 9', () {
      final progress = const Progress(xp: 50, level: 1);
      final outcome = applyAction(
        progress: progress,
        type: ActionType.ownContainer, // 15 XP; 50+15=65, butuh 50.
        today: day(0),
        actionsToday: 0,
      );
      expect(outcome.leveledUp, isTrue);
      expect(outcome.progress.level, 2);
      expect(outcome.progress.xp, 15); // 65 - 50 = 15 menuju level 3.
    });

    test('aksi ke-10 menaikkan tahap terumbu ke Tumbuh', () {
      final progress = Progress(
        streak: 5,
        lastActionDate: day(0),
        totalActions: 9,
        reefHealth: 75,
      );
      final outcome = applyAction(
        progress: progress,
        type: ActionType.tumbler,
        today: day(0),
        actionsToday: 5,
      );
      expect(outcome.stageUp, ReefStage.tumbuh);
      // CD8: satu aksi memulihkan karang penuh.
      expect(outcome.progress.reefHealth, 100);
    });

    test('streak lama tetap 1 tanpa aksi 4 hari lalu pulih', () {
      final progress = Progress(
        streak: 1,
        lastActionDate: day(0),
        totalActions: 1,
      );
      final outcome = applyAction(
        progress: progress,
        type: ActionType.refill,
        today: day(4),
        actionsToday: 0,
      );
      expect(outcome.progress.streak, 1);
      expect(outcome.progress.reefHealth, 100);
    });
  });
}
