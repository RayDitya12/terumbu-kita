import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/constants/app_strings.dart';
import 'package:terumbu_kita/core/constants/game_rules.dart';
import 'package:terumbu_kita/data/models/user_profile.dart';

import '../helpers.dart';

void main() {
  testWidgets('pengguna baru diarahkan ke splash, bukan home', (tester) async {
    await pumpTerumbuApp(tester, profile: null);
    expect(find.text(AppStrings.splashCta), findsOneWidget);
  });

  testWidgets('pengguna yang sudah onboarding langsung masuk home', (
    tester,
  ) async {
    await pumpTerumbuApp(tester, profile: _doneProfile());
    expect(find.text(AppStrings.homeLogAction), findsOneWidget);
    expect(find.text(AppStrings.navQuest), findsOneWidget);
  });

  group('alur onboarding lengkap (spec.md §6.2)', () {
    testWidgets('splash → intro 3 slide → glowing choice → profil → home', (
      tester,
    ) async {
      final repository = await pumpTerumbuApp(tester, profile: null);

      // Discovery: satu tombol terang.
      await tester.tap(find.text(AppStrings.splashCta));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.introSlide1Title), findsOneWidget);

      // Dua slide intro singkat.
      await tester.tap(find.text(AppStrings.introNext));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.introSlide2Title), findsOneWidget);
      await tester.tap(find.text(AppStrings.introNext));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.introSlide3Title), findsOneWidget);

      // Glowing Choice: satu pilihan disarankan sudah terpilih.
      await tester.tap(find.text(AppStrings.introStart));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.choicePrompt), findsOneWidget);
      expect(find.text(AppStrings.habitLabels['tumbler']!), findsOneWidget);
      expect(find.text(AppStrings.choiceRecommended), findsOneWidget);
      // Pengunjung bisa ganti pilihan: kartu lain disentuh, lalu kembali.
      await tester.tap(find.text(AppStrings.habitLabels['tote']!));
      await tester.pump();
      await tester.tap(find.text(AppStrings.habitLabels['tumbler']!));
      await tester.pump();
      await tester.tap(find.text(AppStrings.choiceConfirm));
      await tester.pumpAndSettle();

      // Profil: nama + avatar, tanpa formulir panjang.
      expect(find.text(AppStrings.profileTitle), findsOneWidget);
      await tester.enterText(find.byKey(const Key('nickname-field')), 'Rani');
      await tester.tap(find.byKey(const ValueKey('avatar-2')));
      await tester.pump();
      await tester.tap(find.text(AppStrings.profileDone));
      await tester.pumpAndSettle();

      // Win-State #1: terumbu pertama lahir (spec.md §3.3).
      expect(find.text(AppStrings.winReefBornTitle), findsOneWidget);
      await tester.tap(find.text(AppStrings.winReefBornCta));
      await tester.pumpAndSettle();
      expect(
        find.text('${AppStrings.homeGreetingPrefix} Rani'),
        findsOneWidget,
      );

      // Data tersimpan dan onboardingDone naik (agent.md §6 DoD).
      final saved = await repository.loadProfile();
      expect(saved?.onboardingDone, isTrue);
      expect(saved?.nickname, 'Rani');
      expect(saved?.focusHabit, ActionType.tumbler);
      expect(saved?.avatarId, 2);

      // Dialog tidak muncul dua kali setelah home dibangun ulang.
      await pumpTerumbuApp(tester, profile: saved!);
      expect(find.text(AppStrings.winReefBornTitle), findsNothing);
    });
  });
}

UserProfile _doneProfile() => UserProfile(
  nickname: 'Dimas',
  avatarId: 1,
  focusHabit: ActionType.tote,
  onboardingDone: true,
  createdAt: DateTime(2026, 11, 1),
);
