final class CustomerValidationException implements Exception {
  CustomerValidationException(this.messageAr);

  final String messageAr;

  @override
  String toString() => messageAr;
}

abstract final class CustomerValidator {
  static void validateProfile({
    required String name,
    required String phone,
    required String address,
    required String notes,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw CustomerValidationException('اسم العميل مطلوب');
    }
    if (trimmedName.length > 120) {
      throw CustomerValidationException('اسم العميل طويل جداً');
    }
    if (phone.length > 40) {
      throw CustomerValidationException('رقم الهاتف طويل جداً');
    }
    if (address.length > 300) {
      throw CustomerValidationException('العنوان طويل جداً');
    }
    if (notes.length > 2000) {
      throw CustomerValidationException('الملاحظات طويلة جداً');
    }
  }
}
