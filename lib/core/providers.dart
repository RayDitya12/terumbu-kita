import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/app_settings.dart';
import '../data/models/progress.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/local_storage_repository.dart';
import 'utils/clock.dart';

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
}

final progressProvider = NotifierProvider<ProgressNotifier, Progress>(
  () => throw UnimplementedError('di-override di main()'),
);
