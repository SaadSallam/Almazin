import 'package:equatable/equatable.dart';

/// Coffee type used for pricing across the app (per kilogram, EGP).
class CoffeeType extends Equatable {
  const CoffeeType({
    required this.id,
    required this.name,
    required this.pricePerKilogram,
    required this.notes,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final double pricePerKilogram;
  final String notes;
  final DateTime updatedAt;

  CoffeeType copyWith({
    String? id,
    String? name,
    double? pricePerKilogram,
    String? notes,
    DateTime? updatedAt,
  }) {
    return CoffeeType(
      id: id ?? this.id,
      name: name ?? this.name,
      pricePerKilogram: pricePerKilogram ?? this.pricePerKilogram,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, pricePerKilogram, notes, updatedAt];
}
