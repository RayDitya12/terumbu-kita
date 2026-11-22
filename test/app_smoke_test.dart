import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terumbu_kita/app.dart';
import 'package:terumbu_kita/core/constants/app_strings.dart';
import 'package:terumbu_kita/core/providers.dart';
import 'package:terumbu_kita/data/repositories/local_storage_repository.dart';

void main() {
  testWidgets('shell menampilkan 5 tab navigasi dan Home terisi Clock', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repository = await LocalStorageRepository.create();
    final settings = await repository.loadSettings();

    await tester.pumpWidget(
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
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.navHome), findsOneWidget);
    expect(find.text(AppStrings.navQuest), findsOneWidget);
    expect(find.text(AppStrings.navImpact), findsOneWidget);
    expect(find.text(AppStrings.navCommunity), findsOneWidget);
    expect(find.text(AppStrings.navProfile), findsOneWidget);
    expect(find.textContaining('Terumbu akan tumbuh di sini'), findsOneWidget);

    // Pindah tab ke Profil.
    await tester.tap(find.text(AppStrings.navProfile));
    await tester.pumpAndSettle();
    expect(
      find.text('Profil, Demo Mode, dan reset data dibangun di Tahap 5.'),
      findsOneWidget,
    );
  });
}
