import 'package:uuid/uuid.dart';

import '../models/customer_model.dart';
import '../models/customer_snapshot_model.dart';
import '../models/group_model.dart';
import '../models/monthly_history_model.dart';
import '../utils/date_utils.dart';
import 'local_database_service.dart';

/// =============================================================================
/// CYCLE / MONTHLY RESET LOGIC
/// =============================================================================
/// This is the most important piece of business logic in the app.
///
/// Each group renews on a calendar day (1 or 16). On every app startup we
/// recompute the *current cycle start date* for each group:
///   - If it MATCHES the group's `lastResetCycleStartDate`, we are still in
///     the same cycle → do nothing.
///   - If it is DIFFERENT, the calendar has rolled into a new cycle. We must:
///       1. Snapshot the previous cycle to MonthlyHistory.
///       2. Reset all active customers in that group (isPaid = false,
///          lastPaidDate = null).
///       3. Update currentCycleStartDate to the new cycle start.
///       4. Update lastResetCycleStartDate to the new cycle start.
///       5. Do NOT delete customers.
///       6. Do NOT reset more than once per cycle — step 4 guarantees this:
///          the next startup will compare against the new
///          lastResetCycleStartDate, find them equal, and skip the reset.
/// =============================================================================
class CycleService {
  final LocalDatabaseService _db;
  CycleService(this._db);

  /// Runs at startup. Performs the reset for any group whose new cycle has
  /// begun since the last reset.
  Future<void> checkAndResetCycles({DateTime? now}) async {
    final today = now ?? DateTime.now();
    final groups = _db.groupsBox.values.toList();

    for (final group in groups) {
      final newCycleStart =
          CycleDateUtils.getCurrentCycleStartDate(group.renewalDay, today);

      // If we have already reset for this exact cycle start, skip.
      if (CycleDateUtils.sameCycle(
          newCycleStart, group.lastResetCycleStartDate)) {
        continue;
      }

      // 1) Snapshot the *previous* cycle BEFORE we wipe payment state.
      await _snapshotCycle(group);

      // 2) Reset payments for all active customers of this group.
      await _resetCustomersForGroup(group.id);

      // 3+4) Update both cycle pointers atomically.
      final updated = group.copyWith(
        currentCycleStartDate: newCycleStart,
        lastResetCycleStartDate: newCycleStart,
      );
      await _db.groupsBox.put(updated.id, updated);
    }
  }

  /// Builds a MonthlyHistory record from the group's *current* in-memory
  /// state (which still reflects the cycle that is about to close).
  Future<void> _snapshotCycle(Group group) async {
    final customers = _db.customersBox.values
        .where((c) => c.groupId == group.id && c.isActive)
        .toList();

    final paidTotal = customers
        .where((c) => c.isPaid)
        .fold<double>(0.0, (sum, c) => sum + c.price);
    final pendingTotal = customers
        .where((c) => !c.isPaid)
        .fold<double>(0.0, (sum, c) => sum + c.price);
    final expected = paidTotal + pendingTotal;
    final net = paidTotal - group.currentCompanyCost;

    final snapshots = customers
        .map((c) => CustomerSnapshot(
              name: c.name,
              phone: c.phone,
              gigabytes: c.gigabytes,
              price: c.price,
              isPaid: c.isPaid,
              paidDate: c.lastPaidDate,
              notes: c.notes,
            ))
        .toList();

    final history = MonthlyHistory(
      id: const Uuid().v4(),
      groupId: group.id,
      groupName: group.name,
      cycleStartDate: group.currentCycleStartDate,
      cycleEndDate: CycleDateUtils.getCycleEndDate(
          group.currentCycleStartDate, group.renewalDay),
      companyCost: group.currentCompanyCost,
      totalCollected: paidTotal,
      totalPending: pendingTotal,
      totalExpectedSales: expected,
      netProfit: net,
      customersSnapshot: snapshots,
    );

    await _db.historyBox.put(history.id, history);
  }

  Future<void> _resetCustomersForGroup(String groupId) async {
    final customers = _db.customersBox.values
        .where((c) => c.groupId == groupId && c.isActive)
        .toList();
    for (final c in customers) {
      final reset = c.copyWith(isPaid: false, clearLastPaidDate: true);
      await _db.customersBox.put(reset.id, reset);
    }
  }
}
