import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  const Employee({
    required this.id,
    required this.name,
    this.phone,
    required this.hourlyRate,
    this.active = true,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? phone;
  final double hourlyRate;
  final bool active;
  final DateTime createdAt;

  Employee copyWith({
    String? id,
    String? name,
    String? phone,
    double? hourlyRate,
    bool? active,
    DateTime? createdAt,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.trim().substring(0, name.trim().length > 2 ? 2 : name.trim().length).toUpperCase();
  }

  @override
  List<Object?> get props => [id, name, phone, hourlyRate, active, createdAt];
}
