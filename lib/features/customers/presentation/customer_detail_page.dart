import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:almazin_app/features/customers/presentation/cubit/customer_detail_cubit.dart';
import 'package:almazin_app/features/customers/presentation/cubit/customer_detail_state.dart';
import 'package:almazin_app/features/customers/presentation/widgets/customer_blend_section.dart';
import 'package:almazin_app/features/customers/presentation/widgets/customer_profile_section.dart';
import 'package:almazin_app/features/customers/presentation/widgets/customer_weight_calculator_section.dart';
import 'package:almazin_app/shared/widgets/dashboard_page.dart';

class CustomerDetailPage extends StatelessWidget {
  const CustomerDetailPage({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerDetailCubit, CustomerDetailState>(
      listenWhen: (previous, current) =>
          previous.snackbarMessage != current.snackbarMessage &&
          current.snackbarMessage != null,
      listener: (context, state) {
        final message = state.snackbarMessage;
        if (message == null) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        if (context.mounted) {
          context.read<CustomerDetailCubit>().clearSnackbar();
        }
      },
      child: BlocBuilder<CustomerDetailCubit, CustomerDetailState>(
        buildWhen: (a, b) => a.status != b.status || a.customer?.name != b.customer?.name,
        builder: (context, state) {
          if (state.status == CustomerDetailStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CustomerDetailStatus.notFound) {
            return Center(
              child: Text(
                'العميل غير موجود',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          if (state.status == CustomerDetailStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? 'حدث خطأ', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.read<CustomerDetailCubit>().load(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          }

          final name = state.customer?.name ?? '';

          return DashboardPage(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                FocusTraversalGroup(
                  child: Column(
                    children: const [
                      CustomerProfileSection(),
                      CustomerBlendSection(),
                      CustomerWeightCalculatorSection(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
