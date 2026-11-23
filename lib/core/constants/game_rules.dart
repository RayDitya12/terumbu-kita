/// Semua angka aturan game terpusat di sini (agent.md §2.6, spec.md §7).
/// Jangan menulis magic number di luar file ini.
library;

/// Jenis aksi bebas plastik (spec.md §7.1).
///
/// CD2: tiap aksi memberi XP langsung (Development & Accomplishment).
enum ActionType {
  tumbler(id: 'tumbler', xp: 10),
  tote(id: 'tote', xp: 10),
  noStraw(id: 'no_straw', xp: 5),
  ownContainer(id: 'own_container', xp: 15),
  refill(id: 'refill', xp: 10),
  noCutlery(id: 'no_cutlery', xp: 5);

  const ActionType({required this.id, required this.xp});

  final String id;
  final int xp;

  static ActionType? fromId(String id) {
    for (final type in values) {
      if (type.id == id) return type;
    }
    return null;
  }
}

/// Tahap pertumbuhan terumbu, dihitung dari total aksi (spec.md §7.2).
/// Ambang diturunkan untuk ritme "1 aksi/jenis/hari" (Unit A): ekosistem
/// masih tercapai ±7 hari dan bisa didemokan dalam 2 minggu.
///
/// CD4 + CD2: progress visual milik pengguna sendiri (Ownership).
enum ReefStage {
  tunas(minActions: 0),
  tumbuh(minActions: 6),
  subur(minActions: 18),
  ekosistem(minActions: 40);

  const ReefStage({required this.minActions});

  final int minActions;
}

abstract final class GameRules {
  // --- Level (spec.md §7.2) ---
  /// XP yang dibutuhkan untuk naik dari [level] ke level berikutnya:
  /// `50 + 25 * (level - 1)`.
  static int xpNeededForLevel(int level) => 50 + 25 * (level - 1);

  // --- Streak (spec.md §7.2) ---
  /// Streak putus jika 1 hari terlewat tanpa aksi, kecuali ada freeze.
  static const int missedDaysBeforeStreakBreaks = 1;
  static const int maxFreezes = 2;

  // --- Karang memudar (spec.md §7.2, angka laju disetujui pengguna) ---
  /// Setelah [idleDaysBeforeFading] hari tanpa aksi, kesehatan karang
  /// turun [healthDropPerDay] poin per hari berikutnya. 1 aksi memulihkan
  /// penuh ke 100. CD8 dengan jalan keluar: pesan selalu memotivasi.
  static const int idleDaysBeforeFading = 3;
  static const int healthDropPerDay = 25;
  static const int maxReefHealth = 100;
  static const int minReefHealth = 0;

  // --- Batas harian (spec.md §7.2) ---
  /// Tiap jenis aksi hanya 1× per hari kalender (maks. 6 = jumlah
  /// ActionType); inilah pencegah abuse, menggantikan batas "10 aksi/hari".

  /// Bonus "Hari Sempurna" saat keenam jenis tercatat dalam satu hari.
  static const int perfectDayBonusXp = 10;

  // --- Daily Quest rotasi 2 hari (spec.md §7.2) ---
  static const int dailyQuestRewardXp = 15;
  static const int dailyQuestCountTarget = 3;
  static const int dailyQuestVarietyTarget = 2;
  static const int varietyLookbackDays = 3;

  // --- Target mingguan (spec.md §7.2, disetujui pengguna) ---
  static const int weeklyActionTarget = 12;

  // --- Mystery Chest (spec.md §7.2) ---
  /// 1x/hari, hanya setelah Daily Quest selesai.
  static const int chestsPerDay = 1;
}
