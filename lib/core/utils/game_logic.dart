import 'dart:math' as math;

import '../constants/app_strings.dart';
import '../constants/game_rules.dart';
import '../constants/impact_constants.dart';
import '../../data/models/action_log.dart';
import '../../data/models/progress.dart';
import '../../data/models/quest.dart';
import 'clock.dart';

/// Fungsi murni logika game — terpisah dari UI agar mudah diuji
/// (agent.md §4). Tahap terumbu dihitung dari total aksi (spec.md §7.2).
///
/// CD2 + CD4: progres terumbu adalah feedback pencapaian milik pribadi.
ReefStage reefStageFor(int totalActions) {
  var stage = ReefStage.tunas;
  for (final candidate in ReefStage.values) {
    if (totalActions >= candidate.minActions) stage = candidate;
  }
  return stage;
}

/// Jumlah aksi menuju tahap terumbu berikutnya; null jika sudah maksimum.
int? actionsUntilNextReefStage(int totalActions) {
  final current = reefStageFor(totalActions);
  final nextIndex = ReefStage.values.indexOf(current) + 1;
  if (nextIndex >= ReefStage.values.length) return null;
  return ReefStage.values[nextIndex].minActions - totalActions;
}

/// Proporsi pertumbuhan (0..1) di dalam tahap terumbu saat ini.
///
/// Unit B: tiap aksi memperbesar karang sedikit meski belum berganti tahap.
/// Tahap maksimum (Ekosistem) memakai rentang imajiner 20 aksi terakhir.
double reefGrowthFraction(int totalActions) {
  final stages = ReefStage.values;
  final stage = reefStageFor(totalActions);
  final index = stages.indexOf(stage);
  final lo = stage.minActions;
  final hi = index + 1 < stages.length
      ? stages[index + 1].minActions
      : lo + 20;
  return ((totalActions - lo + 1) / (hi - lo)).clamp(0.0, 1.0);
}

/// Kesehatan karang yang tampil pada [today] (spec.md §7.2 "karang memudar").
///
/// CD8: memudar linear -25/hari mulai hari ke-4 tanpa aksi, bisa pulih
/// penuh dengan 1 aksi — tidak pernah ada hukuman permanen.
int reefHealthOn({required DateTime? lastActionDate, required DateTime today}) {
  if (lastActionDate == null) return GameRules.maxReefHealth;
  final idleDays = Clock.daysBetween(lastActionDate, today);
  if (idleDays <= GameRules.idleDaysBeforeFading) {
    return GameRules.maxReefHealth;
  }
  final dropped =
      (idleDays - GameRules.idleDaysBeforeFading) * GameRules.healthDropPerDay;
  return math.max(GameRules.minReefHealth, GameRules.maxReefHealth - dropped);
}

/// Hasil satu aksi yang dicatat, dihitung oleh [applyAction].
class ActionOutcome {
  const ActionOutcome({
    required this.progress,
    required this.xpGained,
    required this.grams,
    required this.leveledUp,
    required this.firstAction,
    required this.freezeUsed,
    this.perfectDay = false,
    this.stageUp,
    this.streakMilestone,
  });

  final Progress progress;
  final int xpGained;
  final double grams;
  final bool leveledUp;

  /// Win-State #2: aksi pertama pengguna (badge "Penyelam Baru").
  final bool firstAction;

  /// Freeze dipakai untuk menyelamatkan streak dari 1 hari terlewat.
  final bool freezeUsed;

  /// Win-State #5b: keenam jenis aksi tercatat hari ini (+10 XP).
  final bool perfectDay;

  /// Tahap terumbu baru jika tahap naik karena aksi ini (Win-State #3).
  final ReefStage? stageUp;

  /// 3/7/30 bila streak menyentuh penanda Win-State #3.
  final int? streakMilestone;
}

/// Hasil penambahan XP bonus (mis. dari Daily Quest) ke progress.
class XpOutcome {
  const XpOutcome({
    required this.progress,
    required this.leveledUp,
    required this.xpGranted,
  });

  final Progress progress;
  final bool leveledUp;
  final int xpGranted;
}

/// Menambahkan [amount] XP dengan kenaikan level berantai (spec.md §7.2).
XpOutcome applyXp(Progress progress, int amount) {
  var xp = progress.xp + amount;
  var level = progress.level;
  while (xp >= GameRules.xpNeededForLevel(level)) {
    xp -= GameRules.xpNeededForLevel(level);
    level += 1;
  }
  return XpOutcome(
    progress: progress.copyWith(xp: xp, level: level),
    leveledUp: level > progress.level,
    xpGranted: amount,
  );
}

/// Dua varian Daily Quest yang berotasi tiap hari (spec.md §7.2 Unit A).
enum DailyQuestKind { count, variety }

/// Rotasi deterministik: tanggal genap -> [DailyQuestKind.count],
/// gasal -> [DailyQuestKind.variety].
DailyQuestKind dailyQuestKind(DateTime day) => Clock.dateOnly(day).day.isEven
    ? DailyQuestKind.count
    : DailyQuestKind.variety;

