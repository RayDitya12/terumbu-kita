import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/feature_placeholder.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => const FeaturePlaceholder(
    title: AppStrings.navProfile,
    stageNote: 'Profil, Demo Mode, dan reset data dibangun di Tahap 5.',
  );
}
