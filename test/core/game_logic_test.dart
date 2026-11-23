import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/constants/game_rules.dart';
import 'package:terumbu_kita/core/utils/game_logic.dart';

void main() {
  group('reefStageFor (ambang baru spec.md §7.2 Unit A)', () {
    test('Tunas untuk 0-5 aksi', () {
      for (var i = 0; i < 6; i++) {
        expect(reefStageFor(i), ReefStage.tunas, reason: 'aksi=$i');
      }
    });

    test('Tumbuh untuk 6-17 aksi', () {
      expect(reefStageFor(6), ReefStage.tumbuh);
      expect(reefStageFor(17), ReefStage.tumbuh);
    });

    test('Subur untuk 18-39 aksi', () {
      expect(reefStageFor(18), ReefStage.subur);
      expect(reefStageFor(39), ReefStage.subur);
    });

    test('Ekosistem mulai 40 aksi', () {
      expect(reefStageFor(40), ReefStage.ekosistem);
      expect(reefStageFor(1000), ReefStage.ekosistem);
    });
  });

  group('actionsUntilNextReefStage', () {
    test('menghitung sisa aksi menuju tahap berikutnya', () {
      expect(actionsUntilNextReefStage(0), 6);
      expect(actionsUntilNextReefStage(7), 11);
      expect(actionsUntilNextReefStage(25), 15);
      expect(actionsUntilNextReefStage(39), 1);
    });

    test('null saat sudah tahap maksimum', () {
      expect(actionsUntilNextReefStage(40), isNull);
      expect(actionsUntilNextReefStage(120), isNull);
    });
  });
}
