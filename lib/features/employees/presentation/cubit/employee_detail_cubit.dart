import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/attendance.dart';
import '../../domain/advance.dart';
import '../../domain/weekly_payroll.dart';
import '../../domain/employees_repository.dart';
import '../../domain/payroll_calculation_service.dart';
import '../../domain/validators.dart';
import 'employee_detail_state.dart';

class EmployeeDetailCubit extends Cubit<EmployeeDetailState> {
  EmployeeDetailCubit({
    required String employeeId,
    required EmployeesRepository repository,
    DateTime? weekStart,
  })  : _employeeId = employeeId,
        _repository = repository,
        super(EmployeeDetailState(
          weekStart:
              weekStart ?? PayrollCalculationService.getWeekStart(DateTime.now()),
          weekEnd: weekStart != null
              ? PayrollCalculationService.getWeekEnd(weekStart)
              : PayrollCalculationService.getWeekEnd(DateTime.now()),
        ));

  final String _employeeId;
  final EmployeesRepository _repository;
  final _uuid = const Uuid();

  Future<void> load() async {
    debugPrint('[DETAIL] load() → START employeeId=$_employeeId');
    emit(state.copyWith(
      status: EmployeeDetailStatus.loading,
      errorMessage: null,
    ));

    try {
      final employee = await _repository.getEmployee(_employeeId);
      final weekStart = state.weekStart!;
      final weekEnd = PayrollCalculationService.getWeekEnd(weekStart);
      debugPrint('[DETAIL] load() → employee=${employee.name}, week=$weekStart → $weekEnd');

      final attendances = await _repository.getAttendancesForWeek(
        employeeId: _employeeId,
        weekStart: weekStart,
        weekEnd: weekEnd,
      );
      debugPrint('[DETAIL] load() → ${attendances.length} attendances');

      final advances = await _repository.getAdvancesForWeek(
        employeeId: _employeeId,
        weekStart: weekStart,
        weekEnd: weekEnd,
      );

      final payroll = await _repository.getPayrollForWeek(
        employeeId: _employeeId,
        weekStart: weekStart,
      );

      final payrolls = await _repository.getPayrollsForEmployee(_employeeId);
      debugPrint('[DETAIL] load() → ${payrolls.length} total payrolls, current=${payroll != null}');

      final calculated = PayrollCalculationService.calculateWeeklyPayroll(
        attendances: attendances,
        hourlyRate: employee.hourlyRate,
        totalAdvances: advances.fold(0.0, (sum, a) => sum + a.amount),
      );
      debugPrint('[DETAIL] load() → calculated: hours=${calculated.totalHours}, gross=${calculated.grossPay}, net=${calculated.netPay}');

      WeeklyPayroll? weeklyPayroll = payroll;
      if (weeklyPayroll == null) {
        weeklyPayroll = WeeklyPayroll(
          id: '',
          employeeId: _employeeId,
          weekStart: weekStart,
          weekEnd: weekEnd,
          totalHours: calculated.totalHours,
          grossPay: calculated.grossPay,
          advances: calculated.advances,
          deductions: calculated.deductions,
          netPay: calculated.netPay,
          createdAt: DateTime.now(),
        );
      } else {
        weeklyPayroll = weeklyPayroll.copyWith(
          totalHours: calculated.totalHours,
          grossPay: calculated.grossPay,
          advances: calculated.advances,
          netPay: calculated.netPay,
        );
      }

      final calculatedAttendances = attendances.map((a) {
        return PayrollCalculationService.calculateAttendance(
          attendance: a,
          hourlyRate: employee.hourlyRate,
        );
      }).toList();

      emit(state.copyWith(
        status: EmployeeDetailStatus.ready,
        employee: employee,
        attendances: calculatedAttendances,
        advances: advances,
        payrolls: payrolls,
        weeklyPayroll: weeklyPayroll,
        weekEnd: weekEnd,
        isWeekClosed: payroll?.closed ?? false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EmployeeDetailStatus.failure,
        errorMessage: 'فشل في تحميل بيانات الموظف',
      ));
    }
  }

