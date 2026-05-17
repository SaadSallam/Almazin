import 'package:equatable/equatable.dart';
import 'attendance.dart';

class WeekSummary extends Equatable {
  const WeekSummary({
    required this.weekStart,
    required this.weekEnd,
    required this.totalEmployees,
    required this.activeEmployees,
    required this.totalHours,
    required this.totalGrossPay,
    required this.totalAdvances,
    required this.totalNetPay,
    required this.attendanceRecords,
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalEmployees;
  final int activeEmployees;
  final double totalHours;
  final double totalGrossPay;
  final double totalAdvances;
  final double totalNetPay;
  final List<Attendance> attendanceRecords;

  @override
  List<Object?> get props => [
        weekStart,
        weekEnd,
        totalEmployees,
        activeEmployees,
        totalHours,
        totalGrossPay,
        totalAdvances,
        totalNetPay,
        attendanceRecords,
      ];
}
