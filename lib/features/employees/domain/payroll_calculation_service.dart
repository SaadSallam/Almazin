import 'attendance.dart';

class PayrollCalculationService {
  static double calculateHours({
    required DateTime checkIn,
    required DateTime checkOut,
  }) {
    final difference = checkOut.difference(checkIn).inMinutes;

    if (difference >= 0) {
      return difference / 60.0;
    }

    final overnightMinutes = (24 * 60) + difference;
    return overnightMinutes / 60.0;
  }

  static double calculateDailyPay({
    required double hours,
    required double hourlyRate,
  }) {
    return hours * hourlyRate;
  }

  static Attendance calculateAttendance({
    required Attendance attendance,
    required double hourlyRate,
  }) {
    if (attendance.checkIn == null || attendance.checkOut == null) {
      return attendance;
    }

    final hours = calculateHours(
      checkIn: attendance.checkIn!,
      checkOut: attendance.checkOut!,
    );

    final pay = calculateDailyPay(hours: hours, hourlyRate: hourlyRate);

    return attendance.copyWith(
      calculatedHours: double.parse(hours.toStringAsFixed(2)),
      calculatedPay: double.parse(pay.toStringAsFixed(2)),
    );
  }

  static ({
    double totalHours,
    double grossPay,
    double advances,
    double deductions,
    double netPay,
  }) calculateWeeklyPayroll({
    required List<Attendance> attendances,
    required double hourlyRate,
    required double totalAdvances,
    double deductions = 0,
  }) {
    double totalHours = 0;
    double grossPay = 0;

    for (final attendance in attendances) {
      final calculated = calculateAttendance(
        attendance: attendance,
        hourlyRate: hourlyRate,
      );
      totalHours += calculated.calculatedHours;
      grossPay += calculated.calculatedPay;
    }

    final netPay = grossPay - totalAdvances - deductions;

    return (
      totalHours: double.parse(totalHours.toStringAsFixed(2)),
      grossPay: double.parse(grossPay.toStringAsFixed(2)),
      advances: totalAdvances,
      deductions: deductions,
      netPay: double.parse(netPay.toStringAsFixed(2)),
    );
  }

  static DateTime getWeekStart(DateTime date) {
    final daysFromSaturday = (date.weekday + 1) % 7;
    return date.subtract(Duration(days: daysFromSaturday));
  }

  static DateTime getWeekEnd(DateTime date) {
    final weekStart = getWeekStart(date);
    return weekStart.add(const Duration(days: 6));
  }

  static DateTime getNextWeekStart(DateTime weekStart) {
    return weekStart.add(const Duration(days: 7));
  }

  static DateTime getPreviousWeekStart(DateTime weekStart) {
    return weekStart.subtract(const Duration(days: 7));
  }

  static List<DateTime> getWeekDays(DateTime weekStart) {
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
