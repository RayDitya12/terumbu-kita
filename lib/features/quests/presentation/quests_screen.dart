import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/feature_placeholder.dart';

class QuestsScreen extends StatelessWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context) => const FeaturePlaceholder(
    title: AppStrings.navQuest,
    stageNote: 'Daily Quest & Mystery Chest dibangun di Tahap 4.',
  );
}
