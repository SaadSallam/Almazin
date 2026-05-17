import 'employee.dart';
import 'attendance.dart';
import 'advance.dart';
import 'weekly_payroll.dart';

abstract class EmployeesRepository {
  Future<List<Employee>> getAllEmployees();
  Future<Employee> getEmployee(String id);
  Future<Employee> createEmployee(Employee employee);
  Future<Employee> updateEmployee(Employee employee);
  Future<void> deleteEmployee(String id);

  Future<List<Attendance>> getAttendancesForEmployee(String employeeId);
  Future<List<Attendance>> getAttendancesForWeek({
    required String employeeId,
    required DateTime weekStart,
    required DateTime weekEnd,
  });
  Future<Attendance> createAttendance(Attendance attendance);
  Future<Attendance> updateAttendance(Attendance attendance);
  Future<void> deleteAttendance(String id);

  Future<List<Advance>> getAdvancesForEmployee(String employeeId);
  Future<List<Advance>> getAdvancesForWeek({
    required String employeeId,
    required DateTime weekStart,
    required DateTime weekEnd,
  });
  Future<Advance> createAdvance(Advance advance);
  Future<void> deleteAdvance(String id);

  Future<List<WeeklyPayroll>> getPayrollsForEmployee(String employeeId);
  Future<WeeklyPayroll?> getPayrollForWeek({
    required String employeeId,
    required DateTime weekStart,
  });
  Future<WeeklyPayroll> savePayroll(WeeklyPayroll payroll);
  Future<void> closePayroll(String payrollId);
  Future<Map<String, String>> exportAll();
  Future<void> importAll(Map<String, String> data);
}
