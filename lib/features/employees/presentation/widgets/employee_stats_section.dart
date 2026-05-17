import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatting/egp_format.dart';
import '../../../../core/theme/theme_tokens_x.dart';
import '../cubit/employee_detail_cubit.dart';
import '../cubit/employee_detail_state.dart';

class EmployeeStatsSection extends StatelessWidget {
  const EmployeeStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeDetailCubit, EmployeeDetailState>(
      builder: (context, state) {
        final tokens = context.almazinTokens;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'الإحصائيات',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'إجمالي الساعات هذا الأسبوع',
                    value: '${state.totalWeeklyHours.toStringAsFixed(1)} ساعة',
                    icon: Icons.schedule,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'إجمالي الأجر',
                    value: formatEgp(state.totalWeeklyGross),
                    icon: Icons.payments_outlined,
                    color: tokens.successColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'إجمالي السلف',
                    value: formatEgp(state.totalWeekAdvances),
                    icon: Icons.money_off_outlined,
                    color: tokens.warningColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'صافي الراتب',
                    value: formatEgp(state.netPay),
                    icon: Icons.account_balance_wallet_outlined,
                    color: tokens.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'أيام الحضور',
                    value: '${state.attendances.where((a) => a.isComplete).length} أيام',
                    icon: Icons.event_available_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'متوسط الساعات يومياً',
                    value: state.attendances.where((a) => a.isComplete).isEmpty
                        ? '0 ساعة'
                        : '${(state.totalWeeklyHours / state.attendances.where((a) => a.isComplete).length).toStringAsFixed(1)} ساعة',
                    icon: Icons.av_timer,
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.almazinTokens;
    final accentColor = color ?? tokens.primary;

    return Container(
      padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: tokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
