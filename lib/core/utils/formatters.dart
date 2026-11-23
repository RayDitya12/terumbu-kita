/// Format angka untuk tampilan (Bahasa Indonesia: koma desimal).
library;

abstract final class Formatters {
  /// "8 g" / "1,2 kg" — otomatis ganti satuan di atas 1000 g.
  static String grams(double grams) {
    if (grams >= 1000) {
      final kg = grams / 1000;
      final text = kg == kg.roundToDouble()
          ? kg.toStringAsFixed(0)
          : kg.toStringAsFixed(1);
      return '${_idDecimal(text)} kg';
    }
    final rounded = grams.roundToDouble();
    final text = rounded == grams
        ? rounded.toStringAsFixed(0)
        : grams.toStringAsFixed(1);
    return '${_idDecimal(text)} g';
  }

  /// Koma desimal gaya Indonesia.
  static String _idDecimal(String value) => value.replaceAll('.', ',');

  /// "≈ 12 sedotan" (spec.md §3.4).
  static String strawEquivalent(int straws) => '≈ $straws sedotan';

  /// "Tumbuh 3 aksi lagi untuk memperbesar terumbu." — CD2 dengan bahasa
  /// ajakan (agent.md §3: pesan kehilangan/motivasi tidak menghukum).
  static String nextReefStageHint(int actionsLeft) =>
      'Tumbuh $actionsLeft aksi lagi untuk memperbesar terumbu.';

  /// Tanggal singkat, mis. "Sen, 23 Nov".
  static String shortDate(DateTime date) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}
