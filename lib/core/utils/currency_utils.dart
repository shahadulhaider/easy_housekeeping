import 'package:intl/intl.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static final _formatter = NumberFormat('#,##,###', 'en_IN');

  static String formatBDT(double amount) {
    return '৳${_formatter.format(amount.round())}';
  }

  static String formatBDTDecimal(double amount) {
    return '৳${_formatter.format(amount)}';
  }

  static String formatCompact(double amount) {
    if (amount >= 100000) {
      return '৳${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '৳${(amount / 1000).toStringAsFixed(1)}K';
    }
    return formatBDT(amount);
  }
}
