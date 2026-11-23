import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/feature_placeholder.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) => const FeaturePlaceholder(
    title: AppStrings.navCommunity,
    stageNote: AppStrings.placeholderCommunity,
  );
}
