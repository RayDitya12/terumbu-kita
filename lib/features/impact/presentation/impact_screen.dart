import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/feature_placeholder.dart';

class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context) => const FeaturePlaceholder(
    title: AppStrings.navImpact,
    stageNote: 'Grafik dampak mingguan dibangun di Tahap 4.',
  );
}
