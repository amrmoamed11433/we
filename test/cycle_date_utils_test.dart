import 'package:flutter_test/flutter_test.dart';
import 'package:we_packages_manager/utils/date_utils.dart';

void main() {
  group('CycleDateUtils — renewalDay 1', () {
    test('current cycle starts on day 1 of the current month', () {
      final today = DateTime(2025, 3, 17);
      final start = CycleDateUtils.getCurrentCycleStartDate(1, today);
      expect(start, DateTime(2025, 3, 1));
    });

    test('on day 1 the cycle starts today', () {
      final today = DateTime(2025, 6, 1);
      final start = CycleDateUtils.getCurrentCycleStartDate(1, today);
      expect(start, DateTime(2025, 6, 1));
    });

    test('next cycle is day 1 of next month', () {
      final today = DateTime(2025, 12, 20);
      final next = CycleDateUtils.getNextCycleStartDate(1, today);
      expect(next, DateTime(2026, 1, 1));
    });

    test('end date is day before next start', () {
      final start = DateTime(2025, 3, 1);
      final end = CycleDateUtils.getCycleEndDate(start, 1);
      expect(end, DateTime(2025, 3, 31));
    });
  });

  group('CycleDateUtils — renewalDay 16', () {
    test('today >= 16 → start is day 16 of current month', () {
      final today = DateTime(2025, 3, 20);
      final start = CycleDateUtils.getCurrentCycleStartDate(16, today);
      expect(start, DateTime(2025, 3, 16));
    });

    test('today < 16 → start is day 16 of previous month', () {
      final today = DateTime(2025, 3, 10);
      final start = CycleDateUtils.getCurrentCycleStartDate(16, today);
      expect(start, DateTime(2025, 2, 16));
    });

    test('today < 16 in January → start is December 16 of previous year', () {
      final today = DateTime(2025, 1, 5);
      final start = CycleDateUtils.getCurrentCycleStartDate(16, today);
      expect(start, DateTime(2024, 12, 16));
    });

    test('next cycle is day 16 of next month', () {
      final today = DateTime(2025, 3, 16);
      final next = CycleDateUtils.getNextCycleStartDate(16, today);
      expect(next, DateTime(2025, 4, 16));
    });

    test('end date is day before next start', () {
      final start = DateTime(2025, 3, 16);
      final end = CycleDateUtils.getCycleEndDate(start, 16);
      expect(end, DateTime(2025, 4, 15));
    });
  });

  group('sameCycle', () {
    test('matches identical dates', () {
      expect(
        CycleDateUtils.sameCycle(
            DateTime(2025, 3, 1), DateTime(2025, 3, 1, 12, 30)),
        isTrue,
      );
    });

    test('differs across months', () {
      expect(
        CycleDateUtils.sameCycle(DateTime(2025, 3, 1), DateTime(2025, 4, 1)),
        isFalse,
      );
    });
  });
}
