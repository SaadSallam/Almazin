import 'package:equatable/equatable.dart';

class WeeklyPayroll extends Equatable {
  const WeeklyPayroll({
    required this.id,
    required this.employeeId,
    required this.weekStart,
    required this.weekEnd,
    required this.totalHours,
    required this.grossPay,
    required this.advances,
    required this.deductions,
    required this.netPay,
    this.closed = false,
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

  WeeklyPayroll copyWith({
    String? id,
    String? employeeId,
    DateTime? weekStart,
    DateTime? weekEnd,
    double? totalHours,
    double? grossPay,
    double? advances,
    double? deductions,
    double? netPay,
    bool? closed,
    DateTime? createdAt,
  }) {
    return WeeklyPayroll(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      weekStart: weekStart ?? this.weekStart,
      weekEnd: weekEnd ?? this.weekEnd,
      totalHours: totalHours ?? this.totalHours,
      grossPay: grossPay ?? this.grossPay,
      advances: advances ?? this.advances,
      deductions: deductions ?? this.deductions,
      netPay: netPay ?? this.netPay,
      closed: closed ?? this.closed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        weekStart,
        weekEnd,
        totalHours,
        grossPay,
        advances,
        deductions,
        netPay,
        closed,
        createdAt,
      ];
}
