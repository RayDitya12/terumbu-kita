import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/impact_constants.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/action_log.dart';

/// Dampak (spec.md §6.1 layar 7): counter kumulatif + grafik 7 hari.
/// CD2: angka dampak membuat kemajuan terasa nyata; CD1: padanan sedotan
/// mengaitkan aksi pribadi ke masalah laut.
class ImpactScreen extends ConsumerWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logs = ref.watch(actionLogsProvider);
    final today = ref.watch(clockProvider).today;
    final totalGrams = logs.fold<double>(0, (sum, l) => sum + l.plasticGrams);

    final dailyGrams = [
      for (var i = 6; i >= 0; i--)
        _gramsOn(logs, today.subtract(Duration(days: i))),
    ];
    final hasData = logs.isNotEmpty;
    final maxGrams = dailyGrams.fold<double>(0, (m, g) => g > m ? g : m);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.impactTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Formatters.grams(totalGrams),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.reefGradientBottom,
                    ),
                  ),
                  Text(AppStrings.impactTotalLabel),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.strawEquivalent(
                      ImpactConstants.strawEquivalent(totalGrams),
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.impactWeekLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!hasData)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.eco_outlined,
                            size: 40,
                            color: AppTheme.reefGradientBottom,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.impactNoData,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.impactNoDataHint,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          maxY: maxGrams * 1.25,
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(),
                            topTitles: const AxisTitles(),
                            rightTitles: const AxisTitles(),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  final date = today.subtract(
                                    Duration(days: 6 - value.toInt()),
                                  );
                                  return Text(
                                    Formatters.shortDate(date).split(',').first,
                                    style: theme.textTheme.labelSmall,
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: [
                            for (var i = 0; i < 7; i++)
                              BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: dailyGrams[i],
                                    width: 18,
                                    color: AppTheme.coralAccent,
                                    borderRadius: BorderRadius.circular(6),
                                    // Label angka di atas tiap bar.
                                    label: BarChartRodLabel(
                                      show: dailyGrams[i] > 0,
                                      text: dailyGrams[i].toStringAsFixed(0),
                                      offset: const Offset(0, -10),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.reefGradientBottom,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.share),
            label: const Text(AppStrings.impactShare),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.impactShareMock)),
            ),
          ),
        ],
      ),
    );
  }

  double _gramsOn(List<ActionLog> logs, DateTime day) => logs
      .where((l) => Clock.dateOnly(l.timestamp) == day)
      .fold<double>(0, (sum, l) => sum + l.plasticGrams);
}
