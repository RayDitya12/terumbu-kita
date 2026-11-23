import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';

/// Koleksi pengguna (spec.md §6.1 layar 8): spesies, dekorasi, badge.
/// CD4: rasa memiliki; spesies terbuka bertahap lewat total aksi.
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final species = ref.watch(speciesProvider);
    final totalActions = ref.watch(progressProvider).totalActions;
    final collection = ref.watch(collectionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.collectionTitle)),
      body: species.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(AppStrings.impactNoData)),
        data: (all) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionTitle(AppStrings.collectionSpecies),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final s in all)
                  _SpeciesTile(
                    name: s.name,
                    rarity: s.rarity,
                    unlocked: totalActions >= s.minActions,
                    hint:
                        AppStrings.collectionSpeciesHint +
                        '${s.minActions}' +
                        AppStrings.collectionSpeciesHintSuffix,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionTitle(AppStrings.collectionDecorations),
            Text(
              '${collection.decorationsOwned.length} dekorasi tersimpan '
              '(dari Mystery Chest).',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _SectionTitle(AppStrings.collectionBadges),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final id in collection.badges)
                  Chip(
                    avatar: const Icon(
                      Icons.workspace_premium,
                      color: AppTheme.coralAccent,
                    ),
                    label: Text(AppStrings.badgeNames[id] ?? id),
                  ),
              ],
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

class _SpeciesTile extends StatelessWidget {
  const _SpeciesTile({
    required this.name,
    required this.rarity,
    required this.unlocked,
    required this.hint,
  });

  final String name;
  final String rarity;
  final bool unlocked;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked
            ? AppTheme.coralAccent.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            unlocked ? Icons.eco : Icons.lock_outline,
            color: unlocked ? AppTheme.reefGradientBottom : null,
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            unlocked ? rarity : '${AppStrings.collectionLocked} · $hint',
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
