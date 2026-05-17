import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatting/egp_format.dart';
import '../../../../core/theme/theme_tokens_x.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../cubit/employee_detail_cubit.dart';
import '../cubit/employee_detail_state.dart';
import 'week_close_dialog.dart';

class PayrollSummary extends StatelessWidget {
  const PayrollSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeDetailCubit, EmployeeDetailState>(
      builder: (context, state) {
        final tokens = context.almazinTokens;
        final payroll = state.weeklyPayroll;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'ملخص الراتب الأسبوعي',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
                ),
                const Spacer(),
                if (!state.isWeekClosed)
                  AppButton(
                    label: 'إغلاق الأسبوع',
                    icon: Icons.lock_outline,
                    variant: AppButtonVariant.secondary,
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => const WeekCloseDialog(),
                      );
                      if (confirmed == true) {
                        context.read<EmployeeDetailCubit>().closeWeek();
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (payroll == null)
              Center(
                child: Text(
                  'لا يوجد ملخص لهذا الأسبوع',
                  style: TextStyle(color: tokens.textTertiary),
                ),
              )
            else
              Column(
                children: [
                  _SummaryRow(
                    label: 'إجمالي الساعات',
                    value: '${payroll.totalHours.toStringAsFixed(1)} ساعة',
                    icon: Icons.schedule,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'إجمالي الأجر',
                    value: formatEgp(payroll.grossPay),
                    icon: Icons.payments_outlined,
                    valueColor: tokens.successColor,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'السلف',
                    value: '- ${formatEgp(payroll.advances)}',
                    icon: Icons.money_off_outlined,
                    valueColor: tokens.warningColor,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'الخصومات',
                    value: '- ${formatEgp(payroll.deductions)}',
                    icon: Icons.remove_circle_outline,
                    valueColor: tokens.errorColor,
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'صافي الراتب',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: tokens.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          formatEgp(payroll.netPay),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: tokens.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (valueColor ?? tokens.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: valueColor ?? tokens.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: tokens.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor ?? tokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
