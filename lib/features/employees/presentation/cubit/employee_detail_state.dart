import 'package:equatable/equatable.dart';

import '../../domain/employee.dart';
import '../../domain/attendance.dart';
import '../../domain/advance.dart';
import '../../domain/weekly_payroll.dart';

enum EmployeeDetailStatus { initial, loading, ready, notFound, failure }

class EmployeeDetailState extends Equatable {
  const EmployeeDetailState({
    this.status = EmployeeDetailStatus.initial,
    this.employee,
    this.attendances = const [],
    this.advances = const [],
    this.payrolls = const [],
    this.weeklyPayroll,
    this.weekStart,
    this.weekEnd,
    this.errorMessage,
    this.snackbarMessage,
    this.isWeekClosed = false,
    this.selectedTabIndex = 0,
  });

  final EmployeeDetailStatus status;
  final Employee? employee;
  final List<Attendance> attendances;
  final List<Advance> advances;
  final List<WeeklyPayroll> payrolls;
  final WeeklyPayroll? weeklyPayroll;
  final DateTime? weekStart;
  final DateTime? weekEnd;
  final String? errorMessage;
  final String? snackbarMessage;
  final bool isWeekClosed;
  final int selectedTabIndex;

  double get totalWeeklyHours =>
      attendances.fold(0.0, (sum, a) => sum + a.calculatedHours);

  double get totalWeeklyGross =>
      attendances.fold(0.0, (sum, a) => sum + a.calculatedPay);

  double get totalWeekAdvances =>
      advances.fold(0.0, (sum, a) => sum + a.amount);

  double get netPay => totalWeeklyGross - totalWeekAdvances;

  EmployeeDetailState copyWith({
    EmployeeDetailStatus? status,
    Employee? employee,
    List<Attendance>? attendances,
    List<Advance>? advances,
    List<WeeklyPayroll>? payrolls,
    WeeklyPayroll? weeklyPayroll,
    DateTime? weekStart,
    DateTime? weekEnd,
    String? errorMessage,
    String? snackbarMessage,
    bool? isWeekClosed,
    int? selectedTabIndex,
  }) {
    return EmployeeDetailState(
      status: status ?? this.status,
      employee: employee ?? this.employee,
      attendances: attendances ?? this.attendances,
      advances: advances ?? this.advances,
      payrolls: payrolls ?? this.payrolls,
      weeklyPayroll: weeklyPayroll ?? this.weeklyPayroll,
      weekStart: weekStart ?? this.weekStart,
      weekEnd: weekEnd ?? this.weekEnd,
      errorMessage: errorMessage ?? this.errorMessage,
      snackbarMessage: snackbarMessage ?? this.snackbarMessage,
      isWeekClosed: isWeekClosed ?? this.isWeekClosed,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  @override
  List<Object?> get props => [
        status,
        employee,
        attendances,
        advances,
        payrolls,
        weeklyPayroll,
        weekStart,
        weekEnd,
        errorMessage,
        snackbarMessage,
        isWeekClosed,
        selectedTabIndex,
      ];
}
