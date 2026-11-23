import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/action_log.dart';
import '../data/models/app_settings.dart';
import '../data/models/collection.dart';
import '../data/models/progress.dart';
import '../data/models/quest.dart';
import '../data/models/user_profile.dart';
import '../data/mock/mock_data.dart';
import '../data/repositories/local_storage_repository.dart';
import 'constants/game_rules.dart';
import 'utils/chest.dart';
import 'utils/clock.dart';
import 'utils/game_logic.dart';

/// Wiring dependensi utama (agent.md §4 arsitektur).

final storageRepositoryProvider = Provider<LocalStorageRepository>(
  (ref) => throw UnimplementedError('di-override di main()'),
);

class SettingsNotifier extends Notifier<AppSettings> {
  SettingsNotifier(this._repository, this._initial);

  final LocalStorageRepository _repository;
  final AppSettings _initial;

  @override
  AppSettings build() => _initial;

  Future<void> update(AppSettings next) async {
    state = next;
    await _repository.saveSettings(next);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  () => throw UnimplementedError('di-override di main()'),
);

/// Satu-satunya sumber waktu untuk logika game (agent.md §2.4).
/// CD8: offset Demo Mode membuat memudar/streak bisa didemokan.
final clockProvider = Provider<Clock>(
  (ref) =>
      Clock(offsetDays: ref.watch(settingsProvider).simulatedDateOffsetDays),
);

class ProfileNotifier extends Notifier<UserProfile?> {
  ProfileNotifier(this._repository, this._initial);

  final LocalStorageRepository _repository;
  final UserProfile? _initial;

  /// Sisa satu kali: Home menampilkan Win-State "terumbu lahir" setelah
  /// onboarding selesai (spec.md §3.3 Win-State #1).
  bool winStatePending = false;

  @override
  UserProfile? build() => _initial;

  Future<void> completeOnboarding(UserProfile profile) async {
    state = profile;
    winStatePending = true;
    await _repository.saveProfile(profile);
  }

  void consumeWinState() => winStatePending = false;

  Future<void> save(UserProfile profile) async {
    state = profile;
    await _repository.saveProfile(profile);
  }

