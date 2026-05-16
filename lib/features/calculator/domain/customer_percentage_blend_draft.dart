import 'package:equatable/equatable.dart';

class BlendPercentComponent extends Equatable {
  const BlendPercentComponent({
    required this.coffeeId,
    required this.percent,
  });

  final String coffeeId;
  final double percent;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'coffeeId': coffeeId,
        'percent': percent,
      };

  factory BlendPercentComponent.fromJson(Map<String, dynamic> json) {
    return BlendPercentComponent(
      coffeeId: json['coffeeId']?.toString() ?? '',
      percent: (json['percent'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [coffeeId, percent];
}

/// Saved recipe expressed in percentages (converted from direct weights).
class CustomerPercentageBlendDraft extends Equatable {
  const CustomerPercentageBlendDraft({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.components,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final List<BlendPercentComponent> components;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'components': components.map((c) => c.toJson()).toList(),
    };
  }

  factory CustomerPercentageBlendDraft.fromJson(Map<String, dynamic> json) {
    final raw = json['components'];
    final comps = <BlendPercentComponent>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          comps.add(BlendPercentComponent.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return CustomerPercentageBlendDraft(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      components: comps,
    );
  }

  @override
  List<Object?> get props => [id, title, createdAt, components];
}
