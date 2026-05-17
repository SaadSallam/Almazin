import 'package:equatable/equatable.dart';

class Advance extends Equatable {
  const Advance({
    required this.id,
    required this.employeeId,
    required this.amount,
    this.reason,
    required this.createdAt,
  });

  final String id;
  final String employeeId;
  final double amount;
  final String? reason;
  final DateTime createdAt;

  Advance copyWith({
    String? id,
    String? employeeId,
    double? amount,
    String? reason,
    DateTime? createdAt,
  }) {
    return Advance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, amount, reason, createdAt];
}
