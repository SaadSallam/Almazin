import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:almazin_app/core/keyboard/app_shortcuts.dart';
import 'package:almazin_app/core/responsive/responsive_context.dart';
import 'package:almazin_app/core/theme/app_spacing.dart';
import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';
import 'package:almazin_app/features/coffee_prices/presentation/cubit/coffee_prices_cubit.dart';
import 'package:almazin_app/features/coffee_prices/presentation/cubit/coffee_prices_state.dart';
import 'package:almazin_app/features/coffee_prices/presentation/widgets/coffee_prices_table.dart';
import 'package:almazin_app/features/coffee_prices/presentation/widgets/coffee_type_card.dart';
import 'package:almazin_app/features/coffee_prices/presentation/widgets/coffee_type_editor_dialog.dart';
import 'package:almazin_app/shared/widgets/app_button.dart';
import 'package:almazin_app/shared/widgets/app_confirm_dialog.dart';
import 'package:almazin_app/shared/widgets/app_search_field.dart';
import 'package:almazin_app/shared/widgets/app_section.dart';
import 'package:almazin_app/shared/widgets/app_states.dart';
import 'package:almazin_app/shared/widgets/dashboard_page.dart';

class CoffeePricesPage extends StatefulWidget {
  const CoffeePricesPage({super.key});

  @override
  State<CoffeePricesPage> createState() => _CoffeePricesPageState();
}

class _CoffeePricesPageState extends State<CoffeePricesPage> {
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return BlocListener<CoffeePricesCubit, CoffeePricesState>(
      listenWhen: (previous, current) =>
          previous.snackbarMessage != current.snackbarMessage &&
          current.snackbarMessage != null,
      listener: (context, state) {
        final message = state.snackbarMessage;
        if (message == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        if (context.mounted) {
          context.read<CoffeePricesCubit>().clearSnackbar();
        }
      },
      child: Scaffold(
        floatingActionButton: isDesktop
            ? null
            : FloatingActionButton.extended(
                onPressed: () async {
                  final cubit = context.read<CoffeePricesCubit>();
                  await showCoffeeTypeEditor(context: context, cubit: cubit);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('إضافة صنف'),
              ),
        body: BlocBuilder<CoffeePricesCubit, CoffeePricesState>(
          buildWhen: (a, b) =>
              a.status != b.status ||
              a.items != b.items ||
              a.query != b.query ||
              a.errorMessage != b.errorMessage,
          builder: (context, state) {
            if (state.status == CoffeePricesStatus.loading && state.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == CoffeePricesStatus.failure && state.items.isEmpty) {
              return AppErrorState(
                message: state.errorMessage ?? 'حدث خطأ',
                onRetry: () => context.read<CoffeePricesCubit>().load(),
              );
            }

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
                          title: 'أسعار البن',
                          subtitle:
                              'إدارة أصناف البن وأسعار الكيلو بالجنيه المصري. تُستخدم هذه الأسعار في بقية أجزاء التطبيق.',
                          trailing: isDesktop
                              ? AppButton(
                                  label: 'إضافة صنف',
                                  icon: Icons.add_rounded,
                                  variant: AppButtonVariant.primary,
                                  onPressed: () async {
                                    final cubit = context.read<CoffeePricesCubit>();
                                    await showCoffeeTypeEditor(context: context, cubit: cubit);
                                  },
                                )
                              : null,
                          child: const SizedBox.shrink(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppSearchField(
                          focusNode: _searchFocusNode,
                          onChanged: context.read<CoffeePricesCubit>().setQuery,
                          hintText: 'ابحث باسم البن أو الملاحظات…',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (state.status == CoffeePricesStatus.loading) ...[
                          const LinearProgressIndicator(minHeight: 2),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        _CoffeePricesBody(
                          items: state.visibleItems,
                          onEdit: (item) async {
                            final cubit = context.read<CoffeePricesCubit>();
                            await showCoffeeTypeEditor(
                              context: context,
                              cubit: cubit,
                              existing: item,
                            );
                          },
                          onDelete: (item) async {
                            final ok = await showAppConfirmDialog(
                              context: context,
                              title: 'حذف الصنف',
                              message: 'هل تريد حذف «${item.name}»؟',
                            );
                            if (!ok || !context.mounted) return;
                            await context.read<CoffeePricesCubit>().delete(item.id);
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

class _CoffeePricesBody extends StatelessWidget {
  const _CoffeePricesBody({
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  final List<CoffeeType> items;
  final ValueChanged<CoffeeType> onEdit;
  final ValueChanged<CoffeeType> onDelete;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const AppEmptyState(
        message: 'لا توجد أصناف بعد\nابدأ بإضافة أول صنف باستخدام زر «إضافة صنف».',
        icon: Icons.coffee_maker_outlined,
      );
    }

    if (context.isDesktop) {
      return CoffeePricesTable(
        items: items,
        onEdit: onEdit,
        onDelete: onDelete,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final item = items[index];
        return CoffeeTypeCard(
          item: item,
          onEdit: () => onEdit(item),
          onDelete: () => onDelete(item),
        );
      },
    );
  }
}
