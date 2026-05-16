import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:almazin_app/features/coffee_prices/domain/coffee_prices_repository.dart';
import 'package:almazin_app/features/coffee_prices/domain/price_input_parser.dart';
import 'package:almazin_app/features/customers/domain/blend_calculation_service.dart';
import 'package:almazin_app/features/customers/domain/blend_component.dart';
import 'package:almazin_app/features/customers/domain/blend_validator.dart';
import 'package:almazin_app/features/customers/domain/customer_validator.dart';
import 'package:almazin_app/features/customers/domain/customers_repository.dart';

import 'customer_detail_state.dart';

class CustomerDetailCubit extends Cubit<CustomerDetailState> {
  CustomerDetailCubit({
    required String customerId,
    required CustomersRepository customersRepository,
    required CoffeePricesRepository coffeePricesRepository,
    BlendCalculationService blendCalculator = const BlendCalculationService(),
  })  : _customerId = customerId,
        _customersRepository = customersRepository,
        _coffeePricesRepository = coffeePricesRepository,
        _blendCalculator = blendCalculator,
        super(const CustomerDetailState());

  final String _customerId;
  final CustomersRepository _customersRepository;
  final CoffeePricesRepository _coffeePricesRepository;
  final BlendCalculationService _blendCalculator;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: CustomerDetailStatus.loading,
        errorMessage: null,
        snackbarMessage: null,
      ),
    );
    try {
      final customer = await _customersRepository.getById(_customerId);
      final coffees = await _coffeePricesRepository.getAll();

      if (customer == null) {
        emit(state.copyWith(status: CustomerDetailStatus.notFound));
        return;
      }

      final blendDraft = customer.blend.isEmpty
          ? <BlendComponent>[const BlendComponent(coffeeTypeId: '', weightInGrams: 0)]
          : List<BlendComponent>.from(customer.blend);

      emit(
        state.copyWith(
          status: CustomerDetailStatus.ready,
          customer: customer,
          coffees: coffees,
          blendDraft: blendDraft,
          errorMessage: null,
        ),
      );
      _recalculateWeight();
    } catch (_) {
      emit(
        state.copyWith(
          status: CustomerDetailStatus.failure,
          errorMessage: 'تعذر تحميل بيانات العميل',
        ),
      );
    }
  }

  void clearSnackbar() {
    emit(state.copyWith(snackbarMessage: null));
  }

  Future<bool> saveProfile({
    required String name,
    required String phone,
    required String address,
    required String notes,
  }) async {
    final current = state.customer;
    if (current == null) return false;

    emit(state.copyWith(isSavingProfile: true, snackbarMessage: null));
    try {
      CustomerValidator.validateProfile(
        name: name,
        phone: phone,
        address: address,
        notes: notes,
      );

      final updated = current.copyWith(
        name: name.trim(),
        phone: phone.trim(),
        address: address.trim(),
        notes: notes.trim(),
      );
      await _customersRepository.upsert(updated);
      if (!isClosed) {
        emit(
          state.copyWith(
            customer: updated,
            isSavingProfile: false,
            snackbarMessage: 'تم حفظ بيانات العميل',
          ),
        );
      }
      return true;
    } on CustomerValidationException catch (e) {
      if (!isClosed) emit(state.copyWith(isSavingProfile: false, snackbarMessage: e.messageAr));
      return false;
    } catch (_) {
      if (!isClosed) emit(state.copyWith(isSavingProfile: false, snackbarMessage: 'تعذر حفظ البيانات'));
      return false;
    }
  }

  void addBlendLine() {
    final next = List<BlendComponent>.from(state.blendDraft)
      ..add(const BlendComponent(coffeeTypeId: '', weightInGrams: 0));
    emit(state.copyWith(blendDraft: next));
    _recalculateWeight();
  }

  void removeBlendLine(int index) {
    if (index < 0 || index >= state.blendDraft.length) return;
    final next = List<BlendComponent>.from(state.blendDraft)..removeAt(index);
    emit(state.copyWith(blendDraft: next));
    _recalculateWeight();
  }

  void setBlendCoffee(int index, String? coffeeTypeId) {
    if (index < 0 || index >= state.blendDraft.length) return;
    final next = List<BlendComponent>.from(state.blendDraft);
    next[index] = next[index].copyWith(coffeeTypeId: coffeeTypeId ?? '');
    emit(state.copyWith(blendDraft: next));
    _recalculateWeight();
  }

  void setBlendWeightInput(int index, String raw) {
    if (index < 0 || index >= state.blendDraft.length) return;
    final parsed = PriceInputParser.tryParse(raw) ?? 0;
    final next = List<BlendComponent>.from(state.blendDraft);
    next[index] = next[index].copyWith(weightInGrams: parsed);
    emit(state.copyWith(blendDraft: next));
    _recalculateWeight();
  }

  Future<bool> saveBlend() async {
    final current = state.customer;
    if (current == null) return false;

    emit(state.copyWith(isSavingBlend: true, snackbarMessage: null));
    try {
      BlendValidator.validateComponents(state.blendDraft);

      final updated = current.copyWith(blend: state.blendDraft);
      await _customersRepository.upsert(updated);
      if (!isClosed) {
        emit(
          state.copyWith(
            customer: updated,
            blendDraft: List<BlendComponent>.from(state.blendDraft),
            isSavingBlend: false,
            snackbarMessage: 'تم حفظ التوليفة',
          ),
        );
        _recalculateWeight();
      }
      return true;
    } on BlendValidationException catch (e) {
      if (!isClosed) emit(state.copyWith(isSavingBlend: false, snackbarMessage: e.messageAr));
      return false;
    } catch (_) {
      if (!isClosed) emit(state.copyWith(isSavingBlend: false, snackbarMessage: 'تعذر حفظ التوليفة'));
      return false;
    }
  }

  void setWeightInput(String raw) {
    emit(state.copyWith(weightInput: raw));
  }

  void calculateScaledBlend() {
    final customer = state.customer;
    if (customer == null || customer.blend.isEmpty) return;

    final grams = PriceInputParser.tryParse(state.weightInput) ?? 0;
    if (grams <= 0) return;

    final scaled = _blendCalculator.scaleToTargetWeight(
      originalBlend: customer.blend,
      targetWeightGrams: grams,
    );

    emit(state.copyWith(blendDraft: scaled));
    _recalculateWeight();
  }

  void setQuickWeightGrams(double grams) {
    final customer = state.customer;
    if (customer == null || customer.blend.isEmpty) {
      final text = grams == grams.roundToDouble() ? grams.toStringAsFixed(0) : grams.toString();
      emit(state.copyWith(weightInput: text));
      return;
    }

    final scaled = _blendCalculator.scaleToTargetWeight(
      originalBlend: customer.blend,
      targetWeightGrams: grams,
    );

    final text = grams == grams.roundToDouble() ? grams.toStringAsFixed(0) : grams.toString();
    emit(state.copyWith(weightInput: text, blendDraft: scaled));
    _recalculateWeight();
  }

  void _recalculateWeight() {
    final result = _blendCalculator.calculate(
      components: state.blendDraft,
      coffeesById: state.coffeesById,
    );

    emit(state.copyWith(weightResult: result));
  }
}
