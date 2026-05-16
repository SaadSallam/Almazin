import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:almazin_app/core/formatting/egp_format.dart';
import 'package:almazin_app/features/calculator/presentation/formatting/calculator_display_format.dart';
import 'package:almazin_app/features/customers/domain/blend_calculation_service.dart';
import 'package:almazin_app/features/customers/presentation/cubit/customer_detail_cubit.dart';
import 'package:almazin_app/features/customers/presentation/cubit/customer_detail_state.dart';
import 'package:almazin_app/shared/widgets/app_button.dart';
import 'package:almazin_app/shared/widgets/app_card.dart';
import 'package:almazin_app/shared/widgets/app_section.dart';

class CustomerWeightCalculatorSection extends StatelessWidget {
  const CustomerWeightCalculatorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerDetailCubit, CustomerDetailState>(
      buildWhen: (a, b) =>
          a.customer != b.customer ||
          a.weightInput != b.weightInput ||
          a.weightResult != b.weightResult,
      builder: (context, state) {
        final customer = state.customer;
        if (customer == null) return const SizedBox.shrink();

        final cubit = context.read<CustomerDetailCubit>();
        final hasSavedBlend = customer.blend.isNotEmpty;

        return AppSection(
          title: 'حاسبة الوزن',
          subtitle: 'أدخل الوزن المطلوب بالجرام لتوسيع التوليفة المحفوظة بنفس النسب.',
          spacingBefore: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!hasSavedBlend)
                AppCard(
                  child: Text(
                    'احفظ توليفة أولاً لاستخدام الحاسبة.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else ...[
                _WeightInputField(
                  key: ValueKey('weight_field_${customer.id}'),
                  value: state.weightInput,
                  onChanged: cubit.setWeightInput,
                  onSubmitted: (_) => cubit.calculateScaledBlend(),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppButton(
                      label: 'احسب',
                      icon: Icons.calculate_outlined,
                      variant: AppButtonVariant.primary,
                      onPressed: cubit.calculateScaledBlend,
                    ),
                    _QuickWeightChip(label: '250g', onTap: () => cubit.setQuickWeightGrams(250)),
                    _QuickWeightChip(label: '500g', onTap: () => cubit.setQuickWeightGrams(500)),
                    _QuickWeightChip(label: '1kg', onTap: () => cubit.setQuickWeightGrams(1000)),
                  ],
                ),
                const SizedBox(height: 14),
                _WeightResultCard(result: state.weightResult),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _WeightInputField extends StatefulWidget {
  const _WeightInputField({
    super.key,
    required this.value,
    required this.onChanged,
    this.onSubmitted,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_WeightInputField> createState() => _WeightInputFieldState();
}

class _WeightInputFieldState extends State<_WeightInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _WeightInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'الوزن المطلوب (g)',
        hintText: 'مثال: 500 أو 1000',
      ),
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
    );
  }
}

class _QuickWeightChip extends StatelessWidget {
  const _QuickWeightChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _WeightResultCard extends StatelessWidget {
  const _WeightResultCard({required this.result});

  final BlendCalculationResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (result.lines.isEmpty) {
      return AppCard(
        child: Text(
          'أدخل وزناً صالحاً لعرض النتائج.',
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      );
    }

    final avg = result.averagePricePerKg;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _Metric(label: 'إجمالي الوزن', value: CalculatorDisplayFormat.grams(result.totalWeightGrams)),
              _Metric(
                label: 'التكلفة الإجمالية',
                value: EgpFormat.pricePerKilogram(result.totalCostEgp),
              ),
              _Metric(
                label: 'متوسط سعر الكيلو',
                value: avg == null ? '—' : EgpFormat.pricePerKilogram(avg),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                    CalculatorDisplayFormat.grams(line.weightInGrams),
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    EgpFormat.pricePerKilogram(line.lineCostEgp),
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

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
