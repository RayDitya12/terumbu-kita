import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/game_rules.dart';
import '../../../core/theme/app_theme.dart';

/// Glowing Choice — layar inti onboarding (spec.md §3.4.1).
/// Hanya 4 kartu besar, opsi yang disarankan sudah terpilih dan menyala,
/// tidak ada formulir dan tidak ada jalan buntu. CD3 (Empowerment of
/// Creativity): pengguna memilih fokusnya sendiri, bukan disetel aplikasi.
class GlowingChoiceScreen extends StatefulWidget {
  const GlowingChoiceScreen({super.key});

  @override
  State<GlowingChoiceScreen> createState() => _GlowingChoiceScreenState();
}

class _GlowingChoiceScreenState extends State<GlowingChoiceScreen> {
  static const _recommended = ActionType.tumbler;
  static const _choices = [
    ActionType.tumbler,
    ActionType.tote,
    ActionType.noStraw,
    ActionType.ownContainer,
  ];

  /// Terpilih sejak awal: Glowing Choice tidak boleh "bingung harus apa".
  ActionType _selected = _recommended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.choicePrompt,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: _choices.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final choice = _choices[index];
                    return _HabitCard(
                      choice: choice,
                      selected: choice == _selected,
                      recommended: choice == _recommended,
                      onTap: () => setState(() => _selected = choice),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    context.go('/onboarding/profile', extra: _selected),
                child: const Text(AppStrings.choiceConfirm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.choice,
    required this.selected,
    required this.recommended,
    required this.onTap,
  });

  final ActionType choice;
  final bool selected;
  final bool recommended;
  final VoidCallback onTap;

  static const _icons = {
    ActionType.tumbler: Icons.local_cafe,
    ActionType.tote: Icons.shopping_bag,
    ActionType.noStraw: Icons.no_drinks,
    ActionType.ownContainer: Icons.lunch_dining,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = selected
        ? theme.colorScheme.primary
        : Colors.transparent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: selected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.55)
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: selected ? 2.5 : 0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                ),
                child: Icon(
                  _icons[choice],
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.habitLabels[choice.id]!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.habitDescriptions[choice.id]!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (recommended) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.coralAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          AppStrings.choiceRecommended,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
