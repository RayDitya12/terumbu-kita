import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/game_rules.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/chest.dart';
import '../../../core/utils/clock.dart';
import '../../../data/models/quest.dart';

/// Quest harian + target mingguan + Mystery Chest (spec.md §6.1 layar 5).
/// CD7: chest sebagai elemen kejutan; CD2: progres misi terlihat.
class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key});

  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends ConsumerState<QuestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final today = ref.read(clockProvider).today;
      ref.read(questsProvider.notifier).ensureDailyQuest(today);
    });
  }

  Future<void> _openChest() async {
    final today = ref.read(clockProvider).today;
    final reward = await ref.read(questsProvider.notifier).openChest(today);
    if (!mounted || reward == null) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.chestRewardTitle),
        content: Text(_rewardText(reward)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  String _rewardText(ChestReward reward) => switch (reward.type) {
    ChestRewardType.xp => '${reward.value} ${AppStrings.chestRewardXp}',
    ChestRewardType.freeze => AppStrings.chestRewardFreeze,
    ChestRewardType.decoration => AppStrings.chestRewardDecoration,
    ChestRewardType.fact => '${AppStrings.chestRewardFact} #${reward.value}',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = ref.watch(clockProvider).today;
    final quests = ref.watch(questsProvider);
    final daily = quests
        .where((q) => q.date == today && q.id.startsWith('daily-'))
        .firstOrNull;
    final logs = ref.watch(actionLogsProvider);
    final weekStart = Clock.dateOnly(today)
        .subtract(Duration(days: today.weekday - 1));
    final weeklyCount = logs
        .where(
          (l) =>
              Clock.dateOnly(l.timestamp)
                  .isAfter(weekStart.subtract(const Duration(days: 1))),
        )
        .length;
    final chestToday = ref.watch(settingsProvider).lastChestDate;
    final chestOpenable =
        daily?.completed == true &&
        (chestToday == null || Clock.dateOnly(chestToday) != today);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.questTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DailyQuestCard(daily: daily),
          const SizedBox(height: 12),
          _WeeklyCard(count: weeklyCount),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.card_giftcard,
                        color: AppTheme.coralAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mystery Chest',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (chestOpenable)
                    FilledButton.icon(
                      icon: const Icon(Icons.bolt),
                      label: const Text(AppStrings.chestOpen),
                      onPressed: _openChest,
                    )
                  else if (daily?.completed == true)
                    Text(
                      AppStrings.chestOpenedToday,
                      style: theme.textTheme.bodyMedium,
                    )
                  else
                    Text(
                      AppStrings.chestLockedHint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // CD6: event musiman (banner simulasi) + pintu mini-game (CD7).
          Card(
            color: AppTheme.coralAccent.withValues(alpha: 0.10),
            child: ListTile(
              leading: const Icon(Icons.local_activity),
              title: const Text(AppStrings.eventTitle),
              subtitle: const Text(AppStrings.eventBody),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/minigame'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyQuestCard extends StatelessWidget {
  const _DailyQuestCard({required this.daily});

  final Quest? daily;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quest = daily;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quest?.title ?? 'Misi harian hari ini',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: quest == null
                    ? 0
                    : (quest.progress / quest.targetCount).clamp(0.0, 1.0),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              quest == null
                  ? AppStrings.questDailyReward
                  : quest.completed
                  ? AppStrings.questCompleted
                  : '${quest.progress}/${quest.targetCount} '
                        '${AppStrings.questProgressFormat} · '
                        '${AppStrings.questDailyReward}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  const _WeeklyCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = count >= GameRules.weeklyActionTarget;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.questWeeklyTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              done
                  ? AppStrings.questWeeklyDone
                  : '${AppStrings.questWeeklyBody} ($count/'
                        '${GameRules.weeklyActionTarget})',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
