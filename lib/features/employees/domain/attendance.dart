import 'package:equatable/equatable.dart';

class Attendance extends Equatable {
  const Attendance({
    required this.id,
    required this.employeeId,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.calculatedHours = 0,
    this.calculatedPay = 0,
    this.notes,
  });

  final String id;
  final String employeeId;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final double calculatedHours;
  final double calculatedPay;
  final String? notes;

  bool get isComplete => checkIn != null && checkOut != null;

  Attendance copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    DateTime? checkIn,
    DateTime? checkOut,
    double? calculatedHours,
    double? calculatedPay,
    String? notes,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      calculatedHours: calculatedHours ?? this.calculatedHours,
      calculatedPay: calculatedPay ?? this.calculatedPay,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        date,
        checkIn,
        checkOut,
        calculatedHours,
        calculatedPay,
        notes,
      ];
}
