import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/sea_app_bar.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/game_logic.dart';
import '../../../data/models/app_settings.dart';

/// Profil & Pengaturan + Demo Mode (spec.md §6.1 layar 11, §8).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileProvider);
    final progress = ref.watch(progressProvider);
    final settings = ref.watch(settingsProvider);
    final badges = ref.watch(collectionProvider).badges.toSet();
    final title = userTitle(level: progress.level, badges: badges);

    Future<void> advance(int days) async {
      final next = settings.copyWith(
        // Offset tidak pernah negatif: mundur dibatasi sampai hari asli.
        simulatedDateOffsetDays: math.max(
          0,
          settings.simulatedDateOffsetDays + days,
        ),
      );
      await ref.read(settingsProvider.notifier).update(next);
      // CD8: geser tanggal Demo Mode menghitung ulang memudarnya karang,
      // termasuk memulihkan warna saat mundur ke hari terakhir ada aksi.
      await ref
          .read(progressProvider.notifier)
          .applyDecay(ref.read(clockProvider).today);
    }

    return Scaffold(
      appBar: SeaAppBar(title: AppStrings.profileScreenTitle),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.teal,
                child: Text(
                  (profile?.nickname ?? '?').characters.first,
                  style: const TextStyle(color: AppColors.foam, fontSize: 24),
                ),
              ),
              title: Text(
                profile?.nickname ?? '',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                '${AppStrings.profileTitleLabel}: $title · '
                '${AppStrings.homeLevel} ${progress.level}',
              ),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: settings.notificationsEnabled,
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .update(settings.copyWith(notificationsEnabled: v)),
            title: const Text(
              AppStrings.profileNotifications,
              style: TextStyle(fontSize: 14),
            ),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.collections),
            label: const Text(AppStrings.profileCollectionLink),
            onPressed: () => context.push('/collection'),
          ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            icon: const Icon(Icons.card_giftcard),
            label: const Text(AppStrings.profileRewardsLink),
            onPressed: () => context.push('/rewards'),
          ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            icon: const Icon(Icons.sports_esports),
            label: const Text(AppStrings.miniGameTitle),
            onPressed: () => context.push('/minigame'),
          ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            icon: const Icon(Icons.insights),
            label: const Text(AppStrings.octalysisTitle),
            onPressed: () => context.push('/octalysis'),
          ),
          const SizedBox(height: 16),
          // Unit B: setelan kualitas efek terumbu, disimpan lokal.
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.profileQualityTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SegmentedButton<EffectQuality>(
                        showSelectedIcon: false,
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        segments: const [
                          ButtonSegment(
                            value: EffectQuality.full,
                            label: Text(AppStrings.profileQualityFull),
                          ),
                          ButtonSegment(
                            value: EffectQuality.hemat,
                            label: Text(AppStrings.profileQualityHemat),
                          ),
                        ],
                        selected: {settings.effectQuality},
                        onSelectionChanged: (selection) => ref
                            .read(settingsProvider.notifier)
                            .update(
                              settings.copyWith(effectQuality: selection.first),
                            ),
                      ),
                    ],
                  ),
                  Text(
                    AppStrings.profileQualityHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: AppColors.amberTint,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.science_outlined,
                        color: AppColors.amberInk,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.demoModeTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    AppStrings.demoModeSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    '${AppStrings.demoOffsetLabel}'
                    '${settings.simulatedDateOffsetDays}'
                    '${AppStrings.demoOffsetDays}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonal(
                        onPressed: () => advance(1),
                        child: const Text(AppStrings.demoAdvance1),
                      ),
                      FilledButton.tonal(
                        onPressed: () => advance(7),
                        child: const Text(AppStrings.demoAdvance7),
                      ),
                      FilledButton.tonal(
                        onPressed: () => advance(-1),
                        child: const Text(AppStrings.demoBack1),
                      ),
                      FilledButton.tonal(
                        onPressed: () => advance(-7),
                        child: const Text(AppStrings.demoBack7),
                      ),
                      FilledButton.tonal(
                        onPressed: () => ref
                            .read(progressProvider.notifier)
                            .loadSampleData(),
                        child: const Text(AppStrings.demoSampleData),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.sunYellow,
                          foregroundColor: AppColors.ink,
                        ),
                        onPressed: () async {
                          await ref.read(progressProvider.notifier).resetAll();
                          if (context.mounted) context.go('/splash');
                        },
                        child: const Text(AppStrings.demoReset),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
