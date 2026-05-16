import 'package:equatable/equatable.dart';

import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';
import 'package:almazin_app/features/customers/domain/customer.dart';

enum CustomersListStatus { initial, loading, ready, failure }

const Object _unset = Object();

class CustomersListState extends Equatable {
  const CustomersListState({
    this.status = CustomersListStatus.initial,
    this.customers = const [],
    this.coffees = const [],
    this.query = '',
    this.errorMessage,
    this.snackbarMessage,
  });

  final CustomersListStatus status;
  final List<Customer> customers;
  final List<CoffeeType> coffees;
  final String query;
  final String? errorMessage;
  final String? snackbarMessage;

  Map<String, CoffeeType> get coffeesById => {for (final c in coffees) c.id: c};

  List<Customer> get visibleCustomers {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return customers;

    return customers.where((c) {
      final name = c.name.toLowerCase();
      final phone = c.phone.toLowerCase();
      return name.contains(q) || phone.contains(q);
    }).toList();
  }

  CustomersListState copyWith({
    CustomersListStatus? status,
    List<Customer>? customers,
    List<CoffeeType>? coffees,
    String? query,
    Object? errorMessage = _unset,
    Object? snackbarMessage = _unset,
  }) {
    return CustomersListState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      coffees: coffees ?? this.coffees,
      query: query ?? this.query,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
      snackbarMessage:
          identical(snackbarMessage, _unset) ? this.snackbarMessage : snackbarMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, customers, coffees, query, errorMessage, snackbarMessage];
}
