import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/constants/app_strings.dart';
import 'package:terumbu_kita/core/constants/game_rules.dart';
import 'package:terumbu_kita/data/models/action_log.dart';
import 'package:terumbu_kita/data/models/progress.dart';
import 'package:terumbu_kita/data/models/user_profile.dart';

import '../helpers.dart';

void main() {
  UserProfile rani() => UserProfile(
    nickname: 'Rani',
    avatarId: 1,
    focusHabit: ActionType.tumbler,
    onboardingDone: true,
    createdAt: DateTime(2026, 11, 1),
  );

  ActionLog seed(String type, DateTime at, int index) => ActionLog(
    id: 'seed-$index',
    actionType: type,
    timestamp: at,
    xpGained: 10,
    plasticGrams: 10,
  );

  testWidgets('catat aksi pertama: XP, win-state, badge, dan home ter-update', (
    tester,
  ) async {
    final repository = await pumpTerumbuApp(tester, profile: rani());

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
      find.text('Tumbuh 5 aksi lagi untuk memperbesar terumbu.'),
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

  testWidgets('1×/jenis/hari: kartu bercentang dan tap kedua ditolak', (
    tester,
  ) async {
    final now = DateTime.now();
    await pumpTerumbuApp(
      tester,
      profile: rani(),
      actionLogs: [seed('tumbler', now, 0)],
    );

    await tester.tap(find.text(AppStrings.homeLogAction));
    await tester.pumpAndSettle();

    // Jenis yang sudah tercatat: centang + label, bukan fokus lagi.
    expect(find.text(AppStrings.logActionDoneToday), findsOneWidget);
    expect(find.text(AppStrings.logActionRecommended), findsNothing);
    // Kartu selesai tidak bisa dipilih.
    await tester.tap(find.byKey(const Key('action-tumbler')));
    await tester.pump();
    // Submit tetap tak terpilih apa pun → nonaktif.
    final submit = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text(AppStrings.logActionSubmit),
        matching: find.byType(FilledButton),
      ),
    );
    expect(submit.onPressed, isNull);
  });

  testWidgets('Hari Sempurna: jenis ke-6 memberi bonus +10 XP', (tester) async {
    final now = DateTime.now();
    final five = [
      'tumbler',
      'tote',
      'no_straw',
      'refill',
      'no_cutlery',
    ].asMap().entries.map((e) => seed(e.value, now, e.key)).toList();
    final repository = await pumpTerumbuApp(
      tester,
      profile: rani(),
      actionLogs: five,
      progress: Progress(totalActions: 5, streak: 1, lastActionDate: now),
    );

    await tester.tap(find.text(AppStrings.homeLogAction));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(GridView), const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('action-own_container')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('action-own_container')));
    await tester.pump();
    await tester.tap(find.text(AppStrings.logActionSubmit));
    await tester.pumpAndSettle();

    // 15 XP aksi + 10 bonus Hari Sempurna.
    expect(find.text('+25 XP'), findsOneWidget);
    expect(find.text(AppStrings.winActionPerfectDay), findsOneWidget);

    final progress = await repository.loadProgress();
    expect(progress.totalActions, 6);
    final logs = await repository.loadActionLogs();
    expect(logs, hasLength(6));
  });

  testWidgets('Batalkan aksi terakhir: progres, log, dan badge dipulihkan', (
    tester,
  ) async {
    final repository = await pumpTerumbuApp(tester, profile: rani());

    await tester.tap(find.text(AppStrings.homeLogAction));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.logActionSubmit));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.winActionCta));
    await tester.pumpAndSettle();

    // Buka lagi → tombol Batalkan tersedia untuk log terakhir hari ini.
    await tester.tap(find.text(AppStrings.homeLogAction));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cancel-last-action')), findsOneWidget);

    await tester.tap(find.byKey(const Key('cancel-last-action')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.logActionCancelDone), findsOneWidget);

    final progress = await repository.loadProgress();
    expect(progress.totalActions, 0);
    expect(progress.xp, 0);
    expect(progress.streak, 0);
    expect(progress.lastActionDate, isNull);
    final logs = await repository.loadActionLogs();
    expect(logs, isEmpty);
    final collection = await repository.loadCollection();
    expect(collection.badges, isNot(contains('penyelam_baru')));
  });
}
