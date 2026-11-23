import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Pita header gradien tipis (deep ocean → teal) untuk layar non-Home.
/// Home tetap imersif tanpa pita (unit tema, spec.md §9).
class SeaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SeaAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: seaHeaderGradient),
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.foam,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Text(title),
      actions: actions,
    );
  }
}
