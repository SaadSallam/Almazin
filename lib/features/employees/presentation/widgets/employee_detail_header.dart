import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/formatting/egp_format.dart';
import '../../../../core/theme/theme_tokens_x.dart';
import '../cubit/employee_detail_cubit.dart';
import '../cubit/employee_detail_state.dart';
import 'employee_avatar.dart';

class EmployeeDetailHeader extends StatelessWidget {
  const EmployeeDetailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeDetailCubit, EmployeeDetailState>(
      builder: (context, state) {
        final employee = state.employee;
        if (employee == null) return const SizedBox.shrink();

        final tokens = context.almazinTokens;
        final weekStart = state.weekStart!;
        final weekEnd = state.weekEnd!;

        return Row(
          children: [
            EmployeeAvatar(
              initials: employee.initials,
              size: 56,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'سعر الساعة: ${formatEgp(employee.hourlyRate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _WeekNavigation(
              weekStart: weekStart,
              weekEnd: weekEnd,
              isClosed: state.isWeekClosed,
            ),
          ],
        );
      },
    );
  }
}

class _WeekNavigation extends StatelessWidget {
  const _WeekNavigation({
    required this.weekStart,
    required this.weekEnd,
    required this.isClosed,
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final bool isClosed;

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.almazinTokens;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            final previous = weekStart.subtract(const Duration(days: 7));
            context.read<EmployeeDetailCubit>().setWeek(previous);
          },
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: tokens.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                '${_formatDate(weekStart)} - ${_formatDate(weekEnd)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: tokens.textPrimary,
                ),
              ),
              if (isClosed)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: tokens.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'مغلق',
                    style: TextStyle(
                      fontSize: 11,
                      color: tokens.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            final next = weekStart.add(const Duration(days: 7));
            context.read<EmployeeDetailCubit>().setWeek(next);
          },
        ),
      ],
    );
  }
}
