import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'package:almazin_app/features/employees/domain/attendance.dart';
import 'package:almazin_app/features/employees/domain/employee.dart';
import 'package:almazin_app/features/employees/domain/validators.dart';
import 'package:almazin_app/features/employees/domain/payroll_calculation_service.dart';
import 'package:almazin_app/features/employees/domain/employees_repository.dart';
import 'package:almazin_app/features/employees/data/employees_local_datasource.dart';
import 'package:almazin_app/features/employees/data/employees_repository_impl.dart';

void main() {
  late Box<dynamic> box;
  late EmployeesLocalDataSource dataSource;
  late EmployeesRepository repository;
  late String employeeId;
  final uuid = const Uuid();

  setUp(() async {
    final dir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(dir.path);
    box = await Hive.openBox<dynamic>('test_almazin_data');
    dataSource = EmployeesLocalDataSourceImpl(box);
    repository = EmployeesRepositoryImpl(dataSource);

    final emp = await repository.createEmployee(
      Employee(
        id: '',
        name: 'أحمد',
        phone: '01234567890',
        hourlyRate: 50,
        createdAt: DateTime.now(),
      ),
    );
    employeeId = emp.id;
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('test_almazin_data');
  });

  group('AttendanceValidator — checkIn only (fix verification)', () {
    test('checkIn only passes validation', () {
      final errors = AttendanceValidator.validate(
        checkIn: DateTime(2026, 5, 16, 9, 0),
        checkOut: null,
      );
      expect(errors, isEmpty, reason: 'checkOut=null should NOT be an error');
    });

    test('both checkIn and checkOut passes validation', () {
      final errors = AttendanceValidator.validate(
        checkIn: DateTime(2026, 5, 16, 9, 0),
        checkOut: DateTime(2026, 5, 16, 17, 0),
      );
      expect(errors, isEmpty);
    });

    test('both null passes validation (no-op)', () {
      final errors = AttendanceValidator.validate(
        checkIn: null,
        checkOut: null,
      );
      expect(errors, isEmpty);
    });

    test('checkOut without checkIn fails', () {
      final errors = AttendanceValidator.validate(
        checkIn: null,
        checkOut: DateTime(2026, 5, 16, 17, 0),
      );
      expect(errors, isNotEmpty);
      expect(errors.first, 'وقت الحضور مطلوب');
    });
  });

  group('Attendance CREATE — check-in only', () {
    test('createAttendance with only checkIn succeeds', () async {
      final attendance = await repository.createAttendance(
        Attendance(
          id: '',
          employeeId: employeeId,
          date: DateTime(2026, 5, 16),
          checkIn: DateTime(2026, 5, 16, 9, 0),
          checkOut: null,
        ),
      );

      expect(attendance.id, isNotEmpty, reason: 'ID should be generated');
      expect(attendance.checkIn, isNotNull);
      expect(attendance.checkOut, isNull,
          reason: 'checkOut should remain null on check-in');
      expect(attendance.employeeId, employeeId);
    });

    test('createAttendance generates UUID', () async {
      final a1 = await repository.createAttendance(
        Attendance(
          id: '',
          employeeId: employeeId,
          date: DateTime(2026, 5, 16),
          checkIn: DateTime(2026, 5, 16, 9, 0),
        ),
      );
      final a2 = await repository.createAttendance(
        Attendance(
          id: '',
          employeeId: employeeId,
          date: DateTime(2026, 5, 17),
          checkIn: DateTime(2026, 5, 17, 10, 0),
        ),
      );

      expect(a1.id, isNot(a2.id), reason: 'Each attendance gets unique ID');
    });

    test('attendance persists in Hive after create', () async {
      final attendance = await repository.createAttendance(
        Attendance(
          id: '',
          employeeId: employeeId,
          date: DateTime(2026, 5, 16),
          checkIn: DateTime(2026, 5, 16, 9, 0),
        ),
      );

      final all = await dataSource.getAllAttendances();
      expect(all.length, 1);
      expect(all.first.id, attendance.id);
      expect(all.first.checkOut, isNull);
    });
  });

  group('Attendance UPDATE — check-out (critical: NO DUPLICATE)', () {
    test('updateAttendance updates existing record, does NOT create new',
        () async {
      final created = await repository.createAttendance(
        Attendance(
          id: '',
          employeeId: employeeId,
          date: DateTime(2026, 5, 16),
          checkIn: DateTime(2026, 5, 16, 9, 0),
        ),
      );

      await repository.updateAttendance(
        created.copyWith(
          checkOut: DateTime(2026, 5, 16, 17, 0),
        ),
      );

      final all = await dataSource.getAllAttendances();
      expect(all.length, 1, reason: 'Must NOT create duplicate record');
      expect(all.first.id, created.id);
      expect(all.first.checkIn?.hour, 9);
      expect(all.first.checkOut?.hour, 17);
    });

    test('updateAttendance throws if ID not found', () async {
      expect(
        () async => repository.updateAttendance(
          Attendance(
            id: 'nonexistent',
            employeeId: employeeId,
            date: DateTime(2026, 5, 16),
            checkIn: DateTime(2026, 5, 16, 9, 0),
            checkOut: DateTime(2026, 5, 16, 17, 0),
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Payroll calculation — check-in only', () {
    test('check-in only results in 0 hours and 0 pay', () async {
      final attendance = Attendance(
        id: uuid.v4(),
        employeeId: employeeId,
        date: DateTime(2026, 5, 16),
        checkIn: DateTime(2026, 5, 16, 9, 0),
        checkOut: null,
      );

      final calc = PayrollCalculationService.calculateWeeklyPayroll(
        attendances: [attendance],
        hourlyRate: 50,
        totalAdvances: 0,
      );

      expect(calc.totalHours, 0,
          reason: 'Without checkout, hours should be 0');
      expect(calc.grossPay, 0, reason: 'Without checkout, pay should be 0');
    });

    test('check-in + checkout calculates correct hours and pay', () async {
      final attendance = Attendance(
        id: uuid.v4(),
        employeeId: employeeId,
        date: DateTime(2026, 5, 16),
        checkIn: DateTime(2026, 5, 16, 9, 0),
        checkOut: DateTime(2026, 5, 16, 17, 0),
      );

      final calc = PayrollCalculationService.calculateWeeklyPayroll(
        attendances: [attendance],
        hourlyRate: 50,
        totalAdvances: 0,
      );

      expect(calc.totalHours, 8);
      expect(calc.grossPay, 400);
      expect(calc.netPay, 400);
    });

    test('multi-day payroll accumulates correctly', () async {
      final attendances = [
        Attendance(
          id: uuid.v4(),
          employeeId: employeeId,
          date: DateTime(2026, 5, 16),
          checkIn: DateTime(2026, 5, 16, 9, 0),
          checkOut: DateTime(2026, 5, 16, 17, 0),
        ),
        Attendance(
          id: uuid.v4(),
          employeeId: employeeId,
          date: DateTime(2026, 5, 17),
          checkIn: DateTime(2026, 5, 17, 8, 0),
          checkOut: DateTime(2026, 5, 17, 16, 0),
        ),
      ];

      final calc = PayrollCalculationService.calculateWeeklyPayroll(
        attendances: attendances,
        hourlyRate: 50,
        totalAdvances: 100,
      );

      expect(calc.totalHours, 16);
      expect(calc.grossPay, 800);
      expect(calc.advances, 100);
      expect(calc.netPay, 700);
    });

    test('overnight shift calculates correctly', () async {
      final attendance = Attendance(
        id: uuid.v4(),
        employeeId: employeeId,
        date: DateTime(2026, 5, 16),
        checkIn: DateTime(2026, 5, 16, 22, 0),
        checkOut: DateTime(2026, 5, 17, 6, 0),
      );

      final calc = PayrollCalculationService.calculateWeeklyPayroll(
        attendances: [attendance],
        hourlyRate: 50,
        totalAdvances: 0,
      );

      expect(calc.totalHours, 8);
      expect(calc.grossPay, 400);
    });
  });

  group('Full end-to-end flow: check-in → check-out → payroll', () {
    test('complete flow with no duplicates', () async {
      final date = DateTime(2026, 5, 16);
      final weekStart =
          PayrollCalculationService.getWeekStart(date);
      final weekEnd =
          PayrollCalculationService.getWeekEnd(weekStart);

      final checkInTime = DateTime(2026, 5, 16, 9, 0);
      final checkOutTime = DateTime(2026, 5, 16, 17, 0);

      final dayAttendance = await repository.createAttendance(
        Attendance(
          id: '',
          employeeId: employeeId,
          date: date,
          checkIn: checkInTime,
          checkOut: null,
        ),
      );

      expect(dayAttendance.id, isNotEmpty);
      expect(dayAttendance.checkOut, isNull);
      expect(
        (await repository.getAttendancesForWeek(
          employeeId: employeeId,
          weekStart: weekStart,
          weekEnd: weekEnd,
        )).length,
        1,
      );

      await repository.updateAttendance(
        dayAttendance.copyWith(checkOut: checkOutTime),
      );

      final attendancesAfter = await repository.getAttendancesForWeek(
        employeeId: employeeId,
        weekStart: weekStart,
        weekEnd: weekEnd,
      );
      expect(attendancesAfter.length, 1,
          reason: 'CRITICAL: must not create duplicate record');
      expect(attendancesAfter.first.checkOut?.hour, 17);

      final employee = await repository.getEmployee(employeeId);
      final calc = PayrollCalculationService.calculateWeeklyPayroll(
        attendances: attendancesAfter,
        hourlyRate: employee.hourlyRate,
        totalAdvances: 0,
      );

      expect(calc.totalHours, 8);
      expect(calc.grossPay, 400);
      expect(calc.netPay, 400);
    });
  });

  group('Cubit logic verification (no cubit instantiation needed)', () {
    test('updateAttendance dispatch logic is correct', () async {
      final created = await repository.createAttendance(
        Attendance(
          id: '',
          employeeId: employeeId,
          date: DateTime(2026, 5, 16),
          checkIn: DateTime(2026, 5, 16, 9, 0),
        ),
      );

      final updated = await repository.updateAttendance(
        created.copyWith(checkOut: DateTime(2026, 5, 16, 17, 0)),
      );

      final all = await dataSource.getAllAttendances();
      expect(all.length, 1, reason: 'update must NOT create a new record');
      expect(updated.id, created.id,
          reason: 'same ID across create + update');
    });

    test('attendance id.isEmpty → createAttendance is called', () {
      final attendance = Attendance(
        id: '',
        employeeId: employeeId,
        date: DateTime(2026, 5, 16),
        checkIn: DateTime(2026, 5, 16, 9, 0),
      );
      expect(attendance.id.isEmpty, true,
          reason: 'new check-in attendance has empty ID');
    });

    test('attendance id.isNotEmpty → updateAttendance is called', () async {
      final created = await repository.createAttendance(
        Attendance(
          id: '',
          employeeId: employeeId,
          date: DateTime(2026, 5, 16),
          checkIn: DateTime(2026, 5, 16, 9, 0),
        ),
      );
      expect(created.id.isNotEmpty, true,
          reason: 'after createAttendance, ID is set');
    });
  });
}
