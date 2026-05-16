import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:almazin_app/core/keyboard/app_shortcuts.dart';
import 'package:almazin_app/core/navigation/app_paths.dart';
import 'package:almazin_app/features/customers/presentation/cubit/customers_list_cubit.dart';
import 'package:almazin_app/features/customers/presentation/cubit/customers_list_state.dart';
import 'package:almazin_app/features/customers/presentation/widgets/customer_card.dart';
import 'package:almazin_app/features/customers/presentation/widgets/customer_editor_dialog.dart';
import 'package:almazin_app/shared/widgets/app_confirm_dialog.dart';
import 'package:almazin_app/shared/widgets/app_search_field.dart';
import 'package:almazin_app/shared/widgets/app_section.dart';
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
        floatingActionButton: FloatingActionButton.extended(
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
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.errorMessage ?? 'حدث خطأ', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.read<CustomersListCubit>().load(),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
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
                          child: const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 12),
                        AppSearchField(
                          focusNode: _searchFocusNode,
                          onChanged: context.read<CustomersListCubit>().setQuery,
                          hintText: 'ابحث بالاسم أو الهاتف…',
                        ),
                        const SizedBox(height: 14),
                        if (visible.isEmpty)
                          const _CustomersEmpty()
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: visible.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
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

class _CustomersEmpty extends StatelessWidget {
  const _CustomersEmpty();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.25)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'لا يوجد عملاء',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'أضف عميلاً جديداً ثم عيّن توليفته من صفحة التفاصيل.',
                style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
