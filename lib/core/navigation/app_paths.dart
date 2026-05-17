/// Canonical route paths for [go_router].
abstract final class AppPaths {
  static const String coffeePrices = '/coffee-prices';
  static const String customers = '/customers';
  static const String calculator = '/calculator';
  static const String employees = '/employees';
  static const String pinLock = '/pin-lock';
  static const String settings = '/settings';

  static String customerDetail(String customerId) => '/customers/$customerId';
  static String employeeDetail(String employeeId) => '/employees/$employeeId';
}
