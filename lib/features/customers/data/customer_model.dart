import 'package:almazin_app/features/customers/domain/blend_component.dart';
import 'package:almazin_app/features/customers/domain/customer.dart';

final class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.notes,
    required this.blend,
  });

  final String id;
  final String name;
  final String phone;
  final String address;
  final String notes;
  final List<BlendComponentModel> blend;

  factory CustomerModel.fromEntity(Customer entity) {
    return CustomerModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      address: entity.address,
      notes: entity.notes,
      blend: entity.blend.map(BlendComponentModel.fromEntity).toList(),
    );
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final rawBlend = json['blend'];
    final blend = <BlendComponentModel>[];
    if (rawBlend is List) {
      for (final item in rawBlend) {
        if (item is Map) {
          blend.add(BlendComponentModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return CustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      blend: blend,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'notes': notes,
      'blend': blend.map((b) => b.toJson()).toList(),
    };
  }

  Customer toEntity() {
    return Customer(
      id: id,
      name: name,
      phone: phone,
      address: address,
      notes: notes,
      blend: blend.map((b) => b.toEntity()).toList(),
    );
  }
}

final class BlendComponentModel {
  const BlendComponentModel({
    required this.coffeeTypeId,
    required this.weightInGrams,
  });

  final String coffeeTypeId;
  final double weightInGrams;

  factory BlendComponentModel.fromEntity(BlendComponent entity) {
    return BlendComponentModel(
      coffeeTypeId: entity.coffeeTypeId,
      weightInGrams: entity.weightInGrams,
    );
  }

  factory BlendComponentModel.fromJson(Map<String, dynamic> json) {
    final coffeeTypeId = json['coffeeTypeId']?.toString() ?? '';

    // Support both old (percentage) and new (weightInGrams) formats
    double weightInGrams;
    if (json.containsKey('weightInGrams')) {
      weightInGrams = (json['weightInGrams'] as num?)?.toDouble() ?? 0;
    } else if (json.containsKey('percentage')) {
      // Migrate old percentage data: assume 100g total weight
      final oldPercentage = (json['percentage'] as num?)?.toDouble() ?? 0;
      weightInGrams = oldPercentage;
    } else {
      weightInGrams = 0;
    }

    return BlendComponentModel(
      coffeeTypeId: coffeeTypeId,
      weightInGrams: weightInGrams,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'coffeeTypeId': coffeeTypeId,
      'weightInGrams': weightInGrams,
    };
  }

  BlendComponent toEntity() {
    return BlendComponent(
      coffeeTypeId: coffeeTypeId,
      weightInGrams: weightInGrams,
    );
  }
}
