import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:almazin_app/features/coffee_prices/domain/coffee_prices_repository.dart';
import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';
import 'package:almazin_app/features/coffee_prices/domain/coffee_type_validator.dart';

import 'coffee_prices_state.dart';

class CoffeePricesCubit extends Cubit<CoffeePricesState> {
  CoffeePricesCubit(this._repository) : super(const CoffeePricesState());

  final CoffeePricesRepository _repository;

  static final Uuid _uuid = Uuid();

  Future<void> load() async {
    emit(
      state.copyWith(
        status: CoffeePricesStatus.loading,
        snackbarMessage: null,
        errorMessage: null,
      ),
    );
    try {
      final items = await _repository.getAll();
      emit(
        state.copyWith(
          status: CoffeePricesStatus.ready,
          items: items,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CoffeePricesStatus.failure,
          errorMessage: 'تعذر تحميل البيانات',
        ),
      );
    }
  }

  void setQuery(String value) {
    emit(state.copyWith(query: value));
  }

  void clearSnackbar() {
    emit(state.copyWith(snackbarMessage: null));
  }

  Future<bool> save({
    required String? existingId,
    required String name,
    required double pricePerKilogram,
    required String notes,
  }) async {
    emit(state.copyWith(snackbarMessage: null));
    try {
      CoffeeTypeValidator.validateForSave(
        name: name,
        pricePerKilogram: pricePerKilogram,
        notes: notes,
      );

      final now = DateTime.now();
      final entity = CoffeeType(
        id: existingId ?? _uuid.v4(),
        name: name.trim(),
        pricePerKilogram: pricePerKilogram,
        notes: notes.trim(),
        updatedAt: now,
      );

      await _repository.upsert(entity);
      final items = await _repository.getAll();
      if (!isClosed) {
        emit(
          state.copyWith(
            status: CoffeePricesStatus.ready,
            items: items,
            snackbarMessage: existingId == null ? 'تمت إضافة الصنف' : 'تم حفظ التعديلات',
          ),
        );
      }
      return true;
    } on CoffeeTypeValidationException catch (e) {
      if (!isClosed) emit(state.copyWith(snackbarMessage: e.messageAr));
      return false;
    } catch (_) {
      if (!isClosed) emit(state.copyWith(snackbarMessage: 'تعذر حفظ البيانات'));
      return false;
    }
  }

  Future<void> delete(String id) async {
    emit(state.copyWith(snackbarMessage: null));
    try {
      await _repository.delete(id);
      final items = await _repository.getAll();
      if (!isClosed) {
        emit(
          state.copyWith(
            status: CoffeePricesStatus.ready,
            items: items,
            snackbarMessage: 'تم حذف الصنف',
          ),
        );
      }
    } catch (_) {
      if (!isClosed) emit(state.copyWith(snackbarMessage: 'تعذر حذف الصنف'));
    }
  }
}
