/// Koleksi pengguna: spesies karang, dekorasi, badge (spec.md §7.3).
/// CD4: rasa memiliki lewat koleksi yang terus bertambah.
class Collection {
  const Collection({
    this.speciesUnlocked = const [],
    this.decorationsOwned = const [],
    this.badges = const [],
  });

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
    speciesUnlocked: _stringList(json['speciesUnlocked']),
    decorationsOwned: _stringList(json['decorationsOwned']),
    badges: _stringList(json['badges']),
  );

  final List<String> speciesUnlocked;
  final List<String> decorationsOwned;
  final List<String> badges;

  Collection copyWith({
    List<String>? speciesUnlocked,
    List<String>? decorationsOwned,
    List<String>? badges,
  }) => Collection(
    speciesUnlocked: speciesUnlocked ?? this.speciesUnlocked,
    decorationsOwned: decorationsOwned ?? this.decorationsOwned,
    badges: badges ?? this.badges,
  );

  Map<String, dynamic> toJson() => {
    'speciesUnlocked': speciesUnlocked,
    'decorationsOwned': decorationsOwned,
    'badges': badges,
  };

  static List<String> _stringList(Object? value) => value is List
      ? value.whereType<String>().toList(growable: false)
      : const [];
}
