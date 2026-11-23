import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';

/// Hadiah voucher mock (spec.md §6.1 layar 10).
/// CD6: kuota terbatas + label "simulasi" — tidak pernah menjanjikan
/// hadiah nyata (agent.md §8).
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rewards = ref.watch(rewardsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.rewardsTitle)),
      body: rewards.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(AppStrings.impactNoData)),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final voucher in data.vouchers)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.confirmation_number,
                            color: AppColors.coralInk,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              voucher.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(voucher.partner),
                      const SizedBox(height: 4),
                      Text(voucher.condition, style: theme.textTheme.bodySmall),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: voucher.quotaTotal == 0
                            ? 0
                            : voucher.quotaLeft / voucher.quotaTotal,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${voucher.quotaLeft}/${voucher.quotaTotal} '
                              '${AppStrings.rewardsQuotaLabel}',
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                          FilledButton(
                            onPressed: () => ScaffoldMessenger.of(context)
                                .showSnackBar(
                                  const SnackBar(
                                    content: Text(AppStrings.rewardsRedeemMock),
                                  ),
                                ),
                            child: const Text(AppStrings.rewardsRedeem),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              data.disclaimer,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
