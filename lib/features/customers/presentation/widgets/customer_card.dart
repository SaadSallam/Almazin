import 'package:flutter/material.dart';

import 'package:almazin_app/features/customers/domain/blend_summary_formatter.dart';
import 'package:almazin_app/features/customers/domain/customer.dart';
import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';
import 'package:almazin_app/shared/widgets/app_card.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    required this.coffeesById,
    required this.onTap,
    required this.onDelete,
  });

  final Customer customer;
  final Map<String, CoffeeType> coffeesById;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final blendSummary = BlendSummaryFormatter.format(
      blend: customer.blend,
      coffeesById: coffeesById,
    );

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (customer.phone.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    customer.phone,
                    style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  blendSummary,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'حذف',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
