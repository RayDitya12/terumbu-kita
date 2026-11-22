import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/utils/clock.dart';

void main() {
  Clock clockAt(String iso, {int offsetDays = 0}) =>
      Clock(timeSource: () => DateTime.parse(iso), offsetDays: offsetDays);

  group('Clock', () {
    test('now memakai timeSource tanpa offset', () {
      final clock = clockAt('2026-11-23T09:30:00');
      expect(clock.now, DateTime(2026, 11, 23, 9, 30));
    });

    test('offsetDays menggeser waktu untuk Demo Mode', () {
      final clock = clockAt('2026-11-23T09:30:00', offsetDays: 7);
      expect(clock.now, DateTime(2026, 11, 30, 9, 30));
    });

    test('today membuang komponen jam', () {
      final clock = clockAt('2026-11-23T23:59:59');
      expect(clock.today, DateTime(2026, 11, 23));
    });

    test('daysBetween menghitung selisih hari kalender', () {
      final a = DateTime(2026, 11, 20, 23, 59);
      final b = DateTime(2026, 11, 21, 0, 1);
      expect(Clock.daysBetween(a, b), 1);
      expect(Clock.daysBetween(b, a), -1);
    });

    test('withOffset mengembalikan Clock baru dengan sumber waktu sama', () {
      final base = clockAt('2026-11-23T09:30:00');
      final shifted = base.withOffset(1);
      expect(shifted.now, DateTime(2026, 11, 24, 9, 30));
      expect(base.now, DateTime(2026, 11, 23, 9, 30));
    });
  });
}
