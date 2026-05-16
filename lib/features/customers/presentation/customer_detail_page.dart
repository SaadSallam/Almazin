import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:almazin_app/core/theme/almazin_theme_tokens.dart';
import 'package:almazin_app/core/theme/app_spacing.dart';
import 'package:almazin_app/features/customers/presentation/cubit/customer_detail_cubit.dart';
import 'package:almazin_app/features/customers/presentation/cubit/customer_detail_state.dart';
import 'package:almazin_app/features/customers/presentation/widgets/customer_blend_section.dart';
import 'package:almazin_app/features/customers/presentation/widgets/customer_profile_section.dart';
import 'package:almazin_app/features/customers/presentation/widgets/customer_weight_calculator_section.dart';
import 'package:almazin_app/shared/widgets/app_states.dart';
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
            return const AppEmptyState(
              message: 'العميل غير موجود',
              icon: Icons.person_off_rounded,
            );
          }

          if (state.status == CustomerDetailStatus.failure) {
            return AppErrorState(
              message: state.errorMessage ?? 'حدث خطأ',
              onRetry: () => context.read<CustomerDetailCubit>().load(),
            );
          }

          final name = state.customer?.name ?? '';
          final tokens = Theme.of(context).extension<AlmazinThemeTokens>()!;

          return DashboardPage(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                        letterSpacing: -0.3,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
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
