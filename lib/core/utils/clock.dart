/// Abstraksi waktu untuk seluruh logika game.
///
/// Aturan game DILARANG memakai `DateTime.now()` langsung (agent.md §2.4);
/// semua waktu dibaca lewat [Clock] agar Demo Mode bisa menggeser tanggal
/// lewat [offsetDays] (spec.md §8).
typedef TimeSource = DateTime Function();

class Clock {
  Clock({TimeSource? timeSource, this.offsetDays = 0})
    : _timeSource = timeSource ?? DateTime.now;

  final TimeSource _timeSource;

  /// Pergeseran hari untuk Demo Mode (spec.md §8).
  final int offsetDays;

  DateTime get now => _timeSource().add(Duration(days: offsetDays));

  /// Tanggal kalender saat ini tanpa komponen jam.
  DateTime get today => dateOnly(now);

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  /// Selisih hari kalender antara [earlier] dan [later] (>= 0 bila urut).
  static int daysBetween(DateTime earlier, DateTime later) =>
      dateOnly(later).difference(dateOnly(earlier)).inDays;

  Clock withOffset(int newOffsetDays) =>
      Clock(timeSource: _timeSource, offsetDays: newOffsetDays);
}
