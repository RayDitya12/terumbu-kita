import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/constants/game_rules.dart';
import 'package:terumbu_kita/core/utils/game_logic.dart';
import 'package:terumbu_kita/data/models/action_log.dart';
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

  group('ambang tahap terumbu Unit A (spec.md §7.2)', () {
    test('Tunas 0-5, Tumbuh 6-17, Subur 18-39, Ekosistem 40+', () {
      expect(reefStageFor(0), ReefStage.tunas);
      expect(reefStageFor(5), ReefStage.tunas);
      expect(reefStageFor(6), ReefStage.tumbuh);
      expect(reefStageFor(17), ReefStage.tumbuh);
      expect(reefStageFor(18), ReefStage.subur);
      expect(reefStageFor(39), ReefStage.subur);
      expect(reefStageFor(40), ReefStage.ekosistem);
    });
  });

  group('applyAction (spec.md §7.1-7.2, aturan 1×/jenis/hari)', () {
    test('aksi pertama: XP, streak 1, badge flag, total bertambah', () {
      final outcome = applyAction(
        progress: const Progress(),
        type: ActionType.tumbler,
        today: day(0),
        typesCompletedToday: 1,
      );
      expect(outcome.xpGained, 10);
      expect(outcome.perfectDay, isFalse);
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
        typesCompletedToday: 2,
      );
      expect(outcome.progress.streak, 1);
      expect(outcome.progress.totalActions, 2);
    });

    test('Hari Sempurna: jenis ke-6 memberi bonus +10 XP', () {
      final progress = Progress(
        streak: 1,
        lastActionDate: day(0),
        totalActions: 5,
      );
      final outcome = applyAction(
        progress: progress,
        type: ActionType.noCutlery, // 5 XP.
        today: day(0),
        typesCompletedToday: 6,
      );
      expect(outcome.perfectDay, isTrue);
      expect(outcome.xpGained, 5 + GameRules.perfectDayBonusXp);
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
        typesCompletedToday: 1,
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
        typesCompletedToday: 1,
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
        typesCompletedToday: 1,
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
        typesCompletedToday: 1,
      );
      expect(outcome.progress.streak, 1);
      expect(outcome.progress.freezes, 2);
    });

    test('level up berantai: XP 60 dari level 1 menjadi level 2 XP 9', () {
      final progress = const Progress(xp: 50, level: 1);
      final outcome = applyAction(
        progress: progress,
        type: ActionType.ownContainer, // 15 XP; 50+15=65, butuh 50.
        today: day(0),
        typesCompletedToday: 1,
      );
      expect(outcome.leveledUp, isTrue);
      expect(outcome.progress.level, 2);
      expect(outcome.progress.xp, 15); // 65 - 50 = 15 menuju level 3.
    });

    test('total aksi 6 menaikkan tahap terumbu ke Tumbuh', () {
      final progress = Progress(
        streak: 5,
        lastActionDate: day(0),
        totalActions: 5,
        reefHealth: 75,
      );
      final outcome = applyAction(
        progress: progress,
        type: ActionType.tumbler,
        today: day(0),
        typesCompletedToday: 2,
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
        typesCompletedToday: 1,
      );
      expect(outcome.progress.streak, 1);
      expect(outcome.progress.reefHealth, 100);
    });
  });

  ActionLog log(String type, DateTime at) => ActionLog(
    id: 'log-$type-${at.millisecondsSinceEpoch}',
    actionType: type,
    timestamp: at,
    xpGained: 10,
    plasticGrams: 10,
  );

  group('loggedTypeIdsOnDay (1×/jenis/hari, spec.md §7.2 Unit A)', () {
    test('hanya menghitung log pada hari kalender yang sama', () {
      final logs = [
        log('tumbler', day(0).add(const Duration(hours: 8))),
        log('tote', day(0).add(const Duration(hours: 20))),
        log('tumbler', day(1).add(const Duration(hours: 7))),
      ];
      expect(loggedTypeIdsOnDay(logs, day(0)), {'tumbler', 'tote'});
      expect(loggedTypeIdsOnDay(logs, day(1)), {'tumbler'});
      expect(loggedTypeIdsOnDay(logs, day(2)), isEmpty);
    });
  });

  group('newTypeCountToday (quest variasi, spec.md §7.2 Unit A)', () {
    test('jenis yang baru pertama muncul dalam 3 hari terakhir dihitung', () {
      final logs = [
        log('tumbler', day(0)),
        log('no_straw', day(2)),
        // Hari ke-3: tumbler pernah di window (hari 0..2), refill belum.
        log('tumbler', day(3)),
        log('refill', day(3)),
        log('tote', day(3)),
      ];
      expect(newTypeCountToday(logs, day(3)), 2);
    });

    test('log hari 4 lalu tidak menghalangi (jendela 3 hari)', () {
      final logs = [log('refill', day(0)), log('refill', day(4))];
      expect(newTypeCountToday(logs, day(4)), 1);
    });

    test('hari tanpa log: nol', () {
      expect(newTypeCountToday([log('tumbler', day(0))], day(1)), 0);
    });
  });
}
