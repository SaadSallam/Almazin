import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme_tokens_x.dart';
import '../cubit/employee_detail_cubit.dart';
import '../cubit/employee_detail_state.dart';
import 'attendance_table.dart';
import 'advances_section.dart';
import 'payroll_summary.dart';
import 'employee_stats_section.dart';
import 'weekly_history_view.dart';

class EmployeeDetailTabs extends StatelessWidget {
  const EmployeeDetailTabs({
    super.key,
    required this.employeeId,
  });

  final String employeeId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeDetailCubit, EmployeeDetailState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TabBarWidget(
              selectedIndex: state.selectedTabIndex,
              onTabSelected: (index) {
                context.read<EmployeeDetailCubit>().setTabIndex(index);
              },
            ),
            const SizedBox(height: 16),
            IndexedStack(
              index: state.selectedTabIndex,
              children: const [
                AttendanceTable(),
                AdvancesSection(),
                PayrollSummary(),
                EmployeeStatsSection(),
                WeeklyHistoryView(),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TabBarWidget extends StatelessWidget {
  const _TabBarWidget({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  static const _tabs = ['الحضور', 'السلف', 'الرواتب', 'الإحصائيات', 'السجل'];

  @override
  Widget build(BuildContext context) {
    final tokens = context.almazinTokens;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: tokens.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? tokens.surfaceDefault : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: tokens.shadow.withOpacity(0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  _tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? tokens.textPrimary
                        : tokens.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
