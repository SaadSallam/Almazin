import 'coffee_type.dart';

abstract class CoffeePricesRepository {
  Future<List<CoffeeType>> getAll();

  Future<void> upsert(CoffeeType type);

  Future<void> delete(String id);
}
