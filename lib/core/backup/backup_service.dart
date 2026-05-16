import 'dart:convert';

import 'package:hive/hive.dart';

import 'backup_data.dart';

class BackupService {
  BackupService({
    required Box<dynamic> dataBox,
    required Box<dynamic> settingsBox,
  })  : _dataBox = dataBox,
        _settingsBox = settingsBox;

  final Box<dynamic> _dataBox;
  final Box<dynamic> _settingsBox;

  Future<String> exportBackup() async {
    final coffeeRaw = _dataBox.get('coffee_types_v1');
    final customersRaw = _dataBox.get('customers_v1');
    final themePref = _settingsBox.get('theme_preference');

    final data = BackupData(
      version: kBackupVersion,
      exportedAt: DateTime.now().toUtc().toIso8601String(),
      coffeePrices: _decodeList(coffeeRaw),
      customers: _decodeList(customersRaw),
      settings: <String, dynamic>{'themePreference': themePref},
    );

    return const JsonEncoder.withIndent('  ').convert(data.toJson());
  }

  Future<BackupValidationResult> importBackup(String jsonString) async {
    try {
      final parsed = jsonDecode(jsonString);
      if (parsed is! Map) {
        return BackupValidationResult.error('الملف غير صالح: التنسيق غير صحيح');
      }

      final data = BackupData.fromJson(parsed as Map<String, dynamic>);

      final error = _validate(data);
      if (error != null) {
        return BackupValidationResult.error(error);
      }

      if (data.coffeePrices.isNotEmpty) {
        await _dataBox.put('coffee_types_v1', jsonEncode(data.coffeePrices));
      }
      if (data.customers.isNotEmpty) {
        await _dataBox.put('customers_v1', jsonEncode(data.customers));
      }
      final theme = data.settings['themePreference'];
      if (theme is String) {
        await _settingsBox.put('theme_preference', theme);
      }

      return BackupValidationResult.success(BackupImportSummary(
        coffeeCount: data.coffeePrices.length,
        customerCount: data.customers.length,
      ));
    } on FormatException {
      return BackupValidationResult.error('الملف غير صالح: صيغة JSON غير صحيحة');
    } catch (e) {
      return BackupValidationResult.error('حدث خطأ أثناء الاستيراد: $e');
    }
  }

  BackupValidationResult validate(String jsonString) {
    try {
      final parsed = jsonDecode(jsonString);
      if (parsed is! Map) {
        return BackupValidationResult.error('الملف غير صالح: التنسيق غير صحيح');
      }
      final data = BackupData.fromJson(parsed as Map<String, dynamic>);
      final error = _validate(data);
      if (error != null) return BackupValidationResult.error(error);
      return BackupValidationResult.success(BackupImportSummary(
        coffeeCount: data.coffeePrices.length,
        customerCount: data.customers.length,
      ));
    } on FormatException {
      return BackupValidationResult.error('الملف غير صالح: صيغة JSON غير صحيحة');
    } catch (e) {
      return BackupValidationResult.error('حدث خطأ: $e');
    }
  }

  String? _validate(BackupData data) {
    if (data.version <= 0 || data.version > kBackupVersion) {
      return 'إصدار النسخة الاحتياطية غير مدعوم. الرجاء تحديث التطبيق.';
    }
    return null;
  }

  static List<Map<String, dynamic>> _decodeList(dynamic raw) {
    if (raw is! String || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }
}

class BackupValidationResult {
  final bool isValid;
  final String? errorMessage;
  final BackupImportSummary? summary;

  const BackupValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.summary,
  });

  factory BackupValidationResult.success(BackupImportSummary summary) =>
      BackupValidationResult._(isValid: true, summary: summary);

  factory BackupValidationResult.error(String message) =>
      BackupValidationResult._(isValid: false, errorMessage: message);
}

class BackupImportSummary {
  final int coffeeCount;
  final int customerCount;

  const BackupImportSummary({
    required this.coffeeCount,
    required this.customerCount,
  });
}
