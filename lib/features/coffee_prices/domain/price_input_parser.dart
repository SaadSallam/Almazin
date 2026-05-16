/// Parses user-entered decimal prices (Arabic/Latin separators).
abstract final class PriceInputParser {
  static double? tryParse(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return null;

    s = s.replaceAll('٬', '').replaceAll(',', '.').replaceAll('٫', '.').replaceAll(' ', '');

    return double.tryParse(s);
  }
}
