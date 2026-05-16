import 'package:intl/intl.dart';

abstract final class CalculatorDisplayFormat {
  static final NumberFormat _number = NumberFormat('#,##0.##', 'ar');
  static final NumberFormat _percent = NumberFormat('#0.##', 'ar');

  static String grams(double value) => '${_number.format(value)} g';

  static String percent(double value) => '${_percent.format(value)}٪';
}
