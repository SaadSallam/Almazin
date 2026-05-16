import 'package:flutter/material.dart';

import 'package:almazin_app/core/formatting/egp_format.dart';
import 'package:almazin_app/features/calculator/domain/direct_weight_calculator_service.dart';
import 'package:almazin_app/features/calculator/presentation/formatting/calculator_display_format.dart';

class CalculatorSummaryCard extends StatelessWidget {
  const CalculatorSummaryCard({
    super.key,
    required this.result,
  });

  final DirectWeightCalculatorResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final avg = result.averagePricePerKg;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'الملخص',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SummaryTile(
                  label: 'إجمالي الوزن',
                  value: CalculatorDisplayFormat.grams(result.totalWeightGrams),
                ),
                _SummaryTile(
                  label: 'التكلفة الإجمالية',
                  value: EgpFormat.pricePerKilogram(result.totalCostEgp),
                ),
                _SummaryTile(
                  label: 'متوسط سعر الكيلو',
                  value: avg == null ? '—' : EgpFormat.pricePerKilogram(avg),
                ),
              ],
            ),
            if (result.lines.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'النسب التلقائية (من الأوزان)',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outline.withValues(alpha: 0.25)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      for (final line in result.lines)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  line.coffeeName,
                                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Text(
                                CalculatorDisplayFormat.percent(line.weightPercent),
                                style: textTheme.bodyLarge?.copyWith(color: scheme.primary),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
