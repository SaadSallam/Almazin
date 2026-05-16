import 'blend_component.dart';

final class BlendValidationException implements Exception {
  BlendValidationException(this.messageAr);

  final String messageAr;

  @override
  String toString() => messageAr;
}

abstract final class BlendValidator {
  static void validateComponents(List<BlendComponent> components) {
    if (components.isEmpty) {
      throw BlendValidationException('أضف مكوّن واحداً على الأقل للتوليفة');
    }

    final ids = <String>{};
    var hasValidWeight = false;

    for (final c in components) {
      if (c.coffeeTypeId.isEmpty) {
        throw BlendValidationException('اختر نوع البن لكل سطر');
      }
      if (ids.contains(c.coffeeTypeId)) {
        throw BlendValidationException('لا يمكن تكرار نفس نوع البن في التوليفة');
      }
      ids.add(c.coffeeTypeId);

      if (c.weightInGrams.isFinite && c.weightInGrams > 0) {
        hasValidWeight = true;
      }
    }

    if (!hasValidWeight) {
      throw BlendValidationException('أدخل وزناً صالحاً لصنف واحد على الأقل');
    }
  }
}
