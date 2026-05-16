import 'package:equatable/equatable.dart';

import 'package:almazin_app/features/calculator/domain/direct_weight_calculator_service.dart';
import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';

enum DirectWeightCalculatorStatus { initial, loading, ready, failure }

const Object _unset = Object();

class CalculatorLineDraft extends Equatable {
  const CalculatorLineDraft({
    required this.id,
    this.coffeeId,
    this.weightInput = '',
  });

  final String id;
  final String? coffeeId;
  final String weightInput;

  CalculatorLineDraft copyWith({
    String? id,
    Object? coffeeId = _unset,
    String? weightInput,
  }) {
    return CalculatorLineDraft(
      id: id ?? this.id,
      coffeeId: identical(coffeeId, _unset) ? this.coffeeId : coffeeId as String?,
      weightInput: weightInput ?? this.weightInput,
    );
  }

  @override
  List<Object?> get props => [id, coffeeId, weightInput];
}

class DirectWeightCalculatorState extends Equatable {
  const DirectWeightCalculatorState({
    this.status = DirectWeightCalculatorStatus.initial,
    this.coffees = const [],
    this.lines = const [],
    this.result = DirectWeightCalculatorResult.empty,
    this.errorMessage,
    this.snackbarMessage,
  });

  final DirectWeightCalculatorStatus status;
  final List<CoffeeType> coffees;
  final List<CalculatorLineDraft> lines;
  final DirectWeightCalculatorResult result;
  final String? errorMessage;
  final String? snackbarMessage;

  DirectWeightCalculatorState copyWith({
    DirectWeightCalculatorStatus? status,
    List<CoffeeType>? coffees,
    List<CalculatorLineDraft>? lines,
    DirectWeightCalculatorResult? result,
    Object? errorMessage = _unset,
    Object? snackbarMessage = _unset,
  }) {
    return DirectWeightCalculatorState(
      status: status ?? this.status,
      coffees: coffees ?? this.coffees,
      lines: lines ?? this.lines,
      result: result ?? this.result,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
      snackbarMessage: identical(snackbarMessage, _unset) ? this.snackbarMessage : snackbarMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, coffees, lines, result, errorMessage, snackbarMessage];
}
