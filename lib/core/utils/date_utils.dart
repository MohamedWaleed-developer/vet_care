import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(
      DateTime? date, {
        String pattern = 'dd/MM/yyyy',
      }) {
    if (date == null) {
      return '';
    }

    return DateFormat(pattern).format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) {
      return '';
    }

    return DateFormat('dd/MM/yyyy - hh:mm a').format(date);
  }

  static DateTime? fromTimestamp(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return value.toDate();
  }
}