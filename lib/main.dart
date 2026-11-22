import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers.dart';
import 'data/repositories/local_storage_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = await LocalStorageRepository.create();
  final settings = await repository.loadSettings();

  runApp(
    ProviderScope(
      overrides: [
        storageRepositoryProvider.overrideWithValue(repository),
        settingsProvider.overrideWith(
          () => SettingsNotifier(repository, settings),
        ),
      ],
      child: const TerumbuApp(),
    ),
  );
}
