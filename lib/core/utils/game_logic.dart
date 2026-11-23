import '../constants/game_rules.dart';

/// Fungsi murni logika game — terpisah dari UI agar mudah diuji
/// (agent.md §4). Tahap terumbu dihitung dari total aksi (spec.md §7.2).
///
/// CD2 + CD4: progres terumbu adalah feedback pencapaian milik pribadi.
ReefStage reefStageFor(int totalActions) {
  var stage = ReefStage.tunas;
  for (final candidate in ReefStage.values) {
    if (totalActions >= candidate.minActions) stage = candidate;
  }
  return stage;
}

/// Jumlah aksi menuju tahap terumbu berikutnya; null jika sudah maksimum.
int? actionsUntilNextReefStage(int totalActions) {
  final current = reefStageFor(totalActions);
  final nextIndex = ReefStage.values.indexOf(current) + 1;
  if (nextIndex >= ReefStage.values.length) return null;
  return ReefStage.values[nextIndex].minActions - totalActions;
}
