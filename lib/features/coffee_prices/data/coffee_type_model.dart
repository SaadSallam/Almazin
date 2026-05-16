import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';

final class CoffeeTypeModel {
  const CoffeeTypeModel({
    required this.id,
    required this.name,
    required this.pricePerKilogram,
    required this.notes,
    required this.updatedAtIso,
  });

  final String id;
  final String name;
  final double pricePerKilogram;
  final String notes;
  final String updatedAtIso;

  factory CoffeeTypeModel.fromEntity(CoffeeType entity) {
    return CoffeeTypeModel(
      id: entity.id,
      name: entity.name,
      pricePerKilogram: entity.pricePerKilogram,
      notes: entity.notes,
      updatedAtIso: entity.updatedAt.toUtc().toIso8601String(),
    );
  }

  factory CoffeeTypeModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    final priceRaw = json['pricePerKilogram'];
    final price = priceRaw is num ? priceRaw.toDouble() : double.tryParse('$priceRaw') ?? 0;
    final notes = json['notes']?.toString() ?? '';
    final updatedAtIso = json['updatedAt']?.toString() ?? '';

    return CoffeeTypeModel(
      id: id,
      name: name,
      pricePerKilogram: price,
      notes: notes,
      updatedAtIso: updatedAtIso,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'pricePerKilogram': pricePerKilogram,
      'notes': notes,
      'updatedAt': updatedAtIso,
    };
  }

  CoffeeType toEntity() {
    final parsedAt = DateTime.tryParse(updatedAtIso)?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0);
    return CoffeeType(
      id: id,
      name: name,
      pricePerKilogram: pricePerKilogram,
      notes: notes,
      updatedAt: parsedAt,
    );
  }
}
