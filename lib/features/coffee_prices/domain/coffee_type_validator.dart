/// Thrown when domain validation fails before persistence.
final class CoffeeTypeValidationException implements Exception {
  CoffeeTypeValidationException(this.messageAr);

  final String messageAr;

  @override
  String toString() => messageAr;
}

abstract final class CoffeeTypeValidator {
  static void validateForSave({
    required String name,
    required double pricePerKilogram,
    required String notes,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw CoffeeTypeValidationException('اسم البن مطلوب');
    }
    if (trimmedName.length > 120) {
      throw CoffeeTypeValidationException('اسم البن طويل جداً');
    }
    if (pricePerKilogram <= 0) {
      throw CoffeeTypeValidationException('سعر الكيلو يجب أن يكون أكبر من صفر');
    }
    if (!pricePerKilogram.isFinite) {
      throw CoffeeTypeValidationException('سعر غير صالح');
    }
    if (notes.length > 2000) {
      throw CoffeeTypeValidationException('الملاحظات طويلة جداً');
    }
  }
}
