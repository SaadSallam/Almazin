import 'package:equatable/equatable.dart';

import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';

enum CoffeePricesStatus { initial, loading, ready, failure }

const Object _unset = Object();

class CoffeePricesState extends Equatable {
  const CoffeePricesState({
    this.status = CoffeePricesStatus.initial,
    this.items = const [],
    this.query = '',
    this.snackbarMessage,
    this.errorMessage,
  });

  final CoffeePricesStatus status;
  final List<CoffeeType> items;
  final String query;
  final String? snackbarMessage;
  final String? errorMessage;

  List<CoffeeType> get visibleItems {
    final q = query.trim().toLowerCase();
    Iterable<CoffeeType> out = items;
    if (q.isNotEmpty) {
      out = items.where((e) {
        final name = e.name.toLowerCase();
        final notes = e.notes.toLowerCase();
        return name.contains(q) || notes.contains(q);
      });
    }
    final list = out.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  CoffeePricesState copyWith({
    CoffeePricesStatus? status,
    List<CoffeeType>? items,
    String? query,
    Object? snackbarMessage = _unset,
    Object? errorMessage = _unset,
  }) {
    return CoffeePricesState(
      status: status ?? this.status,
      items: items ?? this.items,
      query: query ?? this.query,
      snackbarMessage: identical(snackbarMessage, _unset)
          ? this.snackbarMessage
          : snackbarMessage as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, items, query, snackbarMessage, errorMessage];
}
