import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers.dart';
import 'data/repositories/local_storage_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = await LocalStorageRepository.create();
  final settings = await repository.loadSettings();
  final profile = await repository.loadProfile();
  final progress = await repository.loadProgress();

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
          () => ProgressNotifier(repository, progress),
        ),
      ],
      child: const TerumbuApp(),
    ),
  );
}
