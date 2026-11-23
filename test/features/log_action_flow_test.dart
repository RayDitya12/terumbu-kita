import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/constants/app_strings.dart';
import 'package:terumbu_kita/core/constants/game_rules.dart';
import 'package:terumbu_kita/data/models/action_log.dart';
import 'package:terumbu_kita/data/models/user_profile.dart';

import '../helpers.dart';

void main() {
  testWidgets('catat aksi pertama: XP, win-state, badge, dan home ter-update', (
    tester,
  ) async {
    final profile = UserProfile(
      nickname: 'Rani',
      avatarId: 1,
      focusHabit: ActionType.tumbler,
      onboardingDone: true,
      createdAt: DateTime(2026, 11, 1),
    );
    final repository = await pumpTerumbuApp(tester, profile: profile);

    // Dari Home, tombol Catat Aksi membuka layar aksi.
    await tester.tap(find.text(AppStrings.homeLogAction));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.logActionTitle), findsOneWidget);

    // CD3: kebiasaan fokus (tumbler) sudah terseleksi + label rekomendasi.
    expect(find.text(AppStrings.logActionRecommended), findsOneWidget);

    // Ganti ke tote (8 g), lalu simpan.
    await tester.tap(find.byKey(const Key('action-tote')));
    await tester.pump();
    await tester.tap(find.text(AppStrings.logActionSubmit));
    await tester.pumpAndSettle();

    // Win-State #2: XP, dampak, streak, badge Penyelam Baru.
    final sheet = find.byType(BottomSheet);
    expect(
      find.descendant(of: sheet, matching: find.text('+10 XP')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: sheet,
        matching: find.textContaining('plastik dihindari aksi ini'),
      ),
      findsOneWidget,
    );
    expect(find.text('≈ 8 sedotan'), findsOneWidget);
    expect(find.text('1 hari beruntun (Level 1)'), findsOneWidget);
    expect(find.text(AppStrings.winActionBadgeNewDiver), findsOneWidget);

    await tester.tap(find.text(AppStrings.winActionCta));
    await tester.pumpAndSettle();

    // Kembali ke Home dengan angka yang sudah hidup.
    expect(find.text('8 g plastik dihindari'), findsOneWidget);
    expect(
      find.text('Tumbuh 9 aksi lagi untuk memperbesar terumbu.'),
      findsOneWidget,
    );

    // Persisten: progress, log aksi, dan badge tersimpan.
    final progress = await repository.loadProgress();
    expect(progress.totalActions, 1);
    expect(progress.xp, 10);
    expect(progress.streak, 1);
    final logs = await repository.loadActionLogs();
    expect(logs, hasLength(1));
    expect(logs.single.actionType, 'tote');
    expect(logs.single.xpGained, 10);
    final collection = await repository.loadCollection();
    expect(collection.badges, contains('penyelam_baru'));
  });

  testWidgets('aksi tanpa XP saat batas harian tercapai', (tester) async {
    final profile = UserProfile(
      nickname: 'Rani',
      avatarId: 1,
      focusHabit: ActionType.tumbler,
      onboardingDone: true,
      createdAt: DateTime(2026, 11, 1),
    );
    // Isi 10 log aksi hari ini lewat bootstrap provider.
    final now = DateTime.now();
    final logs = [
      for (var i = 0; i < 10; i++)
        ActionLog(
          id: 'seed-$i',
          actionType: 'no_straw',
          timestamp: now,
          xpGained: 5,
          plasticGrams: 1,
        ),
    ];
    await pumpTerumbuApp(tester, profile: profile, actionLogs: logs);

    await tester.tap(find.text(AppStrings.homeLogAction));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.logActionSubmit));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.winActionXp(0)), findsOneWidget);
    expect(find.textContaining(AppStrings.winActionCapReached), findsOneWidget);
  });
}
