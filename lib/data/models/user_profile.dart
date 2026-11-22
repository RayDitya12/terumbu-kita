import '../../core/constants/game_rules.dart';
import 'json_utils.dart';

/// Profil pengguna (spec.md §7.3).
class UserProfile {
  const UserProfile({
    required this.nickname,
    required this.avatarId,
    required this.focusHabit,
    required this.onboardingDone,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    nickname: asString(json, 'nickname'),
    avatarId: asInt(json, 'avatarId'),
    focusHabit: ActionType.fromId(asString(json, 'focusHabit')),
    onboardingDone: asBool(json, 'onboardingDone'),
    createdAt: asDateOr(json, 'createdAt', DateTime(2026)),
  );

  final String nickname;
  final int avatarId;

  /// Kebiasaan yang dipilih lewat Glowing Choice saat onboarding (spec.md §3.4.1).
  /// CD3: pengguna memilih sendiri fokusnya (Empowerment of Creativity).
  final ActionType? focusHabit;
  final bool onboardingDone;
  final DateTime createdAt;

  UserProfile copyWith({
    String? nickname,
    int? avatarId,
    ActionType? focusHabit,
    bool? onboardingDone,
  }) => UserProfile(
    nickname: nickname ?? this.nickname,
    avatarId: avatarId ?? this.avatarId,
    focusHabit: focusHabit ?? this.focusHabit,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'nickname': nickname,
    'avatarId': avatarId,
    'focusHabit': focusHabit?.id,
    'onboardingDone': onboardingDone,
    'createdAt': createdAt.toIso8601String(),
  };
}
