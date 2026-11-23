import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_strings.dart';
import 'core/constants/game_rules.dart';
import 'core/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/community/presentation/community_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/impact/presentation/impact_screen.dart';
import 'features/onboarding/presentation/glowing_choice_screen.dart';
import 'features/onboarding/presentation/intro_slides_screen.dart';
import 'features/onboarding/presentation/profile_setup_screen.dart';
import 'features/onboarding/presentation/splash_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/quests/presentation/quests_screen.dart';
import 'shared/widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Bottom nav: Home · Quest · Dampak · Komunitas · Profil (spec.md §6.3).
/// Alur onboarding (Splash → Intro → Glowing Choice → Profil) berada di
/// luar shell dan dijaga oleh redirect (spec.md §6.2).
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final profile = ref.read(profileProvider);
      final onboarded = profile?.onboardingDone ?? false;
      final loc = state.matchedLocation;
      final onOnboardingPath =
          loc == '/splash' || loc.startsWith('/onboarding');
      if (!onboarded) return onOnboardingPath ? null : '/splash';
      return onOnboardingPath ? '/home' : null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: '/onboarding/intro',
        builder: (_, _) => const IntroSlidesScreen(),
      ),
      GoRoute(
        path: '/onboarding/choice',
        builder: (_, _) => const GlowingChoiceScreen(),
      ),
      GoRoute(
        path: '/onboarding/profile',
        builder: (context, state) => ProfileSetupScreen(
          // Deep link tanpa pilihan: jatuh ke saran default (tumbler).
          focusHabit: state.extra is ActionType
              ? state.extra as ActionType
              : ActionType.tumbler,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/quest', builder: (_, _) => const QuestsScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/impact', builder: (_, _) => const ImpactScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/community',
                builder: (_, _) => const CommunityScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class TerumbuApp extends ConsumerWidget {
  const TerumbuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
