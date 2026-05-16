import 'dart:convert';

import 'package:hive/hive.dart';

abstract class CustomersLocalDataSource {
  Future<List<Map<String, dynamic>>> readAll();

  Future<void> writeAll(List<Map<String, dynamic>> rows);
}

final class CustomersLocalDataSourceImpl implements CustomersLocalDataSource {
  CustomersLocalDataSourceImpl(this._box);

  final Box<dynamic> _box;

  static const String _storageKey = 'customers_v1';

  @override
  Future<List<Map<String, dynamic>>> readAll() async {
    final raw = _box.get(_storageKey);
    if (raw is! String || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }

  @override
  Future<void> writeAll(List<Map<String, dynamic>> rows) async {
    await _box.put(_storageKey, jsonEncode(rows));
  }
}
