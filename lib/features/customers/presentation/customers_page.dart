import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:almazin_app/core/keyboard/app_shortcuts.dart';
import 'package:almazin_app/core/navigation/app_paths.dart';
import 'package:almazin_app/core/responsive/responsive_context.dart';
import 'package:almazin_app/core/theme/app_spacing.dart';
import 'package:almazin_app/features/customers/presentation/cubit/customers_list_cubit.dart';
import 'package:almazin_app/features/customers/presentation/cubit/customers_list_state.dart';
import 'package:almazin_app/features/customers/presentation/widgets/customer_card.dart';
import 'package:almazin_app/features/customers/presentation/widgets/customer_editor_dialog.dart';
import 'package:almazin_app/shared/widgets/app_button.dart';
import 'package:almazin_app/shared/widgets/app_confirm_dialog.dart';
import 'package:almazin_app/shared/widgets/app_search_field.dart';
import 'package:almazin_app/shared/widgets/app_section.dart';
import 'package:almazin_app/shared/widgets/app_states.dart';
import 'package:almazin_app/shared/widgets/dashboard_page.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return BlocListener<CustomersListCubit, CustomersListState>(
      listenWhen: (previous, current) =>
          previous.snackbarMessage != current.snackbarMessage &&
          current.snackbarMessage != null,
      listener: (context, state) {
        final message = state.snackbarMessage;
        if (message == null) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        if (context.mounted) {
          context.read<CustomersListCubit>().clearSnackbar();
        }
      },
      child: Scaffold(
        floatingActionButton: isDesktop
            ? null // Use inline button on desktop
            : FloatingActionButton.extended(
                onPressed: () async {
                  final result = await showCustomerEditorDialog(context: context);
                  if (!context.mounted || result == null) return;
                  await context.read<CustomersListCubit>().createCustomer(
                        name: result.name,
                        phone: result.phone,
                        address: result.address,
                        notes: result.notes,
                      );
                },
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('إضافة عميل'),
              ),
        body: BlocBuilder<CustomersListCubit, CustomersListState>(
          buildWhen: (a, b) =>
              a.status != b.status ||
              a.customers != b.customers ||
              a.coffees != b.coffees ||
              a.query != b.query ||
              a.errorMessage != b.errorMessage,
          builder: (context, state) {
            if (state.status == CustomersListStatus.loading && state.customers.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == CustomersListStatus.failure && state.customers.isEmpty) {
              return AppErrorState(
                message: state.errorMessage ?? 'حدث خطأ',
                onRetry: () => context.read<CustomersListCubit>().load(),
              );
            }

            final visible = state.visibleCustomers;

            return Focus(
              autofocus: true,
              child: Shortcuts(
                shortcuts: {
                  SingleActivator(LogicalKeyboardKey.keyF, control: true): const FocusSearchIntent(),
                },
                child: Actions(
                  actions: {
                    FocusSearchIntent: CallbackAction<FocusSearchIntent>(onInvoke: (_) {
                      _searchFocusNode.requestFocus();
                      return null;
                    }),
                  },
                  child: DashboardPage(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppSection(
                          title: 'العملاء',
                          subtitle: 'إدارة العملاء وتوليفاتهم المحفوظة كنسب مئوية.',
                          trailing: isDesktop
                              ? AppButton(
                                  label: 'إضافة عميل',
                                  icon: Icons.person_add_outlined,
                                  variant: AppButtonVariant.primary,
                                  onPressed: () async {
                                    final result = await showCustomerEditorDialog(context: context);
                                    if (!context.mounted || result == null) return;
                                    await context.read<CustomersListCubit>().createCustomer(
                                          name: result.name,
                                          phone: result.phone,
                                          address: result.address,
                                          notes: result.notes,
                                        );
                                  },
                                )
                              : null,
                          child: const SizedBox.shrink(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppSearchField(
                          focusNode: _searchFocusNode,
                          onChanged: context.read<CustomersListCubit>().setQuery,
                          hintText: 'ابحث بالاسم أو الهاتف…',
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (visible.isEmpty)
                          const AppEmptyState(
                            message: 'لا يوجد عملاء\nأضف عميلاً جديداً ثم عيّن توليفته من صفحة التفاصيل.',
                            icon: Icons.people_outline_rounded,
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: visible.length,
                            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final customer = visible[index];
                              return CustomerCard(
                                customer: customer,
                                coffeesById: state.coffeesById,
                                onTap: () => context.push(AppPaths.customerDetail(customer.id)),
                                onDelete: () async {
                                  final ok = await showAppConfirmDialog(
                                    context: context,
                                    title: 'حذف العميل',
                                    message: 'هل تريد حذف «${customer.name}»؟',
                                  );
                                  if (!ok || !context.mounted) return;
                                  await context.read<CustomersListCubit>().deleteCustomer(customer.id);
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
