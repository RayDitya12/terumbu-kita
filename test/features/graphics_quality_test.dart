import 'package:flutter_test/flutter_test.dart';
import 'package:terumbu_kita/core/constants/app_strings.dart';
import 'package:terumbu_kita/core/constants/game_rules.dart';
import 'package:terumbu_kita/core/constants/visual_config.dart';
import 'package:terumbu_kita/data/models/app_settings.dart';
import 'package:terumbu_kita/data/models/progress.dart';
import 'package:terumbu_kita/data/models/user_profile.dart';

import '../helpers.dart';

final _profile = UserProfile(
  nickname: 'Rani',
  avatarId: 1,
  focusHabit: ActionType.tumbler,
  onboardingDone: true,
  createdAt: DateTime(2026, 11, 1),
);

void main() {
  group('VisualConfig per mode kualitas', () {
    test('Penuh: gelembung 30-40, caustics, rays, shader', () {
      final n = VisualConfig.bubblesFor(EffectQuality.full);
      expect(n, inInclusiveRange(30, 40));
      expect(VisualConfig.causticsFor(EffectQuality.full), isTrue);
      expect(VisualConfig.raysFor(EffectQuality.full), isTrue);
      expect(VisualConfig.shaderFor(EffectQuality.full), isTrue);
    });

    test('Hemat: separuh gelembung Penuh, caustics fallback, tanpa rays', () {
      expect(
        VisualConfig.bubblesFor(EffectQuality.hemat),
        VisualConfig.fullBubbleCount ~/ 2,
      );
      expect(VisualConfig.causticsFor(EffectQuality.hemat), isTrue);
      expect(VisualConfig.raysFor(EffectQuality.hemat), isFalse);
      expect(VisualConfig.shaderFor(EffectQuality.hemat), isFalse);
    });

    test('Minimal: tanpa gelembung, caustics, rays', () {
      expect(VisualConfig.bubblesFor(EffectQuality.minimal), 0);
      expect(VisualConfig.causticsFor(EffectQuality.minimal), isFalse);
      expect(VisualConfig.raysFor(EffectQuality.minimal), isFalse);
    });

    test('parallax gelembung memakai tiga lapis', () {
      expect(VisualConfig.bubbleParallaxLayers, 3);
    });
  });

  group('EffectQuality persistensi', () {
    test(
      'fromName membaca ketiga mode dan default Penuh untuk nilai asing',
      () {
        expect(EffectQuality.fromName('minimal'), EffectQuality.minimal);
        expect(EffectQuality.fromName('hemat'), EffectQuality.hemat);
        expect(EffectQuality.fromName('penuh'), EffectQuality.full);
      },
    );

    test('toJson/fromJson menjaga pilihan minimal', () {
      final s = const AppSettings(effectQuality: EffectQuality.minimal);
      expect(
        AppSettings.fromJson(s.toJson()).effectQuality,
        EffectQuality.minimal,
      );
    });

    testWidgets('memilih Minimal tersimpan lokal', (tester) async {
      final repository = await pumpTerumbuApp(tester, profile: _profile);

      await tester.tap(find.text(AppStrings.navProfile));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.profileQualityMinimal));
      await tester.pumpAndSettle();

      final saved = await repository.loadSettings();
      expect(saved.effectQuality, EffectQuality.minimal);
    });

    testWidgets('animasi sistem mati menampilkan keterangan di setelan', (
      tester,
    ) async {
      // Helper pump memasang disableAnimations, jadi keterangan wajib tampil.
      await pumpTerumbuApp(tester, profile: _profile);
      await tester.tap(find.text(AppStrings.navProfile));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.profileQualityMotionOff), findsOneWidget);
    });

    testWidgets('ganti kualitas tidak menyentuh progres terumbu', (
      tester,
    ) async {
      const progress = Progress(xp: 120, level: 3, totalActions: 8);
      await pumpTerumbuApp(tester, profile: _profile, progress: progress);

      await tester.tap(find.text(AppStrings.navProfile));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.profileQualityMinimal));
      await tester.pumpAndSettle();

      // Progres provider tidak tersentuh: Home masih menampilkan level sama.
      await tester.tap(find.text(AppStrings.navHome));
      await tester.pumpAndSettle();
      expect(find.text('Level 3'), findsOneWidget);
    });
  });
}
