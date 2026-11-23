import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/constants/app_strings.dart';
import 'package:terumbu_kita/core/constants/game_rules.dart';
import 'package:terumbu_kita/data/models/app_settings.dart';
import 'package:terumbu_kita/data/models/progress.dart';
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

  testWidgets('layar komunitas menampilkan counter, leaderboard, dan tim', (
    tester,
  ) async {
    await pumpTerumbuApp(tester, profile: profile);

    await tester.tap(find.text(AppStrings.navCommunity));
    await tester.pumpAndSettle();

    // 1284500 g → 1284,5 kg (format Indonesia).
    expect(find.text('1284,5 kg'), findsOneWidget);
    expect(find.text('Dina'), findsOneWidget);
    expect(find.textContaining('5 anggota'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text(AppStrings.communityRewardsLink),
      find.byType(ListView),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.communityRewardsLink), findsOneWidget);
  });

  testWidgets('layar hadiah menampilkan voucher mock dengan kuota', (
    tester,
  ) async {
    await pumpTerumbuApp(tester, profile: profile);

    await tester.tap(find.text(AppStrings.navCommunity));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text(AppStrings.communityRewardsLink),
      find.byType(ListView),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.communityRewardsLink));
    await tester.pumpAndSettle();

    expect(find.text('Diskon 20%'), findsOneWidget);
    expect(find.textContaining('12/50'), findsOneWidget);
    expect(find.textContaining('Simulasi prototipe'), findsOneWidget);

    await tester.tap(find.text(AppStrings.rewardsRedeem));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.rewardsRedeemMock), findsOneWidget);
  });

  testWidgets('koleksi membuka spesies sesuai total aksi', (tester) async {
    await pumpTerumbuApp(
      tester,
      profile: profile,
      progress: const Progress(totalActions: 31),
    );

    await tester.tap(find.text(AppStrings.navProfile));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.profileCollectionLink));
    await tester.pumpAndSettle();

    expect(find.text('Karang Tanduk'), findsOneWidget);
    expect(find.text('Karang Otak'), findsOneWidget);
    expect(find.text(AppStrings.collectionLocked), findsNothing);
  });

  testWidgets('koleksi mengunci spesies yang belum tercapai', (tester) async {
    await pumpTerumbuApp(tester, profile: profile);

    await tester.tap(find.text(AppStrings.navProfile));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.profileCollectionLink));
    await tester.pumpAndSettle();

    expect(find.textContaining(AppStrings.collectionLocked), findsOneWidget);
  });

  testWidgets('demo mode maju 7 hari menggeser offset tersimpan', (
    tester,
  ) async {
    final repository = await pumpTerumbuApp(tester, profile: profile);

    await tester.tap(find.text(AppStrings.navProfile));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.demoAdvance7));
    await tester.pumpAndSettle();

    final settings = await repository.loadSettings();
    expect(settings.simulatedDateOffsetDays, 7);
    expect(find.text('Offset waktu saat ini: 7 hari'), findsOneWidget);
  });

  testWidgets('demo mode reset data mengembalikan ke splash', (tester) async {
    await pumpTerumbuApp(
      tester,
      profile: profile,
      progress: const Progress(totalActions: 12),
      settings: const AppSettings(simulatedDateOffsetDays: 3),
    );

    await tester.tap(find.text(AppStrings.navProfile));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text(AppStrings.demoReset),
      find.byType(ListView),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.demoReset));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.splashCta), findsOneWidget);
  });

  testWidgets('demo mode isi data contoh menghasilkan riwayat 2 minggu', (
    tester,
  ) async {
    final repository = await pumpTerumbuApp(tester, profile: profile);

    await tester.tap(find.text(AppStrings.navProfile));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.demoSampleData));
    await tester.pumpAndSettle();

    final logs = await repository.loadActionLogs();
    expect(logs, hasLength(28));
    final progress = await repository.loadProgress();
    expect(progress.totalActions, 28);
    expect(progress.streak, greaterThanOrEqualTo(1));
  });
}
