import 'package:equatable/equatable.dart';

import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';
import 'package:almazin_app/features/customers/domain/blend_calculation_service.dart';
import 'package:almazin_app/features/customers/domain/blend_component.dart';
import 'package:almazin_app/features/customers/domain/customer.dart';

enum CustomerDetailStatus { initial, loading, ready, failure, notFound }

const Object _unset = Object();

class CustomerDetailState extends Equatable {
  const CustomerDetailState({
    this.status = CustomerDetailStatus.initial,
    this.customer,
    this.coffees = const [],
    this.blendDraft = const [],
    this.weightInput = '',
    this.weightResult = BlendCalculationResult.empty,
    this.errorMessage,
    this.snackbarMessage,
    this.isSavingProfile = false,
    this.isSavingBlend = false,
  });

  final CustomerDetailStatus status;
  final Customer? customer;
  final List<CoffeeType> coffees;
  final List<BlendComponent> blendDraft;
  final String weightInput;
  final BlendCalculationResult weightResult;
  final String? errorMessage;
  final String? snackbarMessage;
  final bool isSavingProfile;
  final bool isSavingBlend;

  Map<String, CoffeeType> get coffeesById => {for (final c in coffees) c.id: c};

  CustomerDetailState copyWith({
    CustomerDetailStatus? status,
    Customer? customer,
    List<CoffeeType>? coffees,
    List<BlendComponent>? blendDraft,
    String? weightInput,
    BlendCalculationResult? weightResult,
    Object? errorMessage = _unset,
    Object? snackbarMessage = _unset,
    bool? isSavingProfile,
    bool? isSavingBlend,
  }) {
    return CustomerDetailState(
      status: status ?? this.status,
      customer: customer ?? this.customer,
      coffees: coffees ?? this.coffees,
      blendDraft: blendDraft ?? this.blendDraft,
      weightInput: weightInput ?? this.weightInput,
      weightResult: weightResult ?? this.weightResult,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
      snackbarMessage:
          identical(snackbarMessage, _unset) ? this.snackbarMessage : snackbarMessage as String?,
      isSavingProfile: isSavingProfile ?? this.isSavingProfile,
      isSavingBlend: isSavingBlend ?? this.isSavingBlend,
    );
  }

  @override
  List<Object?> get props => [
        status,
        customer,
        coffees,
        blendDraft,
        weightInput,
        weightResult,
        errorMessage,
        snackbarMessage,
        isSavingProfile,
        isSavingBlend,
      ];
}
