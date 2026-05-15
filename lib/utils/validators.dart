import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';

class Validators {
  Validators._();

  static String? required(BuildContext context, String? value) {
    final l = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l.validationRequired;
    }
    return null;
  }

  static String? requiredNumberGreaterThanZero(
      BuildContext context, String? value) {
    final l = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l.validationRequired;
    }
    final n = double.tryParse(value.trim());
    if (n == null) return l.validationInvalidNumber;
    if (n <= 0) return l.validationGreaterThanZero;
    return null;
  }

  static String? requiredNumberGreaterOrEqualZero(
      BuildContext context, String? value) {
    final l = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l.validationRequired;
    }
    final n = double.tryParse(value.trim());
    if (n == null) return l.validationInvalidNumber;
    if (n < 0) return l.validationGreaterOrEqualZero;
    return null;
  }
}
