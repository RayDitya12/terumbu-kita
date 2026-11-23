import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';

/// Target radar per Core Drive (spec.md §4.2 — angka desain, bukan hasil
/// ukur). Layar opsional untuk pitch (spec.md §6.1 layar 12).
class OctalysisScreen extends StatelessWidget {
  const OctalysisScreen({super.key});

  static const _labels = [
    'CD1 Meaning',
    'CD2 Achievement',
    'CD3 Empowerment',
    'CD4 Ownership',
    'CD5 Influence',
    'CD6 Scarcity',
    'CD7 Curiosity',
    'CD8 Avoidance',
  ];

  // ASUMSI: target radar spec.md §4.2 (White Hat dominan, Black Hat rendah).
  static const _values = [8.0, 9.0, 7.0, 8.0, 6.0, 4.0, 6.0, 3.0];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.octalysisTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(AppStrings.octalysisIntro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: 320,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                dataSets: [
                  RadarDataSet(
                    dataEntries: [
                      for (final v in _values) RadarEntry(value: v),
                    ],
                    fillColor: AppColors.teal.withValues(alpha: 0.35),
                    borderColor: AppColors.teal,
                    entryRadius: 4,
                  ),
                ],
                getTitle: (index, _) => RadarChartTitle(text: _labels[index]),
                titleTextStyle: theme.textTheme.labelSmall!,
                tickCount: 4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keseimbangan (spec.md §4.3)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'White Hat (CD1-4) dominan: makna, pencapaian, '
                    'kebebasan memilih, dan rasa memiliki.\n'
                    'Black Hat (CD6-8) dipakai hati-hati dan tidak pernah '
                    'menghukum: karang hanya memudar, bisa pulih dengan '
                    'satu aksi.',
                    style: theme.textTheme.bodyMedium,
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
