import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatting/egp_format.dart';
import '../../../../core/theme/almazin_theme_tokens.dart';
import '../../../../core/theme/theme_tokens_x.dart';
import '../../domain/weekly_payroll.dart';
import '../cubit/employee_detail_cubit.dart';
import '../cubit/employee_detail_state.dart';

class WeeklyHistoryView extends StatelessWidget {
  const WeeklyHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeDetailCubit, EmployeeDetailState>(
      builder: (context, state) {
        final closed =
            state.payrolls.where((p) => p.closed).toList()
              ..sort((a, b) => b.weekStart.compareTo(a.weekStart));

        if (closed.isEmpty) {
          final tokens = context.almazinTokens;
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Text(
                'لا توجد أسابيع مغلقة بعد',
                style: TextStyle(color: tokens.textTertiary),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: closed.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return _HistoryCard(payroll: closed[index]);
          },
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.payroll});

  final WeeklyPayroll payroll;

  @override
  Widget build(BuildContext context) {
    final tokens = context.almazinTokens;
    final weekStart = payroll.weekStart;
    final weekEnd = payroll.weekEnd;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.surfaceDefault,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_outlined,
                  size: 16, color: tokens.textTertiary),
              const SizedBox(width: 8),
              Text(
                '${weekStart.day}/${weekStart.month}/${weekStart.year} - '
                '${weekEnd.day}/${weekEnd.month}/${weekEnd.year}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: tokens.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tokens.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'مغلق',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: tokens.successColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatLabel(
                label: 'الساعات',
                value: payroll.totalHours.toStringAsFixed(1),
                tokens: tokens,
              ),
              const SizedBox(width: 24),
              _StatLabel(
                label: 'الإجمالي',
                value: formatEgp(payroll.grossPay),
                tokens: tokens,
                color: tokens.successColor,
              ),
              const SizedBox(width: 24),
              _StatLabel(
                label: 'السلف',
                value: formatEgp(payroll.advances),
                tokens: tokens,
                color: tokens.warningColor,
              ),
              const SizedBox(width: 24),
              _StatLabel(
                label: 'الصافي',
                value: formatEgp(payroll.netPay),
                tokens: tokens,
                color: tokens.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatLabel extends StatelessWidget {
  const _StatLabel({
    required this.label,
    required this.value,
    required this.tokens,
    this.color,
  });

  final String label;
  final String value;
  final AlmazinThemeTokens tokens;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color ?? tokens.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: tokens.textTertiary,
          ),
        ),
      ],
    );
  }
}
