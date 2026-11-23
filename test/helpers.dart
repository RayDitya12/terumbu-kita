import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terumbu_kita/app.dart';
import 'package:terumbu_kita/core/providers.dart';
import 'package:terumbu_kita/data/models/action_log.dart';
import 'package:terumbu_kita/data/models/app_settings.dart';
import 'package:terumbu_kita/data/models/collection.dart';
import 'package:terumbu_kita/data/models/progress.dart';
import 'package:terumbu_kita/data/models/user_profile.dart';
import 'package:terumbu_kita/data/repositories/local_storage_repository.dart';

/// Hasil ulang bootstrap app dengan nilai awal tertentu.
Future<LocalStorageRepository> pumpTerumbuApp(
  WidgetTester tester, {
  UserProfile? profile,
  Progress progress = const Progress(),
  AppSettings settings = const AppSettings(),
  List<ActionLog> actionLogs = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  final repository = await LocalStorageRepository.create();

  await tester.pumpWidget(
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
        actionLogsProvider.overrideWith(
          () => ActionLogsNotifier(repository, actionLogs),
        ),
        collectionProvider.overrideWith(
          () => CollectionNotifier(repository, const Collection()),
        ),
      ],
      child: const TerumbuApp(),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}
