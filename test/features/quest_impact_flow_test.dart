import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/constants/app_strings.dart';
import 'package:terumbu_kita/core/providers.dart';
import 'package:terumbu_kita/core/constants/game_rules.dart';
import 'package:terumbu_kita/core/utils/game_logic.dart';
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

  /// Catat 3 jenis berbeda (aturan Unit A: 1×/jenis/hari) lewat notifier;
  /// satu siklus UI penuh untuk membuktikan layar tetap berfungsi.
  Future<void> logThreeActions(WidgetTester tester) async {
    final notifier = ProviderScope.containerOf(
      tester.element(find.byType(Navigator).first),
    ).read(progressProvider.notifier);
    await notifier.logAction(ActionType.tumbler);
    await notifier.logAction(ActionType.tote);
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.homeLogAction));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(GridView), const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('action-no_straw')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('action-no_straw')));
    await tester.pump();
    await tester.tap(find.text(AppStrings.logActionSubmit));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.winActionCta));
    await tester.pumpAndSettle();
  }

  testWidgets('3 aksi menyelesaikan daily quest (rotasi) dan membuka chest', (
    tester,
  ) async {
    await pumpTerumbuApp(tester, profile: profile);
    await logThreeActions(tester);

    await tester.tap(find.text(AppStrings.navQuest));
    await tester.pumpAndSettle();

    // Quest hari ini (count atau variety) keduanya tercapai oleh 3 jenis
    // baru: count 3/3, variety 3→min(2)=2/2.
    expect(find.text(AppStrings.questCompleted), findsOneWidget);
    await tester.tap(find.text(AppStrings.chestOpen));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.chestRewardTitle), findsOneWidget);
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // Chest hanya 1x/hari.
    expect(find.text(AppStrings.chestOpenedToday), findsOneWidget);
  });

  testWidgets('target mingguan menampilkan hitungan terhadap 12 aksi', (
    tester,
  ) async {
    await pumpTerumbuApp(tester, profile: profile);
    await logThreeActions(tester);

    await tester.tap(find.text(AppStrings.navQuest));
    await tester.pumpAndSettle();
    expect(find.textContaining('(3/12)'), findsOneWidget);
    expect(find.textContaining('12 aksi minggu ini'), findsOneWidget);
  });

  testWidgets('layar dampak menampilkan total dan grafik', (tester) async {
    await pumpTerumbuApp(tester, profile: profile);
    await logThreeActions(tester);

    await tester.tap(find.text(AppStrings.navImpact));
    await tester.pumpAndSettle();

    // tumbler 30 g + tote 8 g + sedotan 1 g = 39 g.
    expect(find.text('39 g'), findsOneWidget);
    expect(find.text('≈ 39 sedotan'), findsOneWidget);
    expect(find.text(AppStrings.impactWeekLabel), findsOneWidget);
    expect(find.text(AppStrings.impactNoData), findsNothing);
  });

  testWidgets('layar dampak kosong memberi pesan memotivasi', (tester) async {
    await pumpTerumbuApp(tester, profile: profile);

    await tester.tap(find.text(AppStrings.navImpact));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.impactNoData), findsOneWidget);
  });

  testWidgets('kartu quest memakai judul rotasi harian (spec §7.2 Unit A)', (
    tester,
  ) async {
    await pumpTerumbuApp(tester, profile: profile);

    await tester.tap(find.text(AppStrings.navQuest));
    await tester.pumpAndSettle();

    final today = DateTime.now();
    final expected = dailyQuestKind(today) == DailyQuestKind.count
        ? AppStrings.questDailyThree
        : AppStrings.questDailyVariety;
    expect(find.text(expected), findsOneWidget);
  });
}
