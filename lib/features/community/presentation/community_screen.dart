import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

/// Komunitas (spec.md §6.1 layar 9) — semua data mock (spec.md §7.4).
/// CD5: peringkat & tim; CD1: counter kolektif.
class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final community = ref.watch(communityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.communityTitle)),
      body: community.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(AppStrings.impactNoData)),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: AppTheme.seaTint,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.grams(data.nationalCounterGrams.toDouble()),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.reefGradientBottom,
                      ),
                    ),
                    Text(
                      '${AppStrings.communityNationalLabel} · ${data.joinHint}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SectionTitle(AppStrings.communityLeaderboard),
            for (final entry in data.leaderboard)
              ListTile(
                leading: CircleAvatar(child: Text(entry.name.characters.first)),
                title: Text(entry.name),
                trailing: Text('${entry.xp} XP'),
              ),
            const SizedBox(height: 12),
            _SectionTitle(AppStrings.communityTeams),
            for (final team in data.teams)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.groups),
                  title: Text(team.name),
                  subtitle: Text(
                    '${team.memberCount} anggota · '
                    '${team.weeklyContribution} aksi minggu ini',
                  ),
                ),
              ),
            const SizedBox(height: 12),
            _SectionTitle(AppStrings.communityChallenges),
            Card(
              child: ListTile(
                leading: const Icon(Icons.flag, color: AppTheme.coralAccent),
                title: const Text(AppStrings.communityChallengeBody),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.card_giftcard),
              label: const Text(AppStrings.communityRewardsLink),
              onPressed: () => context.push('/rewards'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.w800),
    ),
  );
}
