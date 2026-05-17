import 'dart:convert';

import '../domain/weekly_payroll.dart';

class WeeklyPayrollModel {
  const WeeklyPayrollModel({
    required this.id,
    required this.employeeId,
    required this.weekStart,
    required this.weekEnd,
    required this.totalHours,
    required this.grossPay,
    required this.advances,
    required this.deductions,
    required this.netPay,
    required this.closed,
    required this.createdAt,
  });

  final String id;
  final String employeeId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final double totalHours;
  final double grossPay;
  final double advances;
  final double deductions;
  final double netPay;
  final bool closed;
  final DateTime createdAt;

  factory WeeklyPayrollModel.fromJson(Map<String, dynamic> json) {
    return WeeklyPayrollModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      weekStart: DateTime.parse(json['weekStart'] as String),
      weekEnd: DateTime.parse(json['weekEnd'] as String),
      totalHours: (json['totalHours'] as num).toDouble(),
      grossPay: (json['grossPay'] as num).toDouble(),
      advances: (json['advances'] as num).toDouble(),
      deductions: (json['deductions'] as num).toDouble(),
      netPay: (json['netPay'] as num).toDouble(),
      closed: json['closed'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'weekStart': weekStart.toIso8601String(),
      'weekEnd': weekEnd.toIso8601String(),
      'totalHours': totalHours,
      'grossPay': grossPay,
      'advances': advances,
      'deductions': deductions,
      'netPay': netPay,
      'closed': closed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  WeeklyPayroll toEntity() {
    return WeeklyPayroll(
      id: id,
      employeeId: employeeId,
      weekStart: weekStart,
      weekEnd: weekEnd,
      totalHours: totalHours,
      grossPay: grossPay,
      advances: advances,
      deductions: deductions,
      netPay: netPay,
      closed: closed,
      createdAt: createdAt,
    );
  }

  factory WeeklyPayrollModel.fromEntity(WeeklyPayroll entity) {
    return WeeklyPayrollModel(
      id: entity.id,
      employeeId: entity.employeeId,
      weekStart: entity.weekStart,
      weekEnd: entity.weekEnd,
      totalHours: entity.totalHours,
      grossPay: entity.grossPay,
      advances: entity.advances,
      deductions: entity.deductions,
      netPay: entity.netPay,
      closed: entity.closed,
      createdAt: entity.createdAt,
    );
  }

  static List<WeeklyPayroll> fromJsonList(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    final list = jsonDecode(jsonStr) as List;
    return list
        .map((e) =>
            WeeklyPayrollModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  static String toJsonList(List<WeeklyPayroll> payrolls) {
    final models = payrolls.map(WeeklyPayrollModel.fromEntity).toList();
    return jsonEncode(models.map((m) => m.toJson()).toList());
  }
}
