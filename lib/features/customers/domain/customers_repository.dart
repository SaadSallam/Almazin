import 'customer.dart';

abstract class CustomersRepository {
  Future<List<Customer>> getAll();

  Future<Customer?> getById(String id);

  Future<void> upsert(Customer customer);

  Future<void> delete(String id);
}