  void setWeek(DateTime weekStart) {
    emit(state.copyWith(
      weekStart: weekStart,
      weekEnd: PayrollCalculationService.getWeekEnd(weekStart),
    ));
    load();
  }

  void setTabIndex(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }

  Future<void> updateAttendance(Attendance attendance) async {
    if (state.isWeekClosed) {
      debugPrint('[DETAIL] updateAttendance() → ABORTED week is closed');
      return;
    }

    debugPrint('[DETAIL] updateAttendance() → CALLED id=${attendance.id}, checkIn=${attendance.checkIn}, checkOut=${attendance.checkOut}');

    AttendanceValidator.throwIfInvalid(
      checkIn: attendance.checkIn,
      checkOut: attendance.checkOut,
    );

    final employee = state.employee!;
    final calculated = PayrollCalculationService.calculateAttendance(
      attendance: attendance,
      hourlyRate: employee.hourlyRate,
    );
    debugPrint('[DETAIL] updateAttendance() → calculated hours=${calculated.calculatedHours}, pay=${calculated.calculatedPay}');

    Attendance updated;
    if (attendance.id.isEmpty) {
      updated = await _repository.createAttendance(calculated);
      debugPrint('[DETAIL] updateAttendance() → CREATED id=${updated.id}');
    } else {
      updated = await _repository.updateAttendance(calculated);
      debugPrint('[DETAIL] updateAttendance() → UPDATED in Hive');
    }

    final attendances = state.attendances
        .where((a) => a.id != updated.id)
        .toList()
      ..add(updated);

    await _recalculatePayroll(attendances, snackbarMessage: 'تم حفظ الحضور بنجاح');
    debugPrint('[DETAIL] updateAttendance() → STATE EMITTED');
  }

  Future<void> deleteAttendance(String attendanceId) async {
    if (state.isWeekClosed) {
      debugPrint('[DETAIL] deleteAttendance() → ABORTED week is closed');
      return;
    }

    debugPrint('[DETAIL] deleteAttendance() → CALLED id=$attendanceId');
    await _repository.deleteAttendance(attendanceId);
    debugPrint('[DETAIL] deleteAttendance() → HIVE DELETE OK');

    final attendances =
        state.attendances.where((a) => a.id != attendanceId).toList();
    await _recalculatePayroll(attendances, snackbarMessage: 'تم حذف الحضور');
  }

  Future<void> addAdvance(Advance advance) async {
    debugPrint('[DETAIL] addAdvance() → CALLED amount=${advance.amount}');
    final newAdvance = await _repository.createAdvance(advance);
    debugPrint('[DETAIL] addAdvance() → CREATED id=${newAdvance.id}');

    final advances = List<Advance>.from(state.advances)..add(newAdvance);
    await _recalculatePayroll(state.attendances, advances: advances, snackbarMessage: 'تم إضافة السلفة بنجاح');
  }

  Future<void> deleteAdvance(String advanceId) async {
    debugPrint('[DETAIL] deleteAdvance() → CALLED id=$advanceId');
    await _repository.deleteAdvance(advanceId);
    debugPrint('[DETAIL] deleteAdvance() → HIVE DELETE OK');

    final advances = state.advances.where((a) => a.id != advanceId).toList();
    await _recalculatePayroll(state.attendances, advances: advances, snackbarMessage: 'تم حذف السلفة');
  }

