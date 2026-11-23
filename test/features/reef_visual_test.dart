import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/constants/app_strings.dart';
import 'package:terumbu_kita/core/constants/game_rules.dart';
import 'package:terumbu_kita/core/utils/game_logic.dart';
import 'package:terumbu_kita/data/models/app_settings.dart';
import 'package:terumbu_kita/data/models/progress.dart';
import 'package:terumbu_kita/data/models/user_profile.dart';
import 'package:terumbu_kita/features/home/presentation/home_screen.dart';
import 'package:terumbu_kita/shared/widgets/reef_scene.dart';

import '../helpers.dart';

final _profile = UserProfile(
  nickname: 'Rani',
  avatarId: 1,
  focusHabit: ActionType.tumbler,
  onboardingDone: true,
  createdAt: DateTime(2026, 11, 1),
);

void main() {
  group('ReefScene visual Unit B', () {
    testWidgets('Home memakai ReefScene dan tetap settle tanpa animasi', (
      tester,
    ) async {
      await pumpTerumbuApp(
        tester,
        profile: _profile,
      );
      expect(find.byType(ReefScene), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('setelan Kualitas efek tersimpan lokal dan default Penuh', (
      tester,
    ) async {
      final repository = await pumpTerumbuApp(
        tester,
        profile: _profile,
      );

      await tester.tap(find.text(AppStrings.navProfile));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.profileQualityTitle), findsOneWidget);

      await tester.tap(find.text(AppStrings.profileQualityHemat));
      await tester.pumpAndSettle();

      final saved = await repository.loadSettings();
      expect(saved.effectQuality, EffectQuality.hemat);
    });

    testWidgets('progress tinggi memakai tahap Ekosistem tanpa error', (
      tester,
    ) async {
      await pumpTerumbuApp(
        tester,
        profile: _profile,
        progress: const Progress(
          xp: 500,
          level: 8,
          totalActions: 45,
          reefHealth: 30,
        ),
      );
      expect(find.text('Ekosistem Laut'), findsOneWidget);
    });
  });

  group('reefGrowthFraction (pertumbuhan dalam tahap)', () {
    test('naik tiap aksi di dalam tahap Tunas 0..5', () {
      expect(reefGrowthFraction(0), closeTo(1 / 6, 0.001));
      expect(reefGrowthFraction(5), 1.0);
    });

    test('reset ke fraksi kecil saat berganti tahap', () {
      expect(reefGrowthFraction(6), closeTo(1 / 12, 0.001));
      expect(reefGrowthFraction(17), 1.0);
      expect(reefGrowthFraction(18), closeTo(1 / 22, 0.001));
    });

    test('Ekosistem memakai rentang 20 aksi dan maksimum 1.0', () {
      expect(reefGrowthFraction(40), closeTo(1 / 20, 0.001));
      expect(reefGrowthFraction(100), 1.0);
    });
  });

  test('ReefStage ambang baru tetap utuh (regresi Unit A)', () {
    expect(ReefStage.tunas.minActions, 0);
    expect(ReefStage.tumbuh.minActions, 6);
    expect(ReefStage.subur.minActions, 18);
    expect(ReefStage.ekosistem.minActions, 40);
  });
}
