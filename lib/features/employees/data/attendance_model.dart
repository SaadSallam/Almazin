import 'dart:convert';

import '../domain/attendance.dart';

class AttendanceModel {
  const AttendanceModel({
    required this.id,
    required this.employeeId,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.calculatedHours,
    required this.calculatedPay,
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

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      date: DateTime.parse(json['date'] as String),
      checkIn: json['checkIn'] != null
          ? DateTime.parse(json['checkIn'] as String)
          : null,
      checkOut: json['checkOut'] != null
          ? DateTime.parse(json['checkOut'] as String)
          : null,
      calculatedHours: (json['calculatedHours'] as num).toDouble(),
      calculatedPay: (json['calculatedPay'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'calculatedHours': calculatedHours,
      'calculatedPay': calculatedPay,
      'notes': notes,
    };
  }

  Attendance toEntity() {
    return Attendance(
      id: id,
      employeeId: employeeId,
      date: date,
      checkIn: checkIn,
      checkOut: checkOut,
      calculatedHours: calculatedHours,
      calculatedPay: calculatedPay,
      notes: notes,
    );
  }

  factory AttendanceModel.fromEntity(Attendance entity) {
    return AttendanceModel(
      id: entity.id,
      employeeId: entity.employeeId,
      date: entity.date,
      checkIn: entity.checkIn,
      checkOut: entity.checkOut,
      calculatedHours: entity.calculatedHours,
      calculatedPay: entity.calculatedPay,
      notes: entity.notes,
    );
  }

  static List<Attendance> fromJsonList(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    final list = jsonDecode(jsonStr) as List;
    return list
        .map((e) =>
            AttendanceModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  static String toJsonList(List<Attendance> attendances) {
    final models = attendances.map(AttendanceModel.fromEntity).toList();
    return jsonEncode(models.map((m) => m.toJson()).toList());
  }
}
