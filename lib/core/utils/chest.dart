import 'dart:math' as math;

import '../constants/game_rules.dart';
import 'clock.dart';

/// Mystery Chest harian (spec.md §7.2). CD7: kejutan acak berbobot.
enum ChestRewardType { xp, freeze, decoration, fact }

class ChestReward {
  const ChestReward(this.type, this.value);

  final ChestRewardType type;

  /// Isi hadiah: jumlah XP, id dekorasi, atau indeks fakta.
  final int value;
}

/// Undian berbobot: 50% XP, 20% freeze, 15% dekorasi, 15% fakta.
/// [rng] injeksi agar tes deterministik (agent.md §4).
ChestReward pickChestReward(math.Random rng) {
  final roll = rng.nextDouble();
  if (roll < 0.50) return ChestReward(ChestRewardType.xp, 10);
  if (roll < 0.70) return ChestReward(ChestRewardType.freeze, 1);
  if (roll < 0.85) {
    return ChestReward(ChestRewardType.decoration, rng.nextInt(3) + 1);
  }
  return ChestReward(ChestRewardType.fact, rng.nextInt(4) + 1);
}

/// Chest hanya 1x/hari dan hanya setelah Daily Quest selesai (spec.md §7.2).
bool chestAvailable({
  required bool dailyQuestCompleted,
  required DateTime? lastChestDate,
  required DateTime today,
}) =>
    dailyQuestCompleted &&
    (lastChestDate == null ||
        Clock.dateOnly(lastChestDate) != Clock.dateOnly(today));

/// Kapasitas freeze mengikuti aturan streak (maks 2).
int freezesAfterOpen(int currentFrezes, ChestReward reward) =>
    reward.type == ChestRewardType.freeze
    ? math.min(GameRules.maxFreezes, currentFrezes + reward.value)
    : currentFrezes;
