import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';
import 'package:almazin_app/features/customers/domain/blend_component.dart';

/// Builds a short Arabic summary for list cards.
abstract final class BlendSummaryFormatter {
  static String format({
    required List<BlendComponent> blend,
    required Map<String, CoffeeType> coffeesById,
    int maxParts = 3,
  }) {
    if (blend.isEmpty) return 'لا توجد توليفة';

    final parts = <String>[];
    for (final c in blend) {
      final name = coffeesById[c.coffeeTypeId]?.name ?? '—';
      parts.add('$name ${c.weightInGrams.toStringAsFixed(0)}g');
      if (parts.length >= maxParts) break;
    }

    final suffix = blend.length > maxParts ? ' …' : '';
    return parts.join(' · ') + suffix;
  }
}
