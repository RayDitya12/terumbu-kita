import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers.dart';
import 'core/utils/clock.dart';
import 'core/utils/game_logic.dart';
import 'data/repositories/local_storage_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = await LocalStorageRepository.create();
  final settings = await repository.loadSettings();
  final profile = await repository.loadProfile();
  final progress = await repository.loadProgress();
  final actionLogs = await repository.loadActionLogs();
  final collection = await repository.loadCollection();
  final quests = await repository.loadQuests();

  // CD8: karang memudar saat aplikasi tidak dibuka; dihitung ulang di
  // startup memakai Clock (mendukung offset Demo Mode).
  final clock = Clock(offsetDays: settings.simulatedDateOffsetDays);
  final decayedProgress = progress.copyWith(
    reefHealth: reefHealthOn(
      lastActionDate: progress.lastActionDate,
      today: clock.today,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        storageRepositoryProvider.overrideWithValue(repository),
        settingsProvider.overrideWith(
          () => SettingsNotifier(repository, settings),
        ),
        profileProvider.overrideWith(
          () => ProfileNotifier(repository, profile),
        ),
        progressProvider.overrideWith(
          () => ProgressNotifier(repository, decayedProgress),
        ),
        actionLogsProvider.overrideWith(
          () => ActionLogsNotifier(repository, actionLogs),
        ),
        collectionProvider.overrideWith(
          () => CollectionNotifier(repository, collection),
        ),
        questsProvider.overrideWith(() => QuestsNotifier(repository, quests)),
      ],
      child: const TerumbuApp(),
    ),
  );
}
