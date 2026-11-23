import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terumbu_kita/app.dart';
import 'package:terumbu_kita/core/providers.dart';
import 'package:terumbu_kita/data/models/action_log.dart';
import 'package:terumbu_kita/data/models/app_settings.dart';
import 'package:terumbu_kita/data/models/collection.dart';
import 'package:terumbu_kita/data/models/quest.dart';
import 'package:terumbu_kita/data/models/progress.dart';
import 'package:terumbu_kita/data/models/user_profile.dart';
import 'package:terumbu_kita/data/mock/mock_data.dart';
import 'package:terumbu_kita/data/repositories/local_storage_repository.dart';

/// Fixture JSON untuk tes layar berbasis data mock (spec.md §7.4).
const _fixtureCommunity =
    '{"campus":"Univ","leaderboard":[{"name":"Dina","xp":120,"avatarId":1}],'
    '"teams":[{"id":"t1","name":"Tim Karang","memberCount":5,'
    '"weeklyContribution":12}],"nationalCounterGrams":1284500,'
    '"joinHint":"34 teman bergabung"}';
const _fixtureRewards =
    '{"vouchers":[{"id":"v1","title":"Diskon 20%","partner":"Kafe Barokah",'
    '"condition":"Bawa tumbler","quotaTotal":50,"quotaLeft":12}],'
    '"disclaimer":"Simulasi prototipe."}';
const _fixtureSpecies =
    '{"species":[{"id":"s1","name":"Karang Tanduk","rarity":"umum",'
    '"minActions":0},{"id":"s2","name":"Karang Otak","rarity":"langka",'
    '"minActions":30}]}';
const _fixtureFacts = '{"facts":[{"text":"Fakta A","source":"sumber"}]}';

Future<String> _fixtureReader(String path) async {
  if (path.endsWith('community.json')) return _fixtureCommunity;
  if (path.endsWith('rewards.json')) return _fixtureRewards;
  if (path.endsWith('species.json')) return _fixtureSpecies;
  return _fixtureFacts;
}

/// Hasil ulang bootstrap app dengan nilai awal tertentu.
Future<LocalStorageRepository> pumpTerumbuApp(
  WidgetTester tester, {
  UserProfile? profile,
  Progress progress = const Progress(),
  AppSettings settings = const AppSettings(),
  List<ActionLog> actionLogs = const [],
  List<Quest> quests = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  final repository = await LocalStorageRepository.create();
  // ReefScene (Unit B) menganimasi terus; matikan animasi agar
  // pumpAndSettle tetap berhenti seperti sebelumnya.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        storageRepositoryProvider.overrideWithValue(repository),
        mockDataProvider.overrideWithValue(
          MockDataLoader(reader: _fixtureReader),
        ),
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
        questsProvider.overrideWith(() => QuestsNotifier(repository, quests)),
      ],
      child: const TerumbuApp(),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}
