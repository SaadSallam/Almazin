import 'dart:convert';

import '../domain/employee.dart';

class EmployeeModel {
  const EmployeeModel({
    required this.id,
    required this.name,
    this.phone,
    required this.hourlyRate,
    required this.active,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? phone;
  final double hourlyRate;
  final bool active;
  final DateTime createdAt;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'hourlyRate': hourlyRate,
      'active': active,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Employee toEntity() {
    return Employee(
      id: id,
      name: name,
      phone: phone,
      hourlyRate: hourlyRate,
      active: active,
      createdAt: createdAt,
    );
  }

  factory EmployeeModel.fromEntity(Employee entity) {
    return EmployeeModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      hourlyRate: entity.hourlyRate,
      active: entity.active,
      createdAt: entity.createdAt,
    );
  }

  static List<Employee> fromJsonList(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    final list = jsonDecode(jsonStr) as List;
    return list
        .map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  static String toJsonList(List<Employee> employees) {
    final models = employees.map(EmployeeModel.fromEntity).toList();
    return jsonEncode(models.map((m) => m.toJson()).toList());
  }
}
