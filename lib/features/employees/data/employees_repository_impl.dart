import 'package:uuid/uuid.dart';

import '../domain/employee.dart';
import '../domain/attendance.dart';
import '../domain/advance.dart';
import '../domain/weekly_payroll.dart';
import '../domain/employees_repository.dart';
import '../domain/validators.dart';
import '../domain/payroll_calculation_service.dart';
import 'employees_local_datasource.dart';

class EmployeesRepositoryImpl implements EmployeesRepository {
  EmployeesRepositoryImpl(this._dataSource);

  final EmployeesLocalDataSource _dataSource;
  final _uuid = const Uuid();

  @override
  Future<List<Employee>> getAllEmployees() async {
    return _dataSource.getAllEmployees();
  }

  @override
  Future<Employee> getEmployee(String id) async {
    return _dataSource.getEmployee(id);
  }

  @override
  Future<Employee> createEmployee(Employee employee) async {
    EmployeeValidator.throwIfInvalid(
      name: employee.name,
      hourlyRate: employee.hourlyRate,
    );

    final employees = await _dataSource.getAllEmployees();
    final newEmployee = employee.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
    );
    employees.add(newEmployee);
    await _dataSource.saveEmployees(employees);
    return newEmployee;
  }

  @override
  Future<Employee> updateEmployee(Employee employee) async {
    EmployeeValidator.throwIfInvalid(
      name: employee.name,
      hourlyRate: employee.hourlyRate,
    );

    final employees = await _dataSource.getAllEmployees();
    final index = employees.indexWhere((e) => e.id == employee.id);
    if (index == -1) throw Exception('Employee not found');
    employees[index] = employee;
    await _dataSource.saveEmployees(employees);
    return employee;
  }

  @override
  Future<void> deleteEmployee(String id) async {
    final employees = await _dataSource.getAllEmployees();
    employees.removeWhere((e) => e.id == id);
    await _dataSource.saveEmployees(employees);

    final attendances = await _dataSource.getAllAttendances();
    attendances.removeWhere((a) => a.employeeId == id);
    await _dataSource.saveAttendances(attendances);

    final advances = await _dataSource.getAllAdvances();
    advances.removeWhere((a) => a.employeeId == id);
    await _dataSource.saveAdvances(advances);

    final payrolls = await _dataSource.getAllPayrolls();
    payrolls.removeWhere((p) => p.employeeId == id);
    await _dataSource.savePayrolls(payrolls);
  }

  @override
  Future<List<Attendance>> getAttendancesForEmployee(String employeeId) async {
    final all = await _dataSource.getAllAttendances();
    return all.where((a) => a.employeeId == employeeId).toList();
  }

  @override
  Future<List<Attendance>> getAttendancesForWeek({
    required String employeeId,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) async {
    final all = await getAttendancesForEmployee(employeeId);
    return all.where((a) {
      return a.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          a.date.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<Attendance> createAttendance(Attendance attendance) async {
    final all = await _dataSource.getAllAttendances();
    final newAttendance = attendance.copyWith(id: _uuid.v4());
    all.add(newAttendance);
    await _dataSource.saveAttendances(all);
    return newAttendance;
  }

  @override
  Future<Attendance> updateAttendance(Attendance attendance) async {
    final all = await _dataSource.getAllAttendances();
    final index = all.indexWhere((a) => a.id == attendance.id);
    if (index == -1) throw Exception('Attendance not found');
    all[index] = attendance;
    await _dataSource.saveAttendances(all);
    return attendance;
  }

  @override
  Future<void> deleteAttendance(String id) async {
    final attendances = await _dataSource.getAllAttendances();
    attendances.removeWhere((a) => a.id == id);
    await _dataSource.saveAttendances(attendances);
  }

  @override
  Future<List<Advance>> getAdvancesForEmployee(String employeeId) async {
    final all = await _dataSource.getAllAdvances();
    return all.where((a) => a.employeeId == employeeId).toList();
  }

  @override
  Future<List<Advance>> getAdvancesForWeek({
    required String employeeId,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) async {
    final all = await getAdvancesForEmployee(employeeId);
    return all.where((a) {
      return a.createdAt.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          a.createdAt.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<Advance> createAdvance(Advance advance) async {
    AdvanceValidator.throwIfInvalid(amount: advance.amount);

    final all = await _dataSource.getAllAdvances();
    final newAdvance = advance.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
    );
    all.add(newAdvance);
    await _dataSource.saveAdvances(all);
    return newAdvance;
  }

  @override
  Future<void> deleteAdvance(String id) async {
    final advances = await _dataSource.getAllAdvances();
    advances.removeWhere((a) => a.id == id);
    await _dataSource.saveAdvances(advances);
  }

  @override
  Future<List<WeeklyPayroll>> getPayrollsForEmployee(String employeeId) async {
    final all = await _dataSource.getAllPayrolls();
    return all.where((p) => p.employeeId == employeeId).toList();
  }

  @override
  Future<WeeklyPayroll?> getPayrollForWeek({
    required String employeeId,
    required DateTime weekStart,
  }) async {
    final all = await getPayrollsForEmployee(employeeId);
    for (final payroll in all) {
      if (PayrollCalculationService.isSameDay(payroll.weekStart, weekStart)) {
        return payroll;
      }
    }
    return null;
  }

  @override
  Future<WeeklyPayroll> savePayroll(WeeklyPayroll payroll) async {
    final all = await _dataSource.getAllPayrolls();
    final index = all.indexWhere((p) => p.id == payroll.id);
    if (index != -1) {
      all[index] = payroll;
    } else {
      all.add(payroll);
    }
    await _dataSource.savePayrolls(all);
    return payroll;
  }

  @override
  Future<void> closePayroll(String payrollId) async {
    final all = await _dataSource.getAllPayrolls();
    final index = all.indexWhere((p) => p.id == payrollId);
    if (index == -1) throw Exception('Payroll not found');
    all[index] = all[index].copyWith(closed: true);
    await _dataSource.savePayrolls(all);
  }

  @override
  Future<Map<String, String>> exportAll() => _dataSource.exportAll();

  @override
  Future<void> importAll(Map<String, String> data) =>
      _dataSource.importAll(data);
}
