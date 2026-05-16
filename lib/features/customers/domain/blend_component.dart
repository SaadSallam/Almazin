import 'package:equatable/equatable.dart';

/// One line of a customer's saved blend.
///
/// weightInGrams is the primary source of truth.
/// percentage is computed automatically from weights.
class BlendComponent extends Equatable {
  const BlendComponent({
    required this.coffeeTypeId,
    required this.weightInGrams,
  });

  final String coffeeTypeId;
  final double weightInGrams;

  /// Computed percentage from weight (requires total weight for accuracy).
  /// For display purposes only - use BlendCalculationService for precise values.
  double get percentage => weightInGrams;

  BlendComponent copyWith({
    String? coffeeTypeId,
    double? weightInGrams,
  }) {
    return BlendComponent(
      coffeeTypeId: coffeeTypeId ?? this.coffeeTypeId,
      weightInGrams: weightInGrams ?? this.weightInGrams,
    );
  }

  @override
  List<Object?> get props => [coffeeTypeId, weightInGrams];
}
