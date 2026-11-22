import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('gram bulat tampil tanpa desimal', () {
      expect(Formatters.grams(8), '8 g');
    });

    test('gram desimal tampil dengan koma', () {
      expect(Formatters.grams(1.5), '1,5 g');
    });

    test('di atas 1000 g beralih ke kg', () {
      expect(Formatters.grams(1200), '1,2 kg');
      expect(Formatters.grams(2000), '2 kg');
    });

    test('shortDate memakai nama hari dan bulan Indonesia', () {
      expect(Formatters.shortDate(DateTime(2026, 11, 23)), 'Sen, 23 Nov');
      expect(Formatters.shortDate(DateTime(2026, 11, 22)), 'Min, 22 Nov');
    });

    test('strawEquivalent format padanan', () {
      expect(Formatters.strawEquivalent(12), '≈ 12 sedotan');
    });
  });
}
