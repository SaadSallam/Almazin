import 'package:flutter/material.dart';

import 'package:almazin_app/core/formatting/egp_format.dart';
import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';
import 'package:almazin_app/shared/widgets/app_card.dart';

class CoffeeTypeCard extends StatelessWidget {
  const CoffeeTypeCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final CoffeeType item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      EgpFormat.pricePerKilogram(item.pricePerKilogram),
                      style: textTheme.titleSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'آخر تحديث: ${EgpFormat.updatedAt(item.updatedAt)}',
                      style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'تعديل',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'حذف',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
