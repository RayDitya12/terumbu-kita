import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Layar Splash/Intro — fase Discovery (spec.md §6.1 layar 1, §4.4 fase 1).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // CD1: narasi makna — masalah laut Indonesia, pengguna diajak jadi bagian
    // solusi, bukan disuruh menuruti imbauan.
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: reefBackgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: AppColors.foam,
                    fontWeight: FontWeight.w800,
                    shadows: const [
                      Shadow(color: AppColors.splashGlow, blurRadius: 24),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.appTagline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.foam.withValues(alpha: 0.7),
                  ),
                ),
                const Spacer(flex: 2),
                Text(
                  AppStrings.splashNarration,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.foam,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                // CD5: sinyal sosial "teman sudah bergabung" (mock).
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.groups_outlined,
                      size: 18,
                      color: AppColors.coral,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.splashJoinHint,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.foam.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 2),
                // Glowing choice pertama: satu tombol terang, aksi jelas.
                FilledButton(
                  onPressed: () => context.go('/onboarding/intro'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.coral,
                    foregroundColor: AppColors.ink,
                  ),
                  child: const Text(AppStrings.splashCta),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
