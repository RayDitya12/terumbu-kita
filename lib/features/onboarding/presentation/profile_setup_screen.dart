import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/game_rules.dart';
import '../../../core/providers.dart';
import '../../../data/models/user_profile.dart';

/// Langkah terakhir onboarding: nama panggilan + avatar (spec.md §6.1).
/// Tetap satu layar kecil — total input hanya dua ketikan (prinsip
/// Glowing Choice, agent.md §3).
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key, required this.focusHabit});

  final ActionType focusHabit;

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  static const _avatars = [
    Icons.emoji_nature_outlined,
    Icons.pets,
    Icons.waves,
    Icons.local_florist,
  ];

  final _nicknameController = TextEditingController();
  int _avatarIndex = 0;
  bool _saving = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final nickname = _nicknameController.text.trim();
    final profile = UserProfile(
      nickname: nickname.isEmpty ? 'Penyelam' : nickname,
      avatarId: _avatarIndex,
      focusHabit: widget.focusHabit,
      onboardingDone: true,
      createdAt: ref.read(clockProvider).now,
    );
    await ref.read(profileProvider.notifier).completeOnboarding(profile);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.profileTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                key: const Key('nickname-field'),
                controller: _nicknameController,
                maxLength: 20,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: AppStrings.profileNicknameLabel,
                  hintText: AppStrings.profileNicknameHint,
                  border: const OutlineInputBorder(),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.profileAvatarLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < _avatars.length; i++)
                    KeyedSubtree(
                      key: ValueKey('avatar-$i'),
                      child: _AvatarOption(
                        icon: _avatars[i],
                        selected: i == _avatarIndex,
                        onTap: () => setState(() => _avatarIndex = i),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              FilledButton(
                onPressed: _saving ? null : _finish,
                child: const Text(AppStrings.profileDone),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerLow,
          border: Border.all(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            width: 3,
          ),
        ),
        child: Icon(
          icon,
          size: 30,
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
