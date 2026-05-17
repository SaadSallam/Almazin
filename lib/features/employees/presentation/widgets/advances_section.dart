import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatting/egp_format.dart';
import '../../../../core/theme/theme_tokens_x.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/advance.dart';
import '../cubit/employee_detail_cubit.dart';
import '../cubit/employee_detail_state.dart';
import 'add_advance_dialog.dart';

class AdvancesSection extends StatelessWidget {
  const AdvancesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeDetailCubit, EmployeeDetailState>(
      builder: (context, state) {
        final tokens = context.almazinTokens;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'السلف',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
                ),
                const Spacer(),
                AppButton(
                  label: 'إضافة سلفة',
                  icon: Icons.add,
                  size: AppButtonSize.small,
                  onPressed: () async {
                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (_) => const AddAdvanceDialog(),
                    );
                    if (result != null) {
                      final advance = Advance(
                        id: '',
                        employeeId: state.employee!.id,
                        amount: result['amount'] as double,
                        reason: result['reason'] as String?,
                        createdAt: DateTime.now(),
                      );
                      context.read<EmployeeDetailCubit>().addAdvance(advance);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state.advances.isEmpty)
              Center(
                child: Text(
                  'لا توجد سلف لهذا الأسبوع',
                  style: TextStyle(color: tokens.textTertiary),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.advances.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                    final advance = state.advances[index];
                    return _AdvanceCard(
                      advance: advance,
                      onDelete: () => context
                          .read<EmployeeDetailCubit>()
                          .deleteAdvance(advance.id),
                    );
                  },
                ),
          ],
        );
      },
    );
  }
}

class _AdvanceCard extends StatelessWidget {
  const _AdvanceCard({
    required this.advance,
    required this.onDelete,
  });

  final Advance advance;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.almazinTokens;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.surfaceDefault,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tokens.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.money_off_outlined,
              color: tokens.warningColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatEgp(advance.amount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),
                if (advance.reason != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    advance.reason!,
                    style: TextStyle(
                      fontSize: 13,
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${advance.createdAt.day}/${advance.createdAt.month}',
            style: TextStyle(
              fontSize: 13,
              color: tokens.textTertiary,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 18, color: tokens.errorColor),
            onPressed: onDelete,
            tooltip: 'حذف',
          ),
        ],
      ),
    );
  }
}
