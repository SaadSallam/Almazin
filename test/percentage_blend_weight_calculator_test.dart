import 'package:flutter_test/flutter_test.dart';

import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';
import 'package:almazin_app/features/customers/domain/blend_calculation_service.dart';
import 'package:almazin_app/features/customers/domain/blend_component.dart';
import 'package:almazin_app/features/customers/domain/blend_validator.dart';

void main() {
  const service = BlendCalculationService();

  final coffees = {
    'a': CoffeeType(
      id: 'a',
      name: 'برازيلي',
      pricePerKilogram: 100,
      notes: '',
      updatedAt: DateTime(2024),
    ),
    'b': CoffeeType(
      id: 'b',
      name: 'حبشي',
      pricePerKilogram: 200,
      notes: '',
      updatedAt: DateTime(2024),
    ),
  };

  test('calculates percentages and costs from weights', () {
    const blend = [
      BlendComponent(coffeeTypeId: 'a', weightInGrams: 400),
      BlendComponent(coffeeTypeId: 'b', weightInGrams: 600),
    ];

    final result = service.calculate(
      components: blend,
      coffeesById: coffees,
    );

    expect(result.totalWeightGrams, 1000);
    expect(result.lines.length, 2);
    expect(result.lines[0].weightInGrams, 400);
    expect(result.lines[1].weightInGrams, 600);
    expect(result.lines[0].calculatedPercentage, closeTo(40, 0.001));
    expect(result.lines[1].calculatedPercentage, closeTo(60, 0.001));
    expect(result.lines[0].lineCostEgp, closeTo(40, 0.001));
    expect(result.lines[1].lineCostEgp, closeTo(120, 0.001));
    expect(result.totalCostEgp, closeTo(160, 0.001));
    expect(result.averagePricePerKg, closeTo(160, 0.001));
  });

  test('blend validator requires at least one valid weight', () {
    expect(
      () => BlendValidator.validateComponents(const [
        BlendComponent(coffeeTypeId: 'a', weightInGrams: 0),
        BlendComponent(coffeeTypeId: 'b', weightInGrams: 0),
      ]),
      throwsA(isA<BlendValidationException>()),
    );
  });

  test('scaleToTargetWeight scales proportionally', () {
    const originalBlend = [
      BlendComponent(coffeeTypeId: 'a', weightInGrams: 250),
      BlendComponent(coffeeTypeId: 'b', weightInGrams: 250),
    ];

    final scaled = service.scaleToTargetWeight(
      originalBlend: originalBlend,
      targetWeightGrams: 1000,
    );

    expect(scaled.length, 2);
    expect(scaled[0].weightInGrams, 500);
    expect(scaled[1].weightInGrams, 500);
  });
}
