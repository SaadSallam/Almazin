class EmployeeValidationException implements Exception {
  const EmployeeValidationException(this.errors);

  final List<String> errors;

  @override
  String toString() => 'EmployeeValidationException: ${errors.join(', ')}';
}

class EmployeeValidator {
  static List<String> validate({
    required String name,
    required double hourlyRate,
  }) {
    final errors = <String>[];

    if (name.trim().isEmpty) {
      errors.add('اسم الموظف مطلوب');
    }

    if (hourlyRate <= 0) {
      errors.add('سعر الساعة يجب أن يكون أكبر من صفر');
    }

    return errors;
  }

  static void throwIfInvalid({
    required String name,
    required double hourlyRate,
  }) {
    final errors = validate(name: name, hourlyRate: hourlyRate);
    if (errors.isNotEmpty) {
      throw EmployeeValidationException(errors);
    }
  }
}

class AttendanceValidationException implements Exception {
  const AttendanceValidationException(this.errors);

  final List<String> errors;

  @override
  String toString() => 'AttendanceValidationException: ${errors.join(', ')}';
}

class AttendanceValidator {
  static List<String> validate({
    DateTime? checkIn,
    DateTime? checkOut,
  }) {
    final errors = <String>[];

    if (checkIn == null && checkOut == null) {
      return errors;
    }

    if (checkIn == null) {
      errors.add('وقت الحضور مطلوب');
    }

    return errors;
  }

  static void throwIfInvalid({
    DateTime? checkIn,
    DateTime? checkOut,
  }) {
    final errors = validate(checkIn: checkIn, checkOut: checkOut);
    if (errors.isNotEmpty) {
      throw AttendanceValidationException(errors);
    }
  }
}

class AdvanceValidationException implements Exception {
  const AdvanceValidationException(this.errors);

  final List<String> errors;

  @override
  String toString() => 'AdvanceValidationException: ${errors.join(', ')}';
}

class AdvanceValidator {
  static List<String> validate({
    required double amount,
  }) {
    final errors = <String>[];

    if (amount <= 0) {
      errors.add('المبلغ يجب أن يكون أكبر من صفر');
    }

    return errors;
  }

  static void throwIfInvalid({required double amount}) {
    final errors = validate(amount: amount);
    if (errors.isNotEmpty) {
      throw AdvanceValidationException(errors);
    }
  }
}
