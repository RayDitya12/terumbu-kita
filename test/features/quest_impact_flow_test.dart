import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/constants/app_strings.dart';
import 'package:terumbu_kita/core/constants/game_rules.dart';
import 'package:terumbu_kita/data/models/user_profile.dart';

import '../helpers.dart';

void main() {
  final profile = UserProfile(
    nickname: 'Rani',
    avatarId: 1,
    focusHabit: ActionType.tumbler,
    onboardingDone: true,
    createdAt: DateTime(2026, 11, 1),
  );

  Future<void> logThreeActions(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text(AppStrings.homeLogAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.logActionSubmit));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.winActionCta));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('3 aksi menyelesaikan daily quest dan membuka chest', (
    tester,
  ) async {
    await pumpTerumbuApp(tester, profile: profile);
    await logThreeActions(tester);

    await tester.tap(find.text(AppStrings.navQuest));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.questCompleted), findsOneWidget);
    await tester.tap(find.text(AppStrings.chestOpen));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.chestRewardTitle), findsOneWidget);
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // Chest hanya 1x/hari.
    expect(find.text(AppStrings.chestOpenedToday), findsOneWidget);
  });

  testWidgets('target mingguan menampilkan hitungan aksi', (tester) async {
    await pumpTerumbuApp(tester, profile: profile);
    await logThreeActions(tester);

    await tester.tap(find.text(AppStrings.navQuest));
    await tester.pumpAndSettle();
    expect(find.textContaining('(3/5)'), findsOneWidget);
  });

  testWidgets('layar dampak menampilkan total dan grafik', (tester) async {
    await pumpTerumbuApp(tester, profile: profile);
    await logThreeActions(tester);

    await tester.tap(find.text(AppStrings.navImpact));
    await tester.pumpAndSettle();

    // 3 x tumbler = 90 g.
    expect(find.text('90 g'), findsOneWidget);
    expect(find.text('≈ 90 sedotan'), findsOneWidget);
    expect(find.text(AppStrings.impactWeekLabel), findsOneWidget);
    expect(find.text(AppStrings.impactNoData), findsNothing);
  });

  testWidgets('layar dampak kosong memberi pesan memotivasi', (tester) async {
    await pumpTerumbuApp(tester, profile: profile);

    await tester.tap(find.text(AppStrings.navImpact));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.impactNoData), findsOneWidget);
  });
}
