const int kBackupVersion = 1;

class BackupData {
  final int version;
  final String exportedAt;
  final List<Map<String, dynamic>> coffeePrices;
  final List<Map<String, dynamic>> customers;
  final Map<String, dynamic> settings;

  const BackupData({
    required this.version,
    required this.exportedAt,
    required this.coffeePrices,
    required this.customers,
    required this.settings,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'version': version,
        'exportedAt': exportedAt,
        'coffeePrices': coffeePrices,
        'customers': customers,
        'settings': settings,
      };

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      version: (json['version'] as num?)?.toInt() ?? 0,
      exportedAt: json['exportedAt']?.toString() ?? '',
      coffeePrices: _toMapList(json['coffeePrices']),
      customers: _toMapList(json['customers']),
      settings: json['settings'] is Map
          ? Map<String, dynamic>.from(json['settings'] as Map)
          : const <String, dynamic>{},
    );
  }

  static List<Map<String, dynamic>> _toMapList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }
}
