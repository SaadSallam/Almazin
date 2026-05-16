import 'package:equatable/equatable.dart';

import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';

/// One line of user input: selected coffee and weight in grams.
class DirectWeightLineInput extends Equatable {
  const DirectWeightLineInput({
    required this.coffeeId,
    required this.weightGrams,
  });

  final String coffeeId;
  final double weightGrams;

  @override
  List<Object?> get props => [coffeeId, weightGrams];
}

/// Per-line breakdown after calculation.
class DirectWeightLineBreakdown extends Equatable {
  const DirectWeightLineBreakdown({
    required this.coffeeId,
    required this.coffeeName,
    required this.weightGrams,
    required this.weightPercent,
    required this.lineCostEgp,
  });

  final String coffeeId;
  final String coffeeName;
  final double weightGrams;
  final double weightPercent;
  final double lineCostEgp;

  @override
  List<Object?> get props => [coffeeId, coffeeName, weightGrams, weightPercent, lineCostEgp];
}

/// Totals and per-line shares for a direct-weight blend.
class DirectWeightCalculatorResult extends Equatable {
  const DirectWeightCalculatorResult({
    required this.totalWeightGrams,
    required this.totalCostEgp,
    required this.averagePricePerKg,
    required this.lines,
  });

  final double totalWeightGrams;
  final double totalCostEgp;
  final double? averagePricePerKg;
  final List<DirectWeightLineBreakdown> lines;

  static const empty = DirectWeightCalculatorResult(
    totalWeightGrams: 0,
    totalCostEgp: 0,
    averagePricePerKg: null,
    lines: <DirectWeightLineBreakdown>[],
  );

  @override
  List<Object?> get props => [totalWeightGrams, totalCostEgp, averagePricePerKg, lines];
}

/// Pure calculator for أوزان مباشرة (grams) + أسعار الكيلو.
final class DirectWeightCalculatorService {
  const DirectWeightCalculatorService();

  DirectWeightCalculatorResult calculate({
    required List<DirectWeightLineInput> lines,
    required Map<String, CoffeeType> coffeesById,
  }) {
    final contributions = <_Contribution>[];

    for (final line in lines) {
      final coffee = coffeesById[line.coffeeId];
      if (coffee == null) continue;

      final grams = line.weightGrams;
      if (!grams.isFinite || grams <= 0) continue;

      final kg = grams / 1000.0;
      final cost = kg * coffee.pricePerKilogram;
      if (!cost.isFinite) continue;

      contributions.add(
        _Contribution(
          coffee: coffee,
          grams: grams,
          cost: cost,
        ),
      );
    }

    if (contributions.isEmpty) {
      return DirectWeightCalculatorResult.empty;
    }

    final totalGrams = contributions.fold<double>(0, (sum, c) => sum + c.grams);
    final totalCost = contributions.fold<double>(0, (sum, c) => sum + c.cost);
    final totalKg = totalGrams / 1000.0;

    final avg = totalKg > 0 ? (totalCost / totalKg) : null;

    final breakdowns = contributions
        .map(
          (c) => DirectWeightLineBreakdown(
            coffeeId: c.coffee.id,
            coffeeName: c.coffee.name,
            weightGrams: c.grams,
            weightPercent: totalGrams > 0 ? (c.grams / totalGrams) * 100 : 0,
            lineCostEgp: c.cost,
          ),
        )
        .toList(growable: false);

    return DirectWeightCalculatorResult(
      totalWeightGrams: totalGrams,
      totalCostEgp: totalCost,
      averagePricePerKg: avg,
      lines: breakdowns,
    );
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
