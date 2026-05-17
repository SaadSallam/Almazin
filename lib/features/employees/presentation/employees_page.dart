import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/formatting/egp_format.dart';
import '../../../../core/navigation/app_paths.dart';
import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/theme/theme_tokens_x.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_search_field.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/dashboard_page.dart';
import '../domain/employee.dart';
import '../domain/payroll_calculation_service.dart';
import 'cubit/employees_list_cubit.dart';
import 'cubit/employees_list_state.dart';
import 'widgets/employee_avatar.dart';
import 'widgets/employee_stats_card.dart';
import 'widgets/week_selector.dart';
import 'widgets/add_employee_dialog.dart';

class EmployeesPage extends StatelessWidget {
  const EmployeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmployeesListCubit, EmployeesListState>(
      listenWhen: (prev, curr) =>
          prev.snackbarMessage != curr.snackbarMessage &&
          curr.snackbarMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.snackbarMessage!)),
        );
        context.read<EmployeesListCubit>().clearSnackbar();
      },
      child: BlocBuilder<EmployeesListCubit, EmployeesListState>(
        buildWhen: (prev, curr) =>
            prev.status != curr.status ||
            prev.employees != curr.employees ||
            prev.searchQuery != curr.searchQuery ||
            prev.weekStart != curr.weekStart,
        builder: (context, state) {
          if (state.status == EmployeesListStatus.initial ||
              state.status == EmployeesListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == EmployeesListStatus.failure) {
            return AppErrorState(
              message: state.errorMessage ?? 'حدث خطأ غير متوقع',
              onRetry: () => context.read<EmployeesListCubit>().load(),
            );
          }

          return DashboardPage(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(
                  weekStart: state.weekStart!,
                  onWeekChanged: (newWeek) {
                    context.read<EmployeesListCubit>().setWeekStart(newWeek);
                  },
                  onSearchChanged: (query) {
                    context.read<EmployeesListCubit>().setSearchQuery(query);
                  },
                  onAddEmployee: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (_) => BlocProvider.value(
                        value: context.read<EmployeesListCubit>(),
                        child: const AddEmployeeDialog(),
                      ),
                    );
                    if (result == true && context.mounted) {
                      context.read<EmployeesListCubit>().load();
                    }
                  },
                  onExport: () async {
                    final json = await context.read<EmployeesListCubit>().exportData();
                    if (!context.mounted) return;
                    await showDialog(
                      context: context,
                      builder: (_) => _DataDialog(
                        title: 'تصدير البيانات',
                        content: json,
                        isExport: true,
                      ),
                    );
                  },
                  onImport: () async {
                    if (!context.mounted) return;
                    final result = await showDialog<String>(
                      context: context,
                      builder: (_) => const _DataDialog(
                        title: 'استيراد البيانات',
                        isExport: false,
                      ),
                    );
                    if (result != null && context.mounted) {
                      context.read<EmployeesListCubit>().importData(result);
                    }
                  },
                ),
                const SizedBox(height: 24),
                _StatsCards(employees: state.employees),
                const SizedBox(height: 24),
                _EmployeeGrid(
                  employees: state.filteredEmployees,
                  weekStart: state.weekStart!,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.weekStart,
    required this.onWeekChanged,
    required this.onSearchChanged,
    required this.onAddEmployee,
    required this.onExport,
    required this.onImport,
  });

  final DateTime weekStart;
  final ValueChanged<DateTime> onWeekChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddEmployee;
  final VoidCallback onExport;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final tokens = context.almazinTokens;

    return Row(
      children: [
        Expanded(
          child: WeekSelector(
            weekStart: weekStart,
            onPrevious: () => onWeekChanged(
              PayrollCalculationService.getPreviousWeekStart(weekStart),
            ),
            onNext: () => onWeekChanged(
              PayrollCalculationService.getNextWeekStart(weekStart),
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: context.isDesktop ? 320 : 200,
          child: AppSearchField(
            onChanged: onSearchChanged,
            hintText: 'بحث عن موظف...',
          ),
        ),
        const SizedBox(width: 12),
        AppButton(
          label: 'إضافة موظف',
          icon: Icons.person_add_outlined,
          onPressed: onAddEmployee,
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: Icon(Icons.settings_outlined, color: tokens.textSecondary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'export') onExport();
            if (value == 'import') onImport();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.file_download_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('تصدير البيانات'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'import',
              child: Row(
                children: [
                  Icon(Icons.file_upload_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('استيراد البيانات'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsCards extends StatelessWidget {
  const _StatsCards({required this.employees});

  final List<Employee> employees;

  @override
  Widget build(BuildContext context) {
    final totalEmployees = employees.length;
    final activeEmployees = employees.where((e) => e.active).length;

    return Row(
      children: [
        Expanded(
          child: EmployeeStatsCard(
            title: 'إجمالي الموظفين',
            value: totalEmployees.toString(),
            icon: Icons.people_alt_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: EmployeeStatsCard(
            title: 'موظفين نشطين',
            value: activeEmployees.toString(),
            icon: Icons.check_circle_outline,
            color: context.almazinTokens.successColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: EmployeeStatsCard(
            title: 'إجمالي الرواتب الأسبوعية',
            value: '0 ج.م',
            icon: Icons.payments_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: EmployeeStatsCard(
            title: 'إجمالي السلف',
            value: '0 ج.م',
            icon: Icons.money_off_outlined,
            color: context.almazinTokens.warningColor,
          ),
        ),
      ],
    );
  }
}

class _EmployeeGrid extends StatelessWidget {
  const _EmployeeGrid({
    required this.employees,
    required this.weekStart,
  });

  final List<Employee> employees;
  final DateTime weekStart;

  @override
  Widget build(BuildContext context) {
    if (employees.isEmpty) {
      return _EmptyState(
        onAddEmployee: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (_) => BlocProvider.value(
              value: context.read<EmployeesListCubit>(),
              child: const AddEmployeeDialog(),
            ),
          );
          if (result == true && context.mounted) {
            context.read<EmployeesListCubit>().load();
          }
        },
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return _EmployeeCard(
          employee: employee,
          onTap: () {
            context.push(
              '${AppPaths.employees}/${employee.id}',
              extra: weekStart,
            );
          },
        );
      },
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({
    required this.employee,
    required this.onTap,
  });

  final Employee employee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.almazinTokens;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          EmployeeAvatar(
            initials: employee.initials,
            size: 48,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  employee.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatEgp(employee.hourlyRate)} / ساعة',
                  style: TextStyle(
                    fontSize: 13,
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 18, color: tokens.textTertiary),
            tooltip: 'تعديل',
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: context.read<EmployeesListCubit>(),
                  child: AddEmployeeDialog(employee: employee),
                ),
              );
              if (result == true && context.mounted) {
                context.read<EmployeesListCubit>().load();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 18, color: tokens.errorColor),
            tooltip: 'حذف',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text('حذف الموظف'),
                  content: Text('هل أنت متأكد من حذف "${employee.name}"؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text('حذف', style: TextStyle(color: tokens.errorColor)),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                context.read<EmployeesListCubit>().deleteEmployee(employee.id);
              }
            },
          ),
          Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: tokens.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddEmployee});

  final VoidCallback onAddEmployee;

  @override
  Widget build(BuildContext context) {
    final tokens = context.almazinTokens;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: tokens.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 44,
                color: tokens.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا يوجد موظفين',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'قم بإضافة موظف جديد لبدء تسجيل\nالحضور والرواتب الأسبوعية',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: tokens.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'إضافة موظف',
              icon: Icons.person_add_outlined,
              onPressed: onAddEmployee,
            ),
          ],
        ),
      ),
    );
  }
}

class _DataDialog extends StatefulWidget {
  const _DataDialog({
    required this.title,
    this.content,
    required this.isExport,
  });

  final String title;
  final String? content;
  final bool isExport;

  @override
  State<_DataDialog> createState() => _DataDialogState();
}

class _DataDialogState extends State<_DataDialog> {
  late final TextEditingController _controller;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.almazinTokens;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 560,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 12,
              readOnly: widget.isExport,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
                hintText: widget.isExport ? null : 'الصق بيانات JSON هنا',
              ),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.isExport)
                  Expanded(
                    child: AppButton(
                      label: _copied ? 'تم النسخ' : 'نسخ',
                      icon: _copied ? Icons.check : Icons.copy,
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: _controller.text),
                        );
                        setState(() => _copied = true);
                        Future.delayed(
                          const Duration(seconds: 2),
                          () {
                            if (mounted) setState(() => _copied = false);
                          },
                        );
                      },
                    ),
                  ),
                if (!widget.isExport) ...[
                  Expanded(
                    child: AppButton(
                      label: 'إلغاء',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'استيراد',
                      onPressed: () =>
                          Navigator.of(context).pop(_controller.text),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
