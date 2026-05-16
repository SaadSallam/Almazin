import 'package:almazin_app/features/customers/data/customer_model.dart';
import 'package:almazin_app/features/customers/data/customers_local_datasource.dart';
import 'package:almazin_app/features/customers/domain/customer.dart';
import 'package:almazin_app/features/customers/domain/customers_repository.dart';

final class CustomersRepositoryImpl implements CustomersRepository {
  CustomersRepositoryImpl(this._local);

  final CustomersLocalDataSource _local;

  List<Customer> _sorted(List<Customer> items) {
    final copy = List<Customer>.from(items);
    copy.sort((a, b) => a.name.compareTo(b.name));
    return copy;
  }

  Future<List<CustomerModel>> _readModels() async {
    final rows = await _local.readAll();
    final models = <CustomerModel>[];
    for (final row in rows) {
      try {
        final model = CustomerModel.fromJson(row);
        if (model.id.isEmpty || model.name.trim().isEmpty) continue;
        models.add(model);
      } catch (_) {}
    }
    return models;
  }

  @override
  Future<List<Customer>> getAll() async {
    final models = await _readModels();
    return _sorted(models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Customer?> getById(String id) async {
    final models = await _readModels();
    for (final model in models) {
      if (model.id == id) return model.toEntity();
    }
    return null;
  }

  @override
  Future<void> upsert(Customer customer) async {
    final models = await _readModels();
    final model = CustomerModel.fromEntity(customer);
    final idx = models.indexWhere((m) => m.id == model.id);
    if (idx >= 0) {
      models[idx] = model;
    } else {
      models.add(model);
    }
    await _local.writeAll(models.map((m) => m.toJson()).toList());
  }

  @override
  Future<void> delete(String id) async {
    final models = await _readModels();
    final next = models.where((m) => m.id != id).toList();
    await _local.writeAll(next.map((m) => m.toJson()).toList());
  }
}
