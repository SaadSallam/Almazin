import 'package:almazin_app/features/coffee_prices/data/coffee_prices_local_datasource.dart';
import 'package:almazin_app/features/coffee_prices/data/coffee_type_model.dart';
import 'package:almazin_app/features/coffee_prices/domain/coffee_prices_repository.dart';
import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';

final class CoffeePricesRepositoryImpl implements CoffeePricesRepository {
  CoffeePricesRepositoryImpl(this._local);

  final CoffeePricesLocalDataSource _local;

  List<CoffeeType> _sorted(List<CoffeeType> items) {
    final copy = List<CoffeeType>.from(items);
    copy.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return copy;
  }

  @override
  Future<List<CoffeeType>> getAll() async {
    final rows = await _local.readAll();
    final parsed = <CoffeeType>[];
    for (final row in rows) {
      try {
        final model = CoffeeTypeModel.fromJson(row);
        if (model.id.isEmpty || model.name.trim().isEmpty) continue;
        parsed.add(model.toEntity());
      } catch (_) {}
    }
    return _sorted(parsed);
  }

  @override
  Future<void> upsert(CoffeeType type) async {
    final rows = await _local.readAll();
    final models = <CoffeeTypeModel>[];
    for (final row in rows) {
      try {
        models.add(CoffeeTypeModel.fromJson(row));
      } catch (_) {}
    }

    final model = CoffeeTypeModel.fromEntity(type);
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
    final rows = await _local.readAll();
    final models = <CoffeeTypeModel>[];
    for (final row in rows) {
      try {
        models.add(CoffeeTypeModel.fromJson(row));
      } catch (_) {}
    }

    final next = models.where((m) => m.id != id).toList();
    await _local.writeAll(next.map((m) => m.toJson()).toList());
  }
}
