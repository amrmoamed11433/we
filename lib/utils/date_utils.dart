import 'package:intl/intl.dart';

/// Cycle math for groups whose renewal day is 1 or 16.
///
/// The cycle is purely calendar-based. A "current cycle" starts on the most
/// recent occurrence of the renewal day on/before today, and ends one day
/// before the next occurrence of the renewal day.
class CycleDateUtils {
  CycleDateUtils._();

  /// Strip time → keep only year/month/day.
  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Returns the start date of the cycle that today falls inside.
  ///
  /// renewalDay = 1:
  ///   start = day 1 of the current month.
  ///
  /// renewalDay = 16:
  ///   if today.day >= 16 → start = day 16 of the current month.
  ///   if today.day  < 16 → start = day 16 of the previous month.
  static DateTime getCurrentCycleStartDate(int renewalDay, DateTime today) {
    final t = _dateOnly(today);
    if (renewalDay == 1) {
      return DateTime(t.year, t.month, 1);
    }
    // renewalDay == 16
    if (t.day >= 16) {
      return DateTime(t.year, t.month, 16);
    }
    // previous month, day 16
    final prevMonth = t.month == 1 ? 12 : t.month - 1;
    final prevYear = t.month == 1 ? t.year - 1 : t.year;
    return DateTime(prevYear, prevMonth, 16);
  }

  /// Start date of the next cycle (i.e., the next renewal day after today).
  static DateTime getNextCycleStartDate(int renewalDay, DateTime today) {
    final currentStart = getCurrentCycleStartDate(renewalDay, today);
    if (renewalDay == 1) {
      // next month, day 1
      final nextMonth = currentStart.month == 12 ? 1 : currentStart.month + 1;
      final nextYear =
          currentStart.month == 12 ? currentStart.year + 1 : currentStart.year;
      return DateTime(nextYear, nextMonth, 1);
    }
    // renewalDay == 16 → next is day 16 of the next month
    final nextMonth = currentStart.month == 12 ? 1 : currentStart.month + 1;
    final nextYear =
        currentStart.month == 12 ? currentStart.year + 1 : currentStart.year;
    return DateTime(nextYear, nextMonth, 16);
  }

  /// End date (inclusive, shown to the user) of the cycle that started on
  /// [cycleStartDate]. This is one day before the next cycle start.
  static DateTime getCycleEndDate(DateTime cycleStartDate, int renewalDay) {
    // next renewal day after the cycle start
    final nextMonth =
        cycleStartDate.month == 12 ? 1 : cycleStartDate.month + 1;
    final nextYear = cycleStartDate.month == 12
        ? cycleStartDate.year + 1
        : cycleStartDate.year;
    final nextStart = DateTime(nextYear, nextMonth, renewalDay);
    return nextStart.subtract(const Duration(days: 1));
  }

  /// Two cycle starts represent the same cycle iff their date parts match.
  static bool sameCycle(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String formatDate(DateTime d, {String locale = 'en'}) {
    final fmt = DateFormat.yMMMd(locale);
    return fmt.format(d);
  }

  static String formatDateTime(DateTime d, {String locale = 'en'}) {
    return DateFormat.yMMMd(locale).add_jm().format(d);
  }
}