/// Daily Quest deterministik untuk hari [day] (spec.md §6.1 layar 5).
/// CD2 + CD7: satu target kecil harian yang membuka Mystery Chest,
/// berganti jenis agar tidak monoton.
Quest dailyQuestFor(DateTime day) {
  final date = Clock.dateOnly(day);
  final kind = dailyQuestKind(date);
  return Quest(
    id: 'daily-${date.year}-${date.month}-${date.day}',
    title: kind == DailyQuestKind.count
        ? AppStrings.questDailyThree
        : AppStrings.questDailyVariety,
    targetCount: kind == DailyQuestKind.count
        ? GameRules.dailyQuestCountTarget
        : GameRules.dailyQuestVarietyTarget,
    date: date,
    rewardXp: GameRules.dailyQuestRewardXp,
  );
}

/// ID jenis aksi yang sudah dicatat pada hari [day] (spec.md §7.2 Unit A:
/// 1 aksi per jenis per hari). Status dihitung dari log, bukan disimpan.
Set<String> loggedTypeIdsOnDay(List<ActionLog> logs, DateTime day) => {
  for (final log in logs)
    if (Clock.dateOnly(log.timestamp) == Clock.dateOnly(day)) log.actionType,
};

/// Jumlah jenis aksi yang dicatat hari [today] dan belum pernah dicatat
/// pada [GameRules.varietyLookbackDays] hari sebelumnya (progres quest
/// "variasi" — spec.md §7.2 Unit A).
int newTypeCountToday(List<ActionLog> logs, DateTime today) {
  final todaySet = loggedTypeIdsOnDay(logs, today);
  final lookbackStart = Clock.dateOnly(today)
      .subtract(const Duration(days: GameRules.varietyLookbackDays));
  final recentSet = {
    for (final log in logs)
      if (Clock.dateOnly(log.timestamp).isBefore(Clock.dateOnly(today)) &&
          !Clock.dateOnly(log.timestamp).isBefore(lookbackStart))
        log.actionType,
  };
  return todaySet.difference(recentSet).length;
}

/// Spesies yang sudah terbuka berdasarkan total aksi (spec.md §7.2
/// Win-State #5). CD4: koleksi milik pengguna, terbuka bertahap.
List<T> unlockedFrom<T extends SpeciesThreshold>(
  List<T> all,
  int totalActions,
) => all.where((s) => totalActions >= s.minActions).toList(growable: false);

/// Abstraksi kecil agar helper koleksi tidak bergantung tipe mock.
abstract interface class SpeciesThreshold {
  int get minActions;
}

/// Gelar pengguna (spec.md §3.5 status). CD2: gelar mengikuti prestasi.
String userTitle({required int level, required Set<String> badges}) {
  if (level >= 10) return 'Penjaga Karang';
  if (badges.contains('penyelam_baru')) return 'Penyelam Baru';
  return 'Calon Penyelam';
}

/// Hasil penerapan satu aksi ke [progress] pada hari [today], dengan
/// [typesCompletedToday] = jumlah jenis aksi berbeda yang tercatat hari
/// ini termasuk [type] (pemanggil menjamin 1×/jenis/hari, spec.md §7.2).
///
/// Semua aturan dari spec.md §7.2: Hari Sempurna, streak + freeze,
/// pemulihan kesehatan karang, dan level-up berantai.
ActionOutcome applyAction({
  required Progress progress,
  required ActionType type,
  required DateTime today,
  required int typesCompletedToday,
}) {
  // CD2 + CD7: Hari Sempurna — keenam jenis aksi tercatat dalam sehari.
  final perfectDay = typesCompletedToday >= ActionType.values.length;
  final xpGained = type.xp + (perfectDay ? GameRules.perfectDayBonusXp : 0);

  var xp = progress.xp + xpGained;
  var level = progress.level;
  while (xp >= GameRules.xpNeededForLevel(level)) {
    xp -= GameRules.xpNeededForLevel(level);
    level += 1;
  }

  var streak = progress.streak;
  var freezes = progress.freezes;
  var freezeUsed = false;
  final gap = progress.lastActionDate == null
      ? null
      : Clock.daysBetween(progress.lastActionDate!, today);
  if (gap == null || gap >= 2) {
    if (gap == 2 && freezes > 0) {
      freezes -= 1;
      freezeUsed = true;
      streak += 1;
    } else {
      streak = 1;
    }
  } else if (gap == 1) {
    streak += 1;
  } // gap == 0: hari yang sama, streak tidak bertambah.

  final oldStage = reefStageFor(progress.totalActions);
  final newStage = reefStageFor(progress.totalActions + 1);

  final next = Progress(
    xp: xp,
    level: level,
    streak: streak,
    longestStreak: math.max(progress.longestStreak, streak),
    lastActionDate: today,
    freezes: freezes,
    // CD8: 1 aksi memulihkan karang penuh.
    reefHealth: GameRules.maxReefHealth,
    totalActions: progress.totalActions + 1,
  );

  const milestones = [3, 7, 30];
  return ActionOutcome(
    progress: next,
    xpGained: xpGained,
    perfectDay: perfectDay,
    grams: ImpactConstants.gramsFor(type.id),
    leveledUp: level > progress.level,
    firstAction: progress.totalActions == 0,
    freezeUsed: freezeUsed,
    stageUp: newStage == oldStage ? null : newStage,
    streakMilestone: milestones.contains(streak) && streak > progress.streak
        ? streak
        : null,
  );
}
