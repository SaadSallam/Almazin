import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/dashboard_page.dart';
import 'cubit/employee_detail_cubit.dart';
import 'cubit/employee_detail_state.dart';
import 'widgets/employee_detail_header.dart';
import 'widgets/employee_detail_tabs.dart';

class EmployeeDetailPage extends StatelessWidget {
  const EmployeeDetailPage({
    super.key,
    required this.employeeId,
  });

  final String employeeId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmployeeDetailCubit, EmployeeDetailState>(
        listenWhen: (prev, curr) =>
            prev.snackbarMessage != curr.snackbarMessage &&
            curr.snackbarMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.snackbarMessage!)),
          );
          context.read<EmployeeDetailCubit>().clearSnackbar();
        },
        child: BlocBuilder<EmployeeDetailCubit, EmployeeDetailState>(
          builder: (context, state) {
            if (state.status == EmployeeDetailStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == EmployeeDetailStatus.failure) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(state.errorMessage ?? 'حدث خطأ'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<EmployeeDetailCubit>().load(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            return DashboardPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const EmployeeDetailHeader(),
                  const SizedBox(height: 24),
                  EmployeeDetailTabs(
                    employeeId: employeeId,
                  ),
                ],
              ),
            );
          },
        ),
    );
  }
}
