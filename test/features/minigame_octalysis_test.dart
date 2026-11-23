import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/constants/app_strings.dart';
import 'package:terumbu_kita/core/constants/game_rules.dart';
import 'package:terumbu_kita/data/models/user_profile.dart';
import 'package:terumbu_kita/features/minigame/presentation/mini_game_screen.dart';

import '../helpers.dart';

void main() {
  final profile = UserProfile(
    nickname: 'Rani',
    avatarId: 1,
    focusHabit: ActionType.tumbler,
    onboardingDone: true,
    createdAt: DateTime(2026, 11, 1),
  );

  testWidgets('mini-game: menjawab 10 item memberi skor dan XP', (
    tester,
  ) async {
    final repository = await pumpTerumbuApp(tester, profile: profile);

    await tester.tap(find.text(AppStrings.navProfile));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text(AppStrings.miniGameTitle),
      find.byType(ListView),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.miniGameTitle));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.miniGamePrompt), findsOneWidget);

    // Jawab 10 item dengan kebenaran penuh memakai urutan deks yang sama
    // dengan layar (seed shuffle tetap, lihat MiniGameScreen).
    final deck = [...sortItems]..shuffle(math.Random(7));
    for (final item in deck) {
      await tester.tap(
        item.recyclable
            ? find.byKey(const Key('answer-reuse'))
            : find.byKey(const Key('answer-once')),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.miniGameScoreText(10)), findsOneWidget);
    await tester.tap(find.byKey(const Key('claim-reward')));
    await tester.pumpAndSettle();

    final progress = await repository.loadProgress();
    expect(progress.xp, 20); // 10 benar x 2 XP.
  });

  testWidgets('layar octalysis menampilkan radar dan keseimbangan', (
    tester,
  ) async {
    await pumpTerumbuApp(tester, profile: profile);

    await tester.tap(find.text(AppStrings.navProfile));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text(AppStrings.octalysisTitle),
      find.byType(ListView),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.octalysisTitle));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.octalysisIntro), findsOneWidget);
    expect(find.textContaining('White Hat'), findsOneWidget);
  });

  testWidgets('banner event musiman tampil di layar Misi', (tester) async {
    await pumpTerumbuApp(tester, profile: profile);

    await tester.tap(find.text(AppStrings.navQuest));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text(AppStrings.eventTitle),
      find.byType(ListView),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.eventBody), findsOneWidget);
  });
}
