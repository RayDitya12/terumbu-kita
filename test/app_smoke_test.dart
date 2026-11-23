import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/constants/app_strings.dart';
import 'package:terumbu_kita/core/constants/game_rules.dart';
import 'package:terumbu_kita/data/models/user_profile.dart';

import 'helpers.dart';

void main() {
  testWidgets('shell menampilkan 5 tab navigasi dan Home terumbu', (
    tester,
  ) async {
    await pumpTerumbuApp(
      tester,
      profile: UserProfile(
        nickname: 'Sari',
        avatarId: 0,
        focusHabit: ActionType.refill,
        onboardingDone: true,
        createdAt: DateTime(2026, 11, 1),
      ),
    );

    expect(find.text(AppStrings.navHome), findsOneWidget);
    expect(find.text(AppStrings.navQuest), findsOneWidget);
    expect(find.text(AppStrings.navImpact), findsOneWidget);
    expect(find.text(AppStrings.navCommunity), findsOneWidget);
    expect(find.text(AppStrings.navProfile), findsOneWidget);
    expect(find.text(AppStrings.homeLogAction), findsOneWidget);
    expect(find.text(AppStrings.reefStageNames['tunas']!), findsOneWidget);

    // Pindah tab ke Profil menampilkan layar Demo Mode (Tahap 5).
    await tester.tap(find.text(AppStrings.navProfile));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text(AppStrings.demoModeTitle), 200);
    expect(find.text(AppStrings.demoModeTitle), findsOneWidget);
  });
}
