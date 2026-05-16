import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:almazin_app/features/coffee_prices/domain/coffee_prices_repository.dart';
import 'package:almazin_app/features/customers/domain/customer.dart';
import 'package:almazin_app/features/customers/domain/customer_validator.dart';
import 'package:almazin_app/features/customers/domain/customers_repository.dart';

import 'customers_list_state.dart';

class CustomersListCubit extends Cubit<CustomersListState> {
  CustomersListCubit({
    required CustomersRepository customersRepository,
    required CoffeePricesRepository coffeePricesRepository,
  })  : _customersRepository = customersRepository,
        _coffeePricesRepository = coffeePricesRepository,
        super(const CustomersListState());

  final CustomersRepository _customersRepository;
  final CoffeePricesRepository _coffeePricesRepository;

  static final Uuid _uuid = Uuid();

  Future<void> load() async {
    emit(
      state.copyWith(
        status: CustomersListStatus.loading,
        errorMessage: null,
        snackbarMessage: null,
      ),
    );
    try {
      final customers = await _customersRepository.getAll();
      final coffees = await _coffeePricesRepository.getAll();
      emit(
        state.copyWith(
          status: CustomersListStatus.ready,
          customers: customers,
          coffees: coffees,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CustomersListStatus.failure,
          errorMessage: 'تعذر تحميل العملاء',
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

  Future<bool> createCustomer({
    required String name,
    required String phone,
    required String address,
    required String notes,
  }) async {
    emit(state.copyWith(snackbarMessage: null));
    try {
      CustomerValidator.validateProfile(
        name: name,
        phone: phone,
        address: address,
        notes: notes,
      );

      final customer = Customer(
        id: _uuid.v4(),
        name: name.trim(),
        phone: phone.trim(),
        address: address.trim(),
        notes: notes.trim(),
        blend: const [],
      );

      await _customersRepository.upsert(customer);
      final customers = await _customersRepository.getAll();
      if (!isClosed) {
        emit(
          state.copyWith(
            status: CustomersListStatus.ready,
            customers: customers,
            snackbarMessage: 'تمت إضافة العميل',
          ),
        );
      }
      return true;
    } on CustomerValidationException catch (e) {
      if (!isClosed) emit(state.copyWith(snackbarMessage: e.messageAr));
      return false;
    } catch (_) {
      if (!isClosed) emit(state.copyWith(snackbarMessage: 'تعذر حفظ العميل'));
      return false;
    }
  }

  Future<void> deleteCustomer(String id) async {
    emit(state.copyWith(snackbarMessage: null));
    try {
      await _customersRepository.delete(id);
      final customers = await _customersRepository.getAll();
      if (!isClosed) {
        emit(
          state.copyWith(
            customers: customers,
            snackbarMessage: 'تم حذف العميل',
          ),
        );
      }
    } catch (_) {
      if (!isClosed) emit(state.copyWith(snackbarMessage: 'تعذر حذف العميل'));
    }
  }
}
