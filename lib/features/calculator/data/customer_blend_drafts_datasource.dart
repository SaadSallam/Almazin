import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:almazin_app/features/calculator/domain/customer_percentage_blend_draft.dart';

abstract class CustomerBlendDraftsDataSource {
  Future<List<CustomerPercentageBlendDraft>> readAll();

  Future<void> append(CustomerPercentageBlendDraft draft);
}

final class CustomerBlendDraftsDataSourceImpl implements CustomerBlendDraftsDataSource {
  CustomerBlendDraftsDataSourceImpl(this._box);

  final Box<dynamic> _box;

  static const String _storageKey = 'customer_blend_drafts_v1';

  @override
  Future<List<CustomerPercentageBlendDraft>> readAll() async {
    final raw = _box.get(_storageKey);
    if (raw is! String || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];

    final out = <CustomerPercentageBlendDraft>[];
    for (final item in decoded) {
      if (item is! Map) continue;
      try {
        out.add(CustomerPercentageBlendDraft.fromJson(Map<String, dynamic>.from(item)));
      } catch (_) {}
    }
    return out;
  }

  @override
  Future<void> append(CustomerPercentageBlendDraft draft) async {
    final existing = await readAll();
    final next = <Map<String, dynamic>>[
      ...existing.map((e) => e.toJson()),
      draft.toJson(),
    ];
    await _box.put(_storageKey, jsonEncode(next));
  }
}
