import 'package:equatable/equatable.dart';

import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';
import 'package:almazin_app/features/customers/domain/blend_component.dart';

/// Per-line breakdown after blend calculation.
class BlendLineResult extends Equatable {
  const BlendLineResult({
    required this.coffeeTypeId,
    required this.coffeeName,
    required this.weightInGrams,
    required this.calculatedPercentage,
    required this.lineCostEgp,
    required this.pricePerKilogram,
  });

  final String coffeeTypeId;
  final String coffeeName;
  final double weightInGrams;
  final double calculatedPercentage;
  final double lineCostEgp;
  final double pricePerKilogram;

  @override
  List<Object?> get props =>
      [coffeeTypeId, coffeeName, weightInGrams, calculatedPercentage, lineCostEgp, pricePerKilogram];
}

/// Complete blend calculation result.
class BlendCalculationResult extends Equatable {
  const BlendCalculationResult({
    required this.totalWeightGrams,
    required this.totalCostEgp,
    required this.averagePricePerKg,
    required this.lines,
  });

  final double totalWeightGrams;
  final double totalCostEgp;
  final double? averagePricePerKg;
  final List<BlendLineResult> lines;

  static const empty = BlendCalculationResult(
    totalWeightGrams: 0,
    totalCostEgp: 0,
    averagePricePerKg: null,
    lines: <BlendLineResult>[],
  );

  @override
  List<Object?> get props => [totalWeightGrams, totalCostEgp, averagePricePerKg, lines];
}

/// Reusable calculation engine for customer blends.
///
/// Takes weights in grams as primary input and computes:
/// - percentage per coffee type
/// - cost per coffee type
/// - total weight, total cost, average kilo price
final class BlendCalculationService {
  const BlendCalculationService();

  BlendCalculationResult calculate({
    required List<BlendComponent> components,
    required Map<String, CoffeeType> coffeesById,
  }) {
    if (components.isEmpty) return BlendCalculationResult.empty;

    final contributions = <_Contribution>[];
    var totalCost = 0.0;

    for (final component in components) {
      final coffee = coffeesById[component.coffeeTypeId];
      if (coffee == null) continue;

      final grams = component.weightInGrams;
      if (!grams.isFinite || grams <= 0) continue;

      final cost = (grams / 1000.0) * coffee.pricePerKilogram;
      if (!cost.isFinite) continue;

      totalCost += cost;
      contributions.add(
        _Contribution(
          coffee: coffee,
          grams: grams,
          cost: cost,
        ),
      );
    }

    if (contributions.isEmpty) return BlendCalculationResult.empty;

    final totalGrams = contributions.fold<double>(0, (sum, c) => sum + c.grams);
    final totalKg = totalGrams / 1000.0;
    final avg = totalKg > 0 ? (totalCost / totalKg) : null;

    final lines = contributions
        .map(
          (c) => BlendLineResult(
            coffeeTypeId: c.coffee.id,
            coffeeName: c.coffee.name,
            weightInGrams: c.grams,
            calculatedPercentage: totalGrams > 0 ? (c.grams / totalGrams) * 100 : 0,
            lineCostEgp: c.cost,
            pricePerKilogram: c.coffee.pricePerKilogram,
          ),
        )
        .toList(growable: false);

    return BlendCalculationResult(
      totalWeightGrams: totalGrams,
      totalCostEgp: totalCost,
      averagePricePerKg: avg,
      lines: lines,
    );
  }

  /// Scales a saved blend proportionally to a target weight.
  ///
  /// Example: saved blend [250g, 250g] → target 1000g → [500g, 500g]
  List<BlendComponent> scaleToTargetWeight({
    required List<BlendComponent> originalBlend,
    required double targetWeightGrams,
  }) {
    if (originalBlend.isEmpty || targetWeightGrams <= 0) return originalBlend;

    final currentTotal = originalBlend.fold<double>(0, (sum, c) => sum + c.weightInGrams);
    if (currentTotal <= 0) return originalBlend;

    final scaleFactor = targetWeightGrams / currentTotal;

    return originalBlend
        .map(
          (c) => BlendComponent(
            coffeeTypeId: c.coffeeTypeId,
            weightInGrams: c.weightInGrams * scaleFactor,
          ),
        )
        .toList(growable: false);
  }
}

final class _Contribution {
  const _Contribution({
    required this.coffee,
    required this.grams,
    required this.cost,
  });

  final CoffeeType coffee;
  final double grams;
  final double cost;
}
