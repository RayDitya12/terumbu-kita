/// Pembaca JSON toleran: nilai bertipe salah dianggap tidak ada (spec.md §9:
/// tidak crash saat data korup).
library;

String asString(Map<String, dynamic> json, String key, {String fallback = ''}) {
  final value = json[key];
  return value is String ? value : fallback;
}

int asInt(Map<String, dynamic> json, String key, {int fallback = 0}) {
  final value = json[key];
  return value is num ? value.toInt() : fallback;
}

double asDouble(Map<String, dynamic> json, String key, {double fallback = 0}) {
  final value = json[key];
  return value is num ? value.toDouble() : fallback;
}

bool asBool(Map<String, dynamic> json, String key, {bool fallback = false}) {
  final value = json[key];
  return value is bool ? value : fallback;
}

DateTime? asDate(Map<String, dynamic> json, String key) =>
    DateTime.tryParse(asString(json, key));

DateTime asDateOr(Map<String, dynamic> json, String key, DateTime fallback) =>
    asDate(json, key) ?? fallback;
