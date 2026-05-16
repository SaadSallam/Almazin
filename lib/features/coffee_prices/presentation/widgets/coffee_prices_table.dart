import 'package:flutter/material.dart';

import 'package:almazin_app/core/formatting/egp_format.dart';
import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';

class CoffeePricesTable extends StatelessWidget {
  const CoffeePricesTable({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  final List<CoffeeType> items;
  final ValueChanged<CoffeeType> onEdit;
  final ValueChanged<CoffeeType> onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(
            scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          ),
          dataRowMinHeight: 56,
          horizontalMargin: 16,
          columns: const [
            DataColumn(label: Text('اسم البن')),
            DataColumn(label: Text('سعر الكيلو')),
            DataColumn(label: Text('آخر تحديث')),
            DataColumn(label: Text('إجراءات')),
          ],
          rows: [
            for (final item in items)
              DataRow(
                cells: [
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Text(
                        item.name,
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      EgpFormat.pricePerKilogram(item.pricePerKilogram),
                      style: textTheme.titleSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      EgpFormat.updatedAt(item.updatedAt),
                      style: textTheme.bodySmall,
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'تعديل',
                          onPressed: () => onEdit(item),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'حذف',
                          onPressed: () => onDelete(item),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
