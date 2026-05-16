import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/navigation/app_paths.dart';
import '../core/storage/app_storage.dart';
import '../features/calculator/data/customer_blend_drafts_datasource.dart';
import '../features/calculator/presentation/calculator_page.dart';
import '../features/calculator/presentation/cubit/direct_weight_calculator_cubit.dart';
import '../features/coffee_prices/data/coffee_prices_local_datasource.dart';
import '../features/coffee_prices/data/coffee_prices_repository_impl.dart';
import '../features/coffee_prices/presentation/coffee_prices_page.dart';
import '../features/coffee_prices/presentation/cubit/coffee_prices_cubit.dart';
import '../features/customers/data/customers_local_datasource.dart';
import '../features/customers/data/customers_repository_impl.dart';
import '../features/customers/presentation/cubit/customer_detail_cubit.dart';
import '../features/customers/presentation/cubit/customers_list_cubit.dart';
import '../features/customers/presentation/customer_detail_page.dart';
import '../features/customers/presentation/customers_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../shared/layout/app_shell.dart';

final class AppRouter {
  const AppRouter._();

  static CoffeePricesRepositoryImpl _coffeePricesRepository() {
    return CoffeePricesRepositoryImpl(
      CoffeePricesLocalDataSourceImpl(Hive.box<dynamic>(kAlmazinDataBox)),
    );
  }

  static CustomersRepositoryImpl _customersRepository() {
    return CustomersRepositoryImpl(
      CustomersLocalDataSourceImpl(Hive.box<dynamic>(kAlmazinDataBox)),
    );
  }

  static GoRouter create() {
    return GoRouter(
      initialLocation: AppPaths.coffeePrices,
      routes: [
        GoRoute(
          path: '/',
          redirect: (_, _) => AppPaths.coffeePrices,
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: AppPaths.coffeePrices,
              pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey,
                child: BlocProvider(
                  create: (_) => CoffeePricesCubit(_coffeePricesRepository())..load(),
                  child: const CoffeePricesPage(),
                ),
              ),
            ),
            GoRoute(
              path: AppPaths.customers,
              pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey,
                child: BlocProvider(
                  create: (_) => CustomersListCubit(
                    customersRepository: _customersRepository(),
                    coffeePricesRepository: _coffeePricesRepository(),
                  )..load(),
                  child: const CustomersPage(),
                ),
              ),
              routes: [
                GoRoute(
                  path: ':customerId',
                  pageBuilder: (context, state) {
                    final customerId = state.pathParameters['customerId']!;
                    return NoTransitionPage<void>(
                      key: state.pageKey,
                      child: BlocProvider(
                        create: (_) => CustomerDetailCubit(
                          customerId: customerId,
                          customersRepository: _customersRepository(),
                          coffeePricesRepository: _coffeePricesRepository(),
                        )..load(),
                        child: CustomerDetailPage(customerId: customerId),
                      ),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: AppPaths.calculator,
              pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey,
                child: BlocProvider(
                  create: (_) => DirectWeightCalculatorCubit(
                    coffeePricesRepository: _coffeePricesRepository(),
                    draftsDataSource: CustomerBlendDraftsDataSourceImpl(
                      Hive.box<dynamic>(kAlmazinDataBox),
                    ),
                  )..loadCoffees(),
                  child: const CalculatorPage(),
                ),
              ),
            ),
            GoRoute(
              path: AppPaths.settings,
              pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey,
                child: const SettingsPage(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
