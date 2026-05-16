import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:almazin_app/core/keyboard/app_shortcuts.dart';
import 'package:almazin_app/core/responsive/responsive_context.dart';
import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';
import 'package:almazin_app/features/coffee_prices/presentation/cubit/coffee_prices_cubit.dart';
import 'package:almazin_app/features/coffee_prices/presentation/cubit/coffee_prices_state.dart';
import 'package:almazin_app/features/coffee_prices/presentation/widgets/coffee_prices_table.dart';
import 'package:almazin_app/features/coffee_prices/presentation/widgets/coffee_type_card.dart';
import 'package:almazin_app/features/coffee_prices/presentation/widgets/coffee_type_editor_dialog.dart';
import 'package:almazin_app/shared/widgets/app_confirm_dialog.dart';
import 'package:almazin_app/shared/widgets/app_search_field.dart';
import 'package:almazin_app/shared/widgets/app_section.dart';
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final cubit = context.read<CoffeePricesCubit>();
            await showCoffeeTypeEditor(context: context, cubit: cubit);
          },
          icon: const Icon(Icons.add),
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
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.errorMessage ?? 'حدث خطأ',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.read<CoffeePricesCubit>().load(),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
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
                          child: const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 12),
                        AppSearchField(
                          focusNode: _searchFocusNode,
                          onChanged: context.read<CoffeePricesCubit>().setQuery,
                          hintText: 'ابحث باسم البن أو الملاحظات…',
                        ),
                        const SizedBox(height: 12),
                        if (state.status == CoffeePricesStatus.loading)
                          const LinearProgressIndicator(minHeight: 3),
                        if (state.status == CoffeePricesStatus.loading)
                          const SizedBox(height: 12),
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
      return const _CoffeePricesEmpty();
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
      separatorBuilder: (_, _) => const SizedBox(height: 12),
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

class _CoffeePricesEmpty extends StatelessWidget {
  const _CoffeePricesEmpty();

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
                'لا توجد أصناف بعد',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'ابدأ بإضافة أول صنف باستخدام زر «إضافة صنف».',
                style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