  Future<void> closeWeek() async {
    debugPrint('[DETAIL] closeWeek() → CALLED');
    final payroll = state.weeklyPayroll;
    if (payroll == null || payroll.id.isEmpty) {
      final existing = await _repository.getPayrollForWeek(
        employeeId: _employeeId,
        weekStart: state.weekStart!,
      );
      if (existing != null) {
        debugPrint('[DETAIL] closeWeek() → EXISTING payroll found, closing');
        await _repository.closePayroll(existing.id);
        emit(state.copyWith(
          weeklyPayroll: existing.copyWith(closed: true),
          isWeekClosed: true,
          snackbarMessage: 'تم إغلاق الأسبوع بنجاح',
        ));
        return;
      }

      final calculated = PayrollCalculationService.calculateWeeklyPayroll(
        attendances: state.attendances,
        hourlyRate: state.employee!.hourlyRate,
        totalAdvances: state.totalWeekAdvances,
      );
      debugPrint('[DETAIL] closeWeek() → new payroll: hours=${calculated.totalHours}, net=${calculated.netPay}');

      final newPayroll = WeeklyPayroll(
        id: _uuid.v4(),
        employeeId: _employeeId,
        weekStart: state.weekStart!,
        weekEnd: state.weekEnd!,
        totalHours: calculated.totalHours,
        grossPay: calculated.grossPay,
        advances: calculated.advances,
        deductions: calculated.deductions,
        netPay: calculated.netPay,
        closed: true,
        createdAt: DateTime.now(),
      );

      final saved = await _repository.savePayroll(newPayroll);
      debugPrint('[DETAIL] closeWeek() → SAVED id=${saved.id}');
      emit(state.copyWith(
        weeklyPayroll: saved,
        isWeekClosed: true,
        snackbarMessage: 'تم إغلاق الأسبوع بنجاح',
      ));
    } else {
      debugPrint('[DETAIL] closeWeek() → closing existing payroll id=${payroll.id}');
      await _repository.closePayroll(payroll.id);
      emit(state.copyWith(
        weeklyPayroll: payroll.copyWith(closed: true),
        isWeekClosed: true,
        snackbarMessage: 'تم إغلاق الأسبوع بنجاح',
      ));
    }
  }

  Future<void> _recalculatePayroll(
    List<Attendance> attendances, {
    List<Advance>? advances,
    String? snackbarMessage,
  }) async {
    final employee = state.employee!;
    final currentAdvances = advances ?? state.advances;

    final calculated = PayrollCalculationService.calculateWeeklyPayroll(
      attendances: attendances,
      hourlyRate: employee.hourlyRate,
      totalAdvances: currentAdvances.fold(0.0, (sum, a) => sum + a.amount),
    );
    debugPrint('[DETAIL] _recalculatePayroll() → hours=${calculated.totalHours}, gross=${calculated.grossPay}, advances=${calculated.advances}, net=${calculated.netPay}');

    final existingPayroll = state.weeklyPayroll;
    WeeklyPayroll payroll;

    if (existingPayroll != null && existingPayroll.id.isNotEmpty) {
      payroll = existingPayroll.copyWith(
        totalHours: calculated.totalHours,
        grossPay: calculated.grossPay,
        advances: calculated.advances,
        netPay: calculated.netPay,
      );
      debugPrint('[DETAIL] _recalculatePayroll() → UPDATING existing id=${payroll.id}');
      await _repository.savePayroll(payroll);
    } else {
      payroll = WeeklyPayroll(
        id: _uuid.v4(),
        employeeId: _employeeId,
        weekStart: state.weekStart!,
        weekEnd: state.weekEnd!,
        totalHours: calculated.totalHours,
        grossPay: calculated.grossPay,
        advances: calculated.advances,
        deductions: calculated.deductions,
        netPay: calculated.netPay,
        createdAt: DateTime.now(),
      );
      debugPrint('[DETAIL] _recalculatePayroll() → CREATING new id=${payroll.id}');
      await _repository.savePayroll(payroll);
    }

    emit(state.copyWith(
      attendances: attendances,
      advances: currentAdvances,
      weeklyPayroll: payroll,
      snackbarMessage: snackbarMessage,
    ));
    debugPrint('[DETAIL] _recalculatePayroll() → STATE EMITTED');
  }

  void clearSnackbar() {
    emit(state.copyWith(snackbarMessage: null));
  }
}
