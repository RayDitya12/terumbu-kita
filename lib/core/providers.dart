import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/action_log.dart';
import '../data/models/app_settings.dart';
import '../data/models/collection.dart';
import '../data/models/progress.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/local_storage_repository.dart';
import 'constants/game_rules.dart';
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
    return outcome;
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
}

final collectionProvider = NotifierProvider<CollectionNotifier, Collection>(
  () => throw UnimplementedError('di-override di main()'),
);
