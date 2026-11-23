import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/game_rules.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/game_logic.dart';
import '../../../data/models/progress.dart';
import '../../../data/models/user_profile.dart';
import '../../../shared/widgets/reef_scene.dart';

/// Home (Terumbu) — spec.md §6.1 layar 3.
/// Tahap 2: visual statis; angka XP/streak/dampak sudah terhubung ke
/// provider agar Tahap 3 tinggal mengisi logikanya.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Win-State #1: tampilkan dialog "terumbu lahir" sekali setelah
    // onboarding selesai (spec.md §3.3).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(profileProvider.notifier);
      if (notifier.winStatePending) {
        notifier.consumeWinState();
        _showReefBornDialog();
      }
    });
  }

  void _showReefBornDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              const Icon(Icons.waves, color: AppColors.coral),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppStrings.winReefBornTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Text(AppStrings.winReefBornBody),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AppStrings.winReefBornCta),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileProvider);
    final progress = ref.watch(progressProvider);
    final totalGrams = ref
        .watch(actionLogsProvider)
        .fold<double>(0, (sum, log) => sum + log.plasticGrams);
    final stage = reefStageFor(progress.totalActions);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(gradient: reefBackgroundGradient),
          ),
          // Area terumbu: dari bawah judul sampai tepat di atas kartu ringkasan.
          Positioned(
            left: 0,
            right: 0,
            bottom: 268,
            top: MediaQuery.sizeOf(context).height * 0.16,
            child: const ReefScene(),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderRow(profile: profile, stage: stage),
                  const Spacer(),
                  _ReefSummaryCard(
                    progress: progress,
                    totalGrams: totalGrams,
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  // Tombol jempol paling bawah: aksi utama paling dekat.
                  FilledButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text(AppStrings.homeLogAction),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.coral,
                      foregroundColor: AppColors.ink,
                      minimumSize: const Size(0, 60),
                    ),
                    onPressed: () => context.push('/log-action'),
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

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.profile, required this.stage});

  final UserProfile? profile;
  final ReefStage stage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            '${AppStrings.homeGreetingPrefix} ${profile?.nickname ?? ''}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.foam,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.foam.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            AppStrings.reefStageNames[stage.name]!,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.foam,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReefSummaryCard extends StatelessWidget {
  const _ReefSummaryCard({
    required this.progress,
    required this.totalGrams,
    required this.theme,
  });

  final Progress progress;
  final double totalGrams;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final xpNeeded = GameRules.xpNeededForLevel(progress.level);
    final nextStageActions = actionsUntilNextReefStage(progress.totalActions);
    return Card(
      color: theme.colorScheme.surface.withValues(alpha: 0.94),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${AppStrings.homeLevel} ${progress.level}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${progress.xp} / $xpNeeded XP',
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (progress.xp / xpNeeded).clamp(0.0, 1.0),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // CD8 dengan nada ajakan, bukan ancaman.
                Icon(
                  progress.streak > 0
                      ? Icons.local_fire_department
                      : Icons.local_fire_department_outlined,
                  size: 18,
                  color: AppColors.sunYellow,
                ),
                const SizedBox(width: 6),
                Text(
                  '${progress.streak} ${AppStrings.homeStreakDays}',
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  '${Formatters.grams(totalGrams)} '
                  '${AppStrings.homeImpactCompact}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            if (nextStageActions != null) ...[
              const SizedBox(height: 10),
              Text(
                Formatters.nextReefStageHint(nextStageActions),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