  Future<void> clear() async {
    state = null;
    await _repository.removeProfile();
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, UserProfile?>(
  () => throw UnimplementedError('di-override di main()'),
);

class ProgressNotifier extends Notifier<Progress> {
  ProgressNotifier(this._repository, this._initial);

  final LocalStorageRepository _repository;
  final Progress _initial;

  @override
  Progress build() => _initial;

  Future<void> save(Progress progress) async {
    state = progress;
    await _repository.saveProgress(progress);
  }

  /// CD8: karang memudar mengikuti hari tanpa aksi; dihitung ulang saat
  /// aplikasi dibuka atau Demo Mode menggeser tanggal.
  Future<void> applyDecay(DateTime today) async {
    final health = reefHealthOn(
      lastActionDate: state.lastActionDate,
      today: today,
    );
    if (health != state.reefHealth) {
      await save(state.copyWith(reefHealth: health));
    }
  }

  /// Mencatat satu aksi bebas plastik (spec.md §6.1 layar 4).
  /// Mengembalikan [ActionOutcome] untuk animasi Win-State.
  Future<ActionOutcome> logAction(ActionType type) async {
    final clock = ref.read(clockProvider);
    final today = clock.today;
    final actionsToday = ref
        .read(actionLogsProvider)
        .where((log) => Clock.dateOnly(log.timestamp) == today)
        .length;

    final outcome = applyAction(
      progress: state,
      type: type,
      today: today,
      actionsToday: actionsToday,
    );
    await save(outcome.progress);

    await ref
        .read(actionLogsProvider.notifier)
        .add(
          ActionLog(
            id: 'log-${clock.now.microsecondsSinceEpoch}',
            actionType: type.id,
            timestamp: clock.now,
            xpGained: outcome.xpGained,
            plasticGrams: outcome.grams,
          ),
        );

    final badges = ref.read(collectionProvider.notifier);
    if (outcome.firstAction) await badges.addBadge('penyelam_baru');
    if (outcome.streakMilestone != null) {
      await badges.addBadge('streak_${outcome.streakMilestone}');
    }
    if (outcome.stageUp != null) {
      await badges.addBadge('stage_${outcome.stageUp!.name}');
    }

    // CD2 + CD7: aksi memajukan Daily Quest; hadiah XP diberikan saat selesai.
    await ref.read(questsProvider.notifier).addProgress(today, 1);
    return outcome;
  }

  /// XP bonus dari luar aksi (hadiah quest). Level-up berantai berlaku sama.
  Future<XpOutcome> addBonusXp(int amount) async {
    final outcome = applyXp(state, amount);
    await save(outcome.progress);
    return outcome;
  }

  /// Menambah streak freeze dari Mystery Chest, dibatasi maks 2 (spec §7.2).
  Future<void> addFreeze(int amount) async {
    final total = math.min(GameRules.maxFreezes, state.freezes + amount);
    await save(state.copyWith(freezes: total));
  }

  /// Demo Mode "isi data contoh" (spec.md §8): riwayat 2 minggu, 2 aksi/hari.
  Future<void> loadSampleData() async {
    final clock = ref.read(clockProvider);
    final today = clock.today;
    final logs = <ActionLog>[];
    var progress = const Progress();
    final types = [ActionType.tumbler, ActionType.noStraw];
    for (var back = 13; back >= 0; back--) {
      final day = today.subtract(Duration(days: back));
      for (var i = 0; i < types.length; i++) {
        final outcome = applyAction(
          progress: progress,
          type: types[i],
          today: day,
          actionsToday: i,
        );
        progress = outcome.progress;
        logs.add(
          ActionLog(
            id: 'sample-${day.millisecondsSinceEpoch}-$i',
            actionType: types[i].id,
            timestamp: day.add(Duration(hours: 8 + i)),
            xpGained: outcome.xpGained,
            plasticGrams: outcome.grams,
          ),
        );
      }
    }
    await ref.read(actionLogsProvider.notifier).replaceAll(logs);
    await save(progress);
    final profile = ref.read(profileProvider);
    if (profile == null || !profile.onboardingDone) {
      await ref
          .read(profileProvider.notifier)
          .save(
            UserProfile(
              nickname: 'Rani',
              avatarId: 1,
              focusHabit: ActionType.tumbler,
              onboardingDone: true,
              createdAt: today.subtract(const Duration(days: 14)),
            ),
          );
    }
    final badges = ref.read(collectionProvider.notifier);
    await badges.addBadge('penyelam_baru');
  }

  /// Demo Mode "reset data" (spec.md §8): kosongkan penyimpanan & state.
  Future<void> resetAll() async {
    await _repository.clearAll();
    await save(const Progress());
    await ref.read(actionLogsProvider.notifier).replaceAll(const []);
    await ref.read(questsProvider.notifier).replaceAll(const []);
    await ref.read(collectionProvider.notifier).replaceAll();
    await ref.read(profileProvider.notifier).clear();
    await ref.read(settingsProvider.notifier).update(const AppSettings());
  }
}

final progressProvider = NotifierProvider<ProgressNotifier, Progress>(
  () => throw UnimplementedError('di-override di main()'),
);

class ActionLogsNotifier extends Notifier<List<ActionLog>> {
  ActionLogsNotifier(this._repository, this._initial);

  final LocalStorageRepository _repository;
  final List<ActionLog> _initial;

  @override
  List<ActionLog> build() => _initial;

  Future<void> add(ActionLog log) async {
    state = [...state, log];
    await _repository.saveActionLogs(state);
  }

  Future<void> replaceAll(List<ActionLog> logs) async {
    state = List.unmodifiable(logs);
    await _repository.saveActionLogs(state);
  }
}

final actionLogsProvider =
    NotifierProvider<ActionLogsNotifier, List<ActionLog>>(
      () => throw UnimplementedError('di-override di main()'),
    );

class CollectionNotifier extends Notifier<Collection> {
  CollectionNotifier(this._repository, this._initial);

  final LocalStorageRepository _repository;
  final Collection _initial;

  @override
  Collection build() => _initial;

  Future<void> addBadge(String badgeId) async {
    if (state.badges.contains(badgeId)) return;
    state = state.copyWith(badges: [...state.badges, badgeId]);
    await _repository.saveCollection(state);
  }

  Future<void> addDecoration(String decorationId) async {
    if (state.decorationsOwned.contains(decorationId)) return;
    state = state.copyWith(
      decorationsOwned: [...state.decorationsOwned, decorationId],
    );
    await _repository.saveCollection(state);
  }

  Future<void> replaceAll() async {
    state = const Collection();
    await _repository.saveCollection(state);
  }
}

final collectionProvider = NotifierProvider<CollectionNotifier, Collection>(
  () => throw UnimplementedError('di-override di main()'),
);

class QuestsNotifier extends Notifier<List<Quest>> {
  QuestsNotifier(this._repository, this._initial);

  final LocalStorageRepository _repository;
  final List<Quest> _initial;

  @override
  List<Quest> build() => _initial;

  Future<void> replaceAll(List<Quest> quests) async {
    state = List.unmodifiable(quests);
    await _repository.saveQuests(state);
  }

  Quest? _findDaily(DateTime day) {
    final date = Clock.dateOnly(day);
    for (final quest in state) {
      if (quest.date == date && quest.id.startsWith('daily-')) return quest;
    }
    return null;
  }

  /// Pastikan quest harian hari [day] ada (dibuat saat pertama dibuka),
  /// dengan progres awal = aksi yang sudah tercatat hari itu.
  Future<Quest> ensureDailyQuest(DateTime day) async {
    final existing = _findDaily(day);
    if (existing != null) return existing;
    final todayCount = ref
        .read(actionLogsProvider)
        .where((l) => Clock.dateOnly(l.timestamp) == Clock.dateOnly(day))
        .length;
    final base = dailyQuestFor(day);
    final quest = base.copyWith(
      progress: math.min(base.targetCount, todayCount),
    );
    state = [...state, quest];
    await _repository.saveQuests(state);
    return quest;
  }

  /// Menambahkan progres ke Daily Quest [day]; memberi hadiah XP saat
  /// quest baru selesai (Win-State #4).
  Future<Quest?> addProgress(DateTime day, int delta) async {
    final quest = await ensureDailyQuest(day);
    final progress = math.min(quest.targetCount, quest.progress + delta);
    final nowCompleted = !quest.completed && progress >= quest.targetCount;
    final updated = quest.copyWith(progress: progress);
    state = [for (final q in state) q.id == quest.id ? updated : q];
    if (nowCompleted) {
      final rewarded = updated.copyWith(completed: true);
      state = [for (final q in state) q.id == quest.id ? rewarded : q];
      await ref.read(progressProvider.notifier).addBonusXp(quest.rewardXp);
      await _repository.saveQuests(state);
      return rewarded;
    }
    await _repository.saveQuests(state);
    return null;
  }

  /// Membuka Mystery Chest hari [today]; null jika belum berhak.
  Future<ChestReward?> openChest(DateTime today, {math.Random? rng}) async {
    final quest = _findDaily(today);
    final settings = ref.read(settingsProvider);
    if (!chestAvailable(
      dailyQuestCompleted: quest?.completed ?? false,
      lastChestDate: settings.lastChestDate,
      today: today,
    )) {
      return null;
    }
    final reward = pickChestReward(rng ?? math.Random());
    await ref
        .read(settingsProvider.notifier)
        .update(settings.copyWith(lastChestDate: Clock.dateOnly(today)));
    switch (reward.type) {
      case ChestRewardType.xp:
        await ref.read(progressProvider.notifier).addBonusXp(reward.value);
      case ChestRewardType.freeze:
        await ref.read(progressProvider.notifier).addFreeze(reward.value);
      case ChestRewardType.decoration:
        await ref
            .read(collectionProvider.notifier)
            .addDecoration('deco_${reward.value}');
      case ChestRewardType.fact:
        break; // fakta ditampilkan di UI, tidak perlu disimpan.
    }
    return reward;
  }
}

final questsProvider = NotifierProvider<QuestsNotifier, List<Quest>>(
  () => throw UnimplementedError('di-override di main()'),
);

/// Loader data mock (spec.md §7.4). Tes mengganti provider ini dengan
/// reader fixture agar tidak menyentuh aset.
final mockDataProvider = Provider<MockDataLoader>(
  (ref) => const MockDataLoader(),
);

final communityProvider = FutureProvider<CommunityData>(
  (ref) => ref.watch(mockDataProvider).loadCommunity(),
);

final rewardsProvider = FutureProvider<RewardData>(
  (ref) => ref.watch(mockDataProvider).loadRewards(),
);

final speciesProvider = FutureProvider<List<CoralSpecies>>(
  (ref) => ref.watch(mockDataProvider).loadSpecies(),
);

final factsProvider = FutureProvider<List<ImpactFact>>(
  (ref) => ref.watch(mockDataProvider).loadFacts(),
);
