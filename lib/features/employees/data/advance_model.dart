import 'dart:convert';

import '../domain/advance.dart';

class AdvanceModel {
  const AdvanceModel({
    required this.id,
    required this.employeeId,
    required this.amount,
    this.reason,
    required this.createdAt,
  });

  final String id;
  final String employeeId;
  final double amount;
  final String? reason;
  final DateTime createdAt;

  factory AdvanceModel.fromJson(Map<String, dynamic> json) {
    return AdvanceModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'amount': amount,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Advance toEntity() {
    return Advance(
      id: id,
      employeeId: employeeId,
      amount: amount,
      reason: reason,
      createdAt: createdAt,
    );
  }

  factory AdvanceModel.fromEntity(Advance entity) {
    return AdvanceModel(
      id: entity.id,
      employeeId: entity.employeeId,
      amount: entity.amount,
      reason: entity.reason,
      createdAt: entity.createdAt,
    );
  }

  static List<Advance> fromJsonList(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    final list = jsonDecode(jsonStr) as List;
    return list
        .map((e) => AdvanceModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  static String toJsonList(List<Advance> advances) {
    final models = advances.map(AdvanceModel.fromEntity).toList();
    return jsonEncode(models.map((m) => m.toJson()).toList());
  }
}
