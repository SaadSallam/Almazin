import 'package:equatable/equatable.dart';

import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';
import 'package:almazin_app/features/customers/domain/blend_component.dart';

class BlendWeightLineResult extends Equatable {
  const BlendWeightLineResult({
    required this.coffeeTypeId,
    required this.coffeeName,
    required this.percentage,
    required this.weightGrams,
    required this.lineCostEgp,
    required this.pricePerKilogram,
  });

  final String coffeeTypeId;
  final String coffeeName;
  final double percentage;
  final double weightGrams;
  final double lineCostEgp;
  final double pricePerKilogram;

  @override
  List<Object?> get props =>
      [coffeeTypeId, coffeeName, percentage, weightGrams, lineCostEgp, pricePerKilogram];
}

class PercentageBlendWeightResult extends Equatable {
  const PercentageBlendWeightResult({
    required this.totalWeightGrams,
    required this.totalCostEgp,
    required this.averagePricePerKg,
    required this.lines,
  });

  final double totalWeightGrams;
  final double totalCostEgp;
  final double? averagePricePerKg;
  final List<BlendWeightLineResult> lines;

  static const empty = PercentageBlendWeightResult(
    totalWeightGrams: 0,
    totalCostEgp: 0,
    averagePricePerKg: null,
    lines: <BlendWeightLineResult>[],
  );

  @override
  List<Object?> get props => [totalWeightGrams, totalCostEgp, averagePricePerKg, lines];
}

/// Calculates per-type weights and costs from a percentage blend and target weight.
///
/// cost = (weightInGrams / 1000) * pricePerKilogram
final class PercentageBlendWeightCalculatorService {
  const PercentageBlendWeightCalculatorService();

  PercentageBlendWeightResult calculate({
    required List<BlendComponent> blend,
    required double targetWeightGrams,
    required Map<String, CoffeeType> coffeesById,
  }) {
    if (!targetWeightGrams.isFinite || targetWeightGrams <= 0 || blend.isEmpty) {
      return PercentageBlendWeightResult.empty;
    }

    final lines = <BlendWeightLineResult>[];
    var totalCost = 0.0;

    for (final component in blend) {
      final coffee = coffeesById[component.coffeeTypeId];
      if (coffee == null) continue;

      final grams = targetWeightGrams * (component.percentage / 100.0);
      if (!grams.isFinite || grams <= 0) continue;

      final cost = (grams / 1000.0) * coffee.pricePerKilogram;
      if (!cost.isFinite) continue;

      totalCost += cost;
      lines.add(
        BlendWeightLineResult(
          coffeeTypeId: coffee.id,
          coffeeName: coffee.name,
          percentage: component.percentage,
          weightGrams: grams,
          lineCostEgp: cost,
          pricePerKilogram: coffee.pricePerKilogram,
        ),
      );
    }

    if (lines.isEmpty) {
      return PercentageBlendWeightResult.empty;
    }

    final totalKg = targetWeightGrams / 1000.0;
    final avg = totalKg > 0 ? totalCost / totalKg : null;

    return PercentageBlendWeightResult(
      totalWeightGrams: targetWeightGrams,
      totalCostEgp: totalCost,
      averagePricePerKg: avg,
      lines: lines,
    );
  }
}
