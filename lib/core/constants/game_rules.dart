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
///
/// CD4 + CD2: progress visual milik pengguna sendiri (Ownership).
enum ReefStage {
  tunas(minActions: 0),
  tumbuh(minActions: 10),
  subur(minActions: 30),
  ekosistem(minActions: 70);

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
  /// Maks. aksi per hari yang menghasilkan XP (mencegah abuse).
  static const int dailyXpActionCap = 10;

  // --- Target mingguan (spec.md §7.2 "mis. 5 aksi", disetujui pengguna) ---
  static const int weeklyActionTarget = 5;

  // --- Mystery Chest (spec.md §7.2) ---
  /// 1x/hari, hanya setelah Daily Quest selesai.
  static const int chestsPerDay = 1;
}
