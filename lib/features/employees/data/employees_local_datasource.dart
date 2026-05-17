import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../domain/employee.dart';
import '../domain/attendance.dart';
import '../domain/advance.dart';
import '../domain/weekly_payroll.dart';
import 'employee_model.dart';
import 'attendance_model.dart';
import 'advance_model.dart';
import 'weekly_payroll_model.dart';

abstract class EmployeesLocalDataSource {
  Future<List<Employee>> getAllEmployees();
  Future<Employee> getEmployee(String id);
  Future<void> saveEmployees(List<Employee> employees);

  Future<List<Attendance>> getAllAttendances();
  Future<void> saveAttendances(List<Attendance> attendances);

  Future<List<Advance>> getAllAdvances();
  Future<void> saveAdvances(List<Advance> advances);

  Future<List<WeeklyPayroll>> getAllPayrolls();
  Future<void> savePayrolls(List<WeeklyPayroll> payrolls);

  Future<Map<String, String>> exportAll();
  Future<void> importAll(Map<String, String> data);
}

class EmployeesLocalDataSourceImpl implements EmployeesLocalDataSource {
  EmployeesLocalDataSourceImpl(this._box) {
    _ensureMigration();
  }

  final Box<dynamic> _box;
  final _uuid = const Uuid();

  static const _employeesKey = 'employees_v1';
  static const _attendancesKey = 'attendances_v1';
  static const _advancesKey = 'advances_v1';
  static const _payrollsKey = 'payrolls_v1';
  static const _versionKey = 'data_version';
  static const _seededKey = 'seed_done';
  static const _currentVersion = 1;

  void _ensureMigration() {
    final version = _box.get(_versionKey) as int? ?? 0;
    if (version < _currentVersion) {
      if (version < 1) {
        final hasOldData = _box.get('employees') != null ||
            _box.get('attendances') != null;
        if (hasOldData) {
          final oldEmployees = _box.get('employees') as String? ?? '';
          final oldAttendances = _box.get('attendances') as String? ?? '';
          if (_box.get(_employeesKey) == null && oldEmployees.isNotEmpty) {
            _box.put(_employeesKey, oldEmployees);
          }
          if (_box.get(_attendancesKey) == null &&
              oldAttendances.isNotEmpty) {
            _box.put(_attendancesKey, oldAttendances);
          }
        }
      }
      _box.put(_versionKey, _currentVersion);
    }
  }

  @override
  Future<List<Employee>> getAllEmployees() async {
    final data = _box.get(_employeesKey) as String?;
    final list = EmployeeModel.fromJsonList(data ?? '');
    if (list.isEmpty && kDebugMode && _box.get(_seededKey) != true) {
      await _seedEmployees();
      _box.put(_seededKey, true);
      return EmployeeModel.fromJsonList(_box.get(_employeesKey) as String? ?? '');
    }
    return list;
  }

  Future<void> _seedEmployees() async {
    final now = DateTime.now();
    final seedData = [
      Employee(
        id: _uuid.v4(),
        name: 'أحمد',
        phone: '01234567890',
        hourlyRate: 50.0,
        createdAt: now,
      ),
      Employee(
        id: _uuid.v4(),
        name: 'محمد',
        phone: '01234567891',
        hourlyRate: 45.0,
        createdAt: now,
      ),
      Employee(
        id: _uuid.v4(),
        name: 'إسلام',
        phone: '01234567892',
        hourlyRate: 55.0,
        createdAt: now,
      ),
    ];
    await saveEmployees(seedData);
  }

  @override
  Future<Employee> getEmployee(String id) async {
    final employees = await getAllEmployees();
    return employees.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('Employee not found: $id'),
    );
  }

  @override
  Future<void> saveEmployees(List<Employee> employees) async {
    await _box.put(_employeesKey, EmployeeModel.toJsonList(employees));
  }

  @override
  Future<List<Attendance>> getAllAttendances() async {
    final data = _box.get(_attendancesKey) as String?;
    return AttendanceModel.fromJsonList(data ?? '');
  }

  @override
  Future<void> saveAttendances(List<Attendance> attendances) async {
    await _box.put(_attendancesKey, AttendanceModel.toJsonList(attendances));
  }

  @override
  Future<List<Advance>> getAllAdvances() async {
    final data = _box.get(_advancesKey) as String?;
    return AdvanceModel.fromJsonList(data ?? '');
  }

  @override
  Future<void> saveAdvances(List<Advance> advances) async {
    await _box.put(_advancesKey, AdvanceModel.toJsonList(advances));
  }

  @override
  Future<List<WeeklyPayroll>> getAllPayrolls() async {
    final data = _box.get(_payrollsKey) as String?;
    return WeeklyPayrollModel.fromJsonList(data ?? '');
  }

  @override
  Future<void> savePayrolls(List<WeeklyPayroll> payrolls) async {
    await _box.put(_payrollsKey, WeeklyPayrollModel.toJsonList(payrolls));
  }

  @override
  Future<Map<String, String>> exportAll() async {
    return {
      _employeesKey: _box.get(_employeesKey) as String? ?? '',
      _attendancesKey: _box.get(_attendancesKey) as String? ?? '',
      _advancesKey: _box.get(_advancesKey) as String? ?? '',
      _payrollsKey: _box.get(_payrollsKey) as String? ?? '',
    };
  }

  @override
  Future<void> importAll(Map<String, String> data) async {
    if (data.containsKey(_employeesKey)) {
      await _box.put(_employeesKey, data[_employeesKey]);
    }
    if (data.containsKey(_attendancesKey)) {
      await _box.put(_attendancesKey, data[_attendancesKey]);
    }
    if (data.containsKey(_advancesKey)) {
      await _box.put(_advancesKey, data[_advancesKey]);
    }
    if (data.containsKey(_payrollsKey)) {
      await _box.put(_payrollsKey, data[_payrollsKey]);
    }
  }
}
