import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/game_rules.dart';
import '../../../core/constants/impact_constants.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/game_logic.dart';

/// Catat Aksi (spec.md §6.1 layar 4).
/// CD2: umpan balik instan; CD3: kebiasaan fokus pengguna direkomendasikan
/// lebih dulu (lanjutan Glowing Choice); CD8: tanpa hukuman, batas harian
/// disampaikan sebagai ajakan, bukan larangan.
class LogActionScreen extends ConsumerStatefulWidget {
  const LogActionScreen({super.key});

  @override
  ConsumerState<LogActionScreen> createState() => _LogActionScreenState();
}

class _LogActionScreenState extends ConsumerState<LogActionScreen> {
  static const _icons = {
    ActionType.tumbler: Icons.local_drink_outlined,
    ActionType.tote: Icons.shopping_bag_outlined,
    ActionType.noStraw: Icons.no_drinks_outlined,
    ActionType.ownContainer: Icons.lunch_dining_outlined,
    ActionType.refill: Icons.water_drop_outlined,
    ActionType.noCutlery: Icons.restaurant_outlined,
  };

  ActionType? _selected;
  bool _photoAttached = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // CD3: kebiasaan yang dipilih di Glowing Choice tampil lebih dulu.
    _selected = ref.read(profileProvider)?.focusHabit;
  }

  Future<void> _submit() async {
    final type = _selected;
    if (type == null || _saving) return;
    setState(() => _saving = true);
    final outcome = await ref.read(progressProvider.notifier).logAction(type);
    if (!mounted) return;
    setState(() => _saving = false);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _WinStateSheet(outcome: outcome),
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.homeLogAction)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.logActionTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.logActionSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.35,
                  children: [
                    for (final type in ActionType.values)
                      _ActionCard(
                        type: type,
                        icon: _icons[type]!,
                        selected: _selected == type,
                        recommended:
                            ref.watch(profileProvider)?.focusHabit == type,
                        onTap: () => setState(() => _selected = type),
                      ),
                  ],
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _photoAttached,
                onChanged: (v) => setState(() => _photoAttached = v),
                title: const Text(
                  AppStrings.logActionPhoto,
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: _photoAttached
                    ? const Text(
                        AppStrings.logActionPhotoNote,
                        style: TextStyle(fontSize: 12),
                      )
                    : null,
              ),
              FilledButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(AppStrings.logActionSubmit),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.coralAccent,
                  foregroundColor: Colors.black87,
                  minimumSize: const Size(0, 56),
                ),
                onPressed: _selected == null || _saving ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.type,
    required this.icon,
    required this.selected,
    required this.recommended,
    required this.onTap,
  });

  final ActionType type;
  final IconData icon;
  final bool selected;
  final bool recommended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: selected ? 4 : 1,
      color: selected
          ? theme.colorScheme.surface
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: selected
            ? const BorderSide(color: AppTheme.coralAccent, width: 3)
            : BorderSide.none,
      ),
      child: InkWell(
        key: Key('action-${type.id}'),
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (recommended)
                const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    AppStrings.logActionRecommended,
                    style: TextStyle(fontSize: 10, color: AppTheme.coralAccent),
                  ),
                ),
              Icon(icon, color: selected ? AppTheme.coralAccent : null),
              const SizedBox(height: 6),
              Text(
                AppStrings.actionLabels[type.id]!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text('+${type.xp} XP', style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animasi Win-State #2 (spec.md §3.3): karang pertama tumbuh + badge.
class _WinStateSheet extends StatelessWidget {
  const _WinStateSheet({required this.outcome});

  final ActionOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = outcome.progress;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.4, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Icon(
                outcome.firstAction ? Icons.eco : Icons.waves,
                size: 64,
                color: AppTheme.coralAccent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.winActionXp(outcome.xpGained),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${Formatters.grams(outcome.grams)} '
              '${AppStrings.winActionImpactLabel}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              Formatters.strawEquivalent(
                ImpactConstants.strawEquivalent(outcome.grams),
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${p.streak} ${AppStrings.winActionStreakLabel} '
              '(Level ${p.level})',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            for (final line in _eventLines()) ...[
              const SizedBox(height: 8),
              Text(
                line,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.healthWarn,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.winActionCta),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _eventLines() => [
    if (outcome.xpGained == 0) AppStrings.winActionCapReached,
    if (outcome.freezeUsed) AppStrings.winActionFreezeNote,
    if (outcome.leveledUp)
      '${AppStrings.winActionLevelUp}${outcome.progress.level}',
    if (outcome.stageUp != null)
      'Terumbu naik tahap: ${AppStrings.reefStageNames[outcome.stageUp!.name]}',
    if (outcome.firstAction) AppStrings.winActionBadgeNewDiver,
  ];
}
