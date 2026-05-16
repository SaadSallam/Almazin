import 'package:equatable/equatable.dart';

import 'blend_component.dart';

class Customer extends Equatable {
  const Customer({
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
  final List<BlendComponent> blend;

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? notes,
    List<BlendComponent>? blend,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      blend: blend ?? this.blend,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, address, notes, blend];
}
