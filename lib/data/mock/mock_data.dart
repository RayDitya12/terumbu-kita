import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/utils/game_logic.dart';

/// Model ringan untuk data mock (spec.md §7.4) dan loader JSON aset.
///
/// Data ini hanya untuk demo: komunitas, voucher, dan spesies tidak nyata
/// (agent.md §8: semua hadiah berlabel simulasi).
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.name,
    required this.xp,
    required this.avatarId,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        name: json['name'] as String? ?? '',
        xp: json['xp'] as int? ?? 0,
        avatarId: json['avatarId'] as int? ?? 0,
      );

  final String name;
  final int xp;
  final int avatarId;
}

class TeamInfo {
  const TeamInfo({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.weeklyContribution,
  });

  factory TeamInfo.fromJson(Map<String, dynamic> json) => TeamInfo(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    memberCount: json['memberCount'] as int? ?? 0,
    weeklyContribution: json['weeklyContribution'] as int? ?? 0,
  );

  final String id;
  final String name;
  final int memberCount;
  final int weeklyContribution;
}

class CommunityData {
  const CommunityData({
    required this.campus,
    required this.leaderboard,
    required this.teams,
    required this.nationalCounterGrams,
    required this.joinHint,
  });

  factory CommunityData.fromJson(Map<String, dynamic> json) => CommunityData(
    campus: json['campus'] as String? ?? '',
    leaderboard: parseList(json['leaderboard'], LeaderboardEntry.fromJson),
    teams: parseList(json['teams'], TeamInfo.fromJson),
    nationalCounterGrams: (json['nationalCounterGrams'] as num?)?.toInt() ?? 0,
    joinHint: json['joinHint'] as String? ?? '',
  );

  final String campus;

  /// CD5: peringkat teman/kampus (mock) memicu pengaruh sosial.
  final List<LeaderboardEntry> leaderboard;
  final List<TeamInfo> teams;

  /// CD1: counter kolektif "seluruh pengguna" (mock).
  final int nationalCounterGrams;
  final String joinHint;
}

class Voucher {
  const Voucher({
    required this.id,
    required this.title,
    required this.partner,
    required this.condition,
    required this.quotaTotal,
    required this.quotaLeft,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) => Voucher(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    partner: json['partner'] as String? ?? '',
    condition: json['condition'] as String? ?? '',
    quotaTotal: json['quotaTotal'] as int? ?? 0,
    quotaLeft: json['quotaLeft'] as int? ?? 0,
  );

  final String id;
  final String title;
  final String partner;
  final String condition;

  /// CD6: kuota terbatas (mock) — selalu berlabel simulasi.
  final int quotaTotal;
  final int quotaLeft;
}

class RewardData {
  const RewardData({required this.vouchers, required this.disclaimer});

  factory RewardData.fromJson(Map<String, dynamic> json) => RewardData(
    vouchers: parseList(json['vouchers'], Voucher.fromJson),
    disclaimer: json['disclaimer'] as String? ?? '',
  );

  final List<Voucher> vouchers;
  final String disclaimer;
}

class ImpactFact {
  const ImpactFact({required this.text, required this.source});

  factory ImpactFact.fromJson(Map<String, dynamic> json) => ImpactFact(
    text: json['text'] as String? ?? '',
    source: json['source'] as String? ?? '',
  );

  final String text;
  final String source;
}

class CoralSpecies implements SpeciesThreshold {
  const CoralSpecies({
    required this.id,
    required this.name,
    required this.rarity,
    required this.minActions,
  });

  factory CoralSpecies.fromJson(Map<String, dynamic> json) => CoralSpecies(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    rarity: json['rarity'] as String? ?? 'umum',
    minActions: json['minActions'] as int? ?? 0,
  );

  final String id;
  final String name;

  /// "umum" | "langka" | "musiman" — musiman melayani CD6.
  final String rarity;
  final int minActions;
}

typedef JsonReader = Future<String> Function(String path);

class MockDataLoader {
  const MockDataLoader({JsonReader? reader})
    : _reader = reader ?? _rootBundleRead;

  final Future<String> Function(String path) _reader;

  static Future<String> _rootBundleRead(String path) =>
      rootBundle.loadString(path);

  Future<CommunityData> loadCommunity() async =>
      CommunityData.fromJson(await _readMap('assets/mock/community.json'));

  Future<RewardData> loadRewards() async =>
      RewardData.fromJson(await _readMap('assets/mock/rewards.json'));

  Future<List<ImpactFact>> loadFacts() async => parseList(
    (await _readMap('assets/mock/facts.json'))['facts'],
    ImpactFact.fromJson,
  );

  Future<List<CoralSpecies>> loadSpecies() async => parseList(
    (await _readMap('assets/mock/species.json'))['species'],
    CoralSpecies.fromJson,
  );

  Future<Map<String, dynamic>> _readMap(String path) async {
    try {
      final decoded = jsonDecode(await _reader(path));
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on Object {
      return const {};
    }
  }
}

List<T> parseList<T>(Object? value, T Function(Map<String, dynamic>) parse) =>
    value is List
    ? value.whereType<Map<String, dynamic>>().map(parse).toList(growable: false)
    : const [];
