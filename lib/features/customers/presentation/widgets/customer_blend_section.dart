import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:almazin_app/core/formatting/egp_format.dart';
import 'package:almazin_app/features/calculator/presentation/formatting/calculator_display_format.dart';
import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';
import 'package:almazin_app/features/customers/domain/blend_component.dart';
import 'package:almazin_app/features/customers/presentation/cubit/customer_detail_cubit.dart';
import 'package:almazin_app/features/customers/presentation/cubit/customer_detail_state.dart';
import 'package:almazin_app/shared/widgets/app_button.dart';
import 'package:almazin_app/shared/widgets/app_card.dart';
import 'package:almazin_app/shared/widgets/app_section.dart';

class CustomerBlendSection extends StatelessWidget {
  const CustomerBlendSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerDetailCubit, CustomerDetailState>(
      buildWhen: (a, b) =>
          a.customer != b.customer ||
          a.blendDraft != b.blendDraft ||
          a.coffees != b.coffees ||
          a.isSavingBlend != b.isSavingBlend ||
          a.weightResult != b.weightResult,
      builder: (context, state) {
        final customer = state.customer;
        if (customer == null) return const SizedBox.shrink();

        return AppSection(
          title: 'التوليفة',
          subtitle: 'أدخل الأوزان بالجرام. يتم حساب النسب والتكلفة تلقائياً.',
          spacingBefore: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (customer.blend.isNotEmpty) ...[
                _SavedBlendTable(
                  blend: customer.blend,
                  coffeesById: state.coffeesById,
                  result: state.weightResult,
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'تعديل التوليفة',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < state.blendDraft.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _BlendDraftRow(
                    index: i,
                    component: state.blendDraft[i],
                    coffees: state.coffees,
                    coffeesById: state.coffeesById,
                    canRemove: state.blendDraft.length > 1,
                    result: state.weightResult,
                  ),
                ),
              const SizedBox(height: 10),
              _BlendSummaryCard(result: state.weightResult),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  AppButton(
                    label: 'إضافة صنف',
                    icon: Icons.add,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.read<CustomerDetailCubit>().addBlendLine(),
                  ),
                  AppButton(
                    label: 'حفظ التوليفة',
                    icon: Icons.save_outlined,
                    variant: AppButtonVariant.primary,
                    onPressed: state.isSavingBlend
                        ? null
                        : () => context.read<CustomerDetailCubit>().saveBlend(),
                  ),
                ],
              ),
              if (state.isSavingBlend) ...[
                const SizedBox(height: 10),
                const LinearProgressIndicator(minHeight: 3),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SavedBlendTable extends StatelessWidget {
  const _SavedBlendTable({
    required this.blend,
    required this.coffeesById,
    required this.result,
  });

  final List<BlendComponent> blend;
  final Map<String, CoffeeType> coffeesById;
  final dynamic result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'التوليفة المحفوظة',
            style: textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          for (final c in blend)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      coffeesById[c.coffeeTypeId]?.name ?? '—',
                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    CalculatorDisplayFormat.grams(c.weightInGrams),
                    style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    EgpFormat.pricePerKilogram(
                      coffeesById[c.coffeeTypeId]?.pricePerKilogram ?? 0,
                    ),
                    style: textTheme.bodyMedium?.copyWith(color: scheme.primary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BlendDraftRow extends StatelessWidget {
  const _BlendDraftRow({
    required this.index,
    required this.component,
    required this.coffees,
    required this.coffeesById,
    required this.canRemove,
    required this.result,
  });

  final int index;
  final BlendComponent component;
  final List<CoffeeType> coffees;
  final Map<String, CoffeeType> coffeesById;
  final bool canRemove;
  final dynamic result;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CustomerDetailCubit>();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final lineResult = result.lines.where((l) => l.coffeeTypeId == component.coffeeTypeId);
    final calculatedPercent = lineResult.isEmpty ? 0 : lineResult.first.calculatedPercentage;
    final lineCost = lineResult.isEmpty ? 0 : lineResult.first.lineCostEgp;

    final coffeeMenu = LayoutBuilder(
      builder: (context, constraints) {
        return coffees.isEmpty
            ? const InputDecorator(
                decoration: InputDecoration(labelText: 'نوع البن'),
                child: Text('أضف أصنافاً من أسعار البن'),
              )
            : DropdownMenu<String?>(
                key: ValueKey('coffee_select_$index'),
                initialSelection: component.coffeeTypeId.isEmpty ? null : component.coffeeTypeId,
                label: const Text('نوع البن'),
                width: constraints.maxWidth,
                menuHeight: 240,
                onSelected: (id) => cubit.setBlendCoffee(index, id),
                dropdownMenuEntries: [
                  const DropdownMenuEntry<String?>(value: null, label: '— اختر —'),
                  for (final c in coffees)
                    DropdownMenuEntry<String?>(value: c.id, label: c.name),
                ],
              );
      },
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(flex: 5, child: coffeeMenu),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    key: ValueKey('blend_weight_$index'),
                    initialValue: component.weightInGrams > 0 ? component.weightInGrams.toString() : '',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'الوزن (g)',
                      suffixText: 'g',
                    ),
                    onChanged: (v) => cubit.setBlendWeightInput(index, v),
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                ),
                IconButton(
                  tooltip: 'حذف',
                  onPressed: canRemove ? () => cubit.removeBlendLine(index) : null,
                  icon: Icon(Icons.delete_outline, color: scheme.error),
                ),
              ],
            ),
            if (component.coffeeTypeId.isNotEmpty && component.weightInGrams > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'النسبة: ${CalculatorDisplayFormat.percent(calculatedPercent)}',
                      style: textTheme.bodySmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    'التكلفة: ${EgpFormat.pricePerKilogram(lineCost)}',
                    style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BlendSummaryCard extends StatelessWidget {
  const _BlendSummaryCard({required this.result});

  final dynamic result;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (result.lines.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ملخص التوليفة',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
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
                value: result.averagePricePerKg == null
                    ? '—'
                    : EgpFormat.pricePerKilogram(result.averagePricePerKg),
              ),
            ],
          ),
        ],
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
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
