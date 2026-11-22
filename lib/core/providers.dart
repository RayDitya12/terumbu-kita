import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/app_settings.dart';
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
