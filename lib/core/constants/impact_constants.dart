/// Konversi item plastik sekali pakai yang dihindari menjadi gram.
///
/// SEMUA angka di file ini adalah placeholder desain (spec.md §7.1):
/// tim harus mengganti dengan angka bersumber dan mencantumkan sitasinya
/// di laporan. Jangan menampilkan angka ini sebagai fakta nasional.
library;

abstract final class ImpactConstants {
  // ASUMSI: perlu sumber — berat 1 kantong belanja plastik kresek.
  static const double gramsPerShoppingBag = 8;

  // ASUMSI: perlu sumber — berat 1 sedotan plastik.
  static const double gramsPerStraw = 1;

  // ASUMSI: perlu sumber — berat 1 gelas plastik + tutup.
  static const double gramsPerCup = 30;

  // ASUMSI: perlu sumber — berat 1 botol plastik PET 600 ml.
  static const double gramsPerBottle = 30;

  // ASUMSI: perlu sumber — berat 1 wadah makan styrofoam/plastik.
  static const double gramsPerFoodContainer = 50;

  // ASUMSI: perlu sumber — berat 1 set sendok-garpu plastik + tisu basah.
  static const double gramsPerCutlerySet = 12;

  /// Gram plastik dihindari per jenis aksi, pemetaan 1 item = 1 aksi.
  static const Map<String, double> gramsByActionId = {
    'tumbler': gramsPerCup, // ASUMSI: 1 aksi ≈ 1 gelas/botol (spec.md §7.1)
    'tote': gramsPerShoppingBag,
    'no_straw': gramsPerStraw,
    'own_container': gramsPerFoodContainer,
    'refill': gramsPerBottle,
    'no_cutlery': gramsPerCutlerySet,
  };

  /// Padanan untuk ditampilkan, mis. "≈ 12 sedotan" (spec.md §3.4).
  static const double referenceItemGrams = gramsPerStraw;

  static double gramsFor(String actionId) => gramsByActionId[actionId] ?? 0;

  static int strawEquivalent(double totalGrams) =>
      (totalGrams / referenceItemGrams).round();
}
