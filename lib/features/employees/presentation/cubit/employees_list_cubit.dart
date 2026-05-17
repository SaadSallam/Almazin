import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/employee.dart';
import '../../domain/employees_repository.dart';
import '../../domain/payroll_calculation_service.dart';
import 'employees_list_state.dart';

class EmployeesListCubit extends Cubit<EmployeesListState> {
  EmployeesListCubit({required EmployeesRepository repository})
      : _repository = repository,
        super(EmployeesListState(
          weekStart: PayrollCalculationService.getWeekStart(DateTime.now()),
        ));

  final EmployeesRepository _repository;

  Future<void> load() async {
    debugPrint('[CUBIT] load() → START');
    emit(state.copyWith(
      status: EmployeesListStatus.loading,
      errorMessage: null,
    ));

    try {
      final employees = await _repository.getAllEmployees();
      debugPrint('[CUBIT] load() → ${employees.length} employees from Hive');
      emit(state.copyWith(
        status: EmployeesListStatus.ready,
        employees: employees,
      ));
      debugPrint('[CUBIT] load() → STATE EMITTED (ready, ${employees.length} employees)');
    } catch (e) {
      debugPrint('[CUBIT] load() → FAILED: $e');
      emit(state.copyWith(
        status: EmployeesListStatus.failure,
        errorMessage: 'فشل في تحميل بيانات الموظفين',
      ));
    }
  }

  Future<void> addEmployee(Employee employee) async {
    debugPrint('[CUBIT] addEmployee() → CALLED name=${employee.name}');
    final newEmployee = await _repository.createEmployee(employee);
    debugPrint('[CUBIT] addEmployee() → REPOSITORY OK, id=${newEmployee.id}');
    final employees = List<Employee>.from(state.employees)..add(newEmployee);
    emit(state.copyWith(
      employees: employees,
      snackbarMessage: 'تم إضافة الموظف بنجاح',
    ));
    debugPrint('[CUBIT] addEmployee() → STATE EMITTED');
  }

  Future<void> updateEmployee(Employee employee) async {
    debugPrint('[CUBIT] updateEmployee() → CALLED id=${employee.id}');
    try {
      final updated = await _repository.updateEmployee(employee);
      debugPrint('[CUBIT] updateEmployee() → HIVE WRITE SUCCESS, name=${updated.name}');
      final employees = state.employees.map((e) {
        return e.id == updated.id ? updated : e;
      }).toList();
      emit(state.copyWith(
        employees: employees,
        snackbarMessage: 'تم تحديث بيانات الموظف بنجاح',
      ));
      debugPrint('[CUBIT] updateEmployee() → STATE EMITTED');
    } catch (e) {
      debugPrint('[CUBIT] updateEmployee() → FAILED: $e');
      emit(state.copyWith(snackbarMessage: 'فشل تحديث بيانات الموظف'));
    }
  }

  Future<void> deleteEmployee(String employeeId) async {
    debugPrint('[CUBIT] deleteEmployee() → CALLED id=$employeeId');
    try {
      await _repository.deleteEmployee(employeeId);
      debugPrint('[CUBIT] deleteEmployee() → HIVE DELETE SUCCESS');
      final employees =
          state.employees.where((e) => e.id != employeeId).toList();
      emit(state.copyWith(
        employees: employees,
        snackbarMessage: 'تم حذف الموظف بنجاح',
      ));
      debugPrint('[CUBIT] deleteEmployee() → STATE EMITTED, ${employees.length} remaining');
    } catch (e) {
      debugPrint('[CUBIT] deleteEmployee() → FAILED: $e');
      emit(state.copyWith(snackbarMessage: 'فشل حذف الموظف'));
    }
  }

  Future<String> exportData() async {
    final data = await _repository.exportAll();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<void> importData(String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final data = decoded.map((k, v) => MapEntry(k, v as String));
      await _repository.importAll(data);
      emit(state.copyWith(snackbarMessage: 'تم استيراد البيانات بنجاح'));
      load();
    } catch (e) {
      emit(state.copyWith(snackbarMessage: 'فشل استيراد البيانات'));
    }
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setWeekStart(DateTime weekStart) {
    emit(state.copyWith(weekStart: weekStart));
  }

  void clearSnackbar() {
    emit(state.copyWith(snackbarMessage: null));
  }
}
