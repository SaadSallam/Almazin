import 'package:intl/intl.dart';

/// Egyptian pound display helpers (per kilogram).
abstract final class EgpFormat {
  static final NumberFormat _money = NumberFormat('#,##0.##', 'ar');

  static String pricePerKilogram(double value) {
    return '${_money.format(value)} ج.م';
  }

  static String updatedAt(DateTime local) {
    return DateFormat.yMMMd('ar').add_Hm().format(local);
  }
}
