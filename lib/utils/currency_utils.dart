import 'package:intl/intl.dart';

class CurrencyUtils {
  CurrencyUtils._();

  /// Formats an amount with a 2-decimal precision and the localized currency
  /// label appended.
  static String format(double amount, String currencyLabel,
      {String locale = 'en'}) {
    final fmt = NumberFormat('#,##0.##', locale);
    return '${fmt.format(amount)} $currencyLabel';
  }
}
