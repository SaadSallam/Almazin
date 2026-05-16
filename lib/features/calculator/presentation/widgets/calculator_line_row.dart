import 'package:flutter/material.dart';

import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';

class CalculatorLineRow extends StatefulWidget {
  const CalculatorLineRow({
    super.key,
    required this.lineId,
    required this.selectedCoffeeId,
    required this.weightInput,
    required this.coffees,
    required this.canRemove,
    required this.onCoffeeChanged,
    required this.onWeightChanged,
    required this.onRemove,
  });

  final String lineId;
  final String? selectedCoffeeId;
  final String weightInput;
  final List<CoffeeType> coffees;
  final bool canRemove;
  final ValueChanged<String?> onCoffeeChanged;
  final ValueChanged<String> onWeightChanged;
  final VoidCallback onRemove;

  @override
  State<CalculatorLineRow> createState() => _CalculatorLineRowState();
}

class _CalculatorLineRowState extends State<CalculatorLineRow> {
  late TextEditingController _weight;

  @override
  void initState() {
    super.initState();
    _weight = TextEditingController(text: widget.weightInput);
  }

  @override
  void didUpdateWidget(covariant CalculatorLineRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lineId != widget.lineId) {
      _weight.dispose();
      _weight = TextEditingController(text: widget.weightInput);
    }
  }

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  String? _effectiveCoffeeId() {
    final id = widget.selectedCoffeeId;
    if (id == null) return null;
    final exists = widget.coffees.any((c) => c.id == id);
    return exists ? id : null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final coffeeField = widget.coffees.isEmpty
        ? InputDecorator(
            decoration: const InputDecoration(
              labelText: 'نوع البن',
              border: OutlineInputBorder(),
            ),
            child: Text(
              'لا توجد أصناف. أضف أصنافاً من شاشة أسعار البن.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        : LayoutBuilder(
            builder: (context, constraints) {
              return DropdownMenu<String?>(
                key: ValueKey<Object>(
                  '${widget.lineId}_${widget.selectedCoffeeId}_${widget.coffees.length}',
                ),
                initialSelection: _effectiveCoffeeId(),
                label: const Text('نوع البن'),
                width: constraints.maxWidth,
                menuHeight: 240,
                onSelected: widget.onCoffeeChanged,
                dropdownMenuEntries: [
                  const DropdownMenuEntry<String?>(
                    value: null,
                    label: '— اختر —',
                  ),
                  for (final c in widget.coffees)
                    DropdownMenuEntry<String?>(
                      value: c.id,
                      label: c.name,
                    ),
                ],
              );
            },
          );

    final weightField = TextFormField(
      controller: _weight,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'الوزن (g)',
        hintText: 'مثال: 250',
      ),
      onChanged: widget.onWeightChanged,
    );

    final remove = IconButton(
      tooltip: 'حذف السطر',
      onPressed: widget.canRemove ? widget.onRemove : null,
      icon: const Icon(Icons.delete_outline),
      color: scheme.error,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 520;

            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  coffeeField,
                  const SizedBox(height: 10),
                  weightField,
                  Align(alignment: AlignmentDirectional.centerEnd, child: remove),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: coffeeField),
                const SizedBox(width: 12),
                Expanded(flex: 3, child: weightField),
                remove,
              ],
            );
          },
        ),
      ),
    );
  }
}
