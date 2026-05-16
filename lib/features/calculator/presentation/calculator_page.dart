import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:almazin_app/features/calculator/presentation/cubit/direct_weight_calculator_cubit.dart';
import 'package:almazin_app/features/calculator/presentation/cubit/direct_weight_calculator_state.dart';
import 'package:almazin_app/features/calculator/presentation/widgets/calculator_line_row.dart';
import 'package:almazin_app/features/calculator/presentation/widgets/calculator_summary_card.dart';
import 'package:almazin_app/features/calculator/presentation/widgets/save_percentage_blend_dialog.dart';
import 'package:almazin_app/shared/widgets/app_button.dart';
import 'package:almazin_app/shared/widgets/app_section.dart';
import 'package:almazin_app/shared/widgets/dashboard_page.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DirectWeightCalculatorCubit, DirectWeightCalculatorState>(
      listenWhen: (previous, current) =>
          previous.snackbarMessage != current.snackbarMessage &&
          current.snackbarMessage != null,
      listener: (context, state) {
        final message = state.snackbarMessage;
        if (message == null) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        if (context.mounted) {
          context.read<DirectWeightCalculatorCubit>().clearSnackbar();
        }
      },
      child: BlocBuilder<DirectWeightCalculatorCubit, DirectWeightCalculatorState>(
        buildWhen: (a, b) =>
            a.status != b.status ||
            a.coffees != b.coffees ||
            a.lines != b.lines ||
            a.result != b.result ||
            a.errorMessage != b.errorMessage,
        builder: (context, state) {
          if (state.status == DirectWeightCalculatorStatus.loading &&
              state.coffees.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == DirectWeightCalculatorStatus.failure &&
              state.coffees.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? 'حدث خطأ', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.read<DirectWeightCalculatorCubit>().loadCoffees(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          }

          final cubit = context.read<DirectWeightCalculatorCubit>();

          return DashboardPage(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSection(
                  title: 'حاسبة التوليفة',
                  subtitle:
                      'أدخل أوزان كل صنف بالجرام (وليس بالنسب). يتم الحساب فوراً من أسعار الكيلو المحفوظة في «أسعار البن».',
                  child: const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    AppButton(
                      label: 'إضافة صنف',
                      icon: Icons.add,
                      variant: AppButtonVariant.primary,
                      onPressed: cubit.addLine,
                    ),
                    AppButton(
                      label: 'حفظ كتوليفة عميل',
                      icon: Icons.save_outlined,
                      variant: AppButtonVariant.secondary,
                      onPressed: () async {
                        final title = await showSavePercentageBlendDialog(context);
                        if (!context.mounted || title == null) return;
                        await cubit.saveCurrentAsPercentageBlend(title);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                CalculatorSummaryCard(result: state.result),
                const SizedBox(height: 14),
                Text(
                  'الأسطر',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                for (final line in state.lines) ...[
                  CalculatorLineRow(
                    lineId: line.id,
                    selectedCoffeeId: line.coffeeId,
                    weightInput: line.weightInput,
                    coffees: state.coffees,
                    canRemove: state.lines.length > 1,
                    onCoffeeChanged: (id) => cubit.setCoffee(line.id, id),
                    onWeightChanged: (raw) => cubit.setWeightInput(line.id, raw),
                    onRemove: () => cubit.removeLine(line.id),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
