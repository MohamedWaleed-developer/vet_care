import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static String currency(
      double amount, {
        String currency = 'SAR',
      }) {
    final formatter = NumberFormat('#,##0.00');

    return '${formatter.format(amount)} $currency';
  }

  static String number(double value) {
    return NumberFormat('#,##0.##').format(value);
  }
}