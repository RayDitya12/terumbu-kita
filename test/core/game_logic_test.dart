import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/constants/game_rules.dart';
import 'package:terumbu_kita/core/utils/game_logic.dart';

void main() {
  group('reefStageFor (ambang spec.md §7.2)', () {
    test('Tunas untuk 0-9 aksi', () {
      for (var i = 0; i < 10; i++) {
        expect(reefStageFor(i), ReefStage.tunas, reason: 'aksi=$i');
      }
    });

    test('Tumbuh untuk 10-29 aksi', () {
      expect(reefStageFor(10), ReefStage.tumbuh);
      expect(reefStageFor(29), ReefStage.tumbuh);
    });

    test('Subur untuk 30-69 aksi', () {
      expect(reefStageFor(30), ReefStage.subur);
      expect(reefStageFor(69), ReefStage.subur);
    });

    test('Ekosistem mulai 70 aksi', () {
      expect(reefStageFor(70), ReefStage.ekosistem);
      expect(reefStageFor(1000), ReefStage.ekosistem);
    });
  });

  group('actionsUntilNextReefStage', () {
    test('menghitung sisa aksi menuju tahap berikutnya', () {
      expect(actionsUntilNextReefStage(0), 10);
      expect(actionsUntilNextReefStage(7), 3);
      expect(actionsUntilNextReefStage(25), 5);
      expect(actionsUntilNextReefStage(60), 10);
    });

    test('null saat sudah tahap maksimum', () {
      expect(actionsUntilNextReefStage(70), isNull);
      expect(actionsUntilNextReefStage(120), isNull);
    });
  });
}
