import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/customer_model.dart';
import '../models/group_model.dart';
import '../models/monthly_history_model.dart';
import '../services/cycle_service.dart';
import '../services/history_service.dart';
import '../services/local_database_service.dart';
import '../utils/date_utils.dart';

class AppProvider extends ChangeNotifier {
  final LocalDatabaseService db;
  final CycleService cycleService;
  final HistoryService historyService;

  AppProvider({
    required this.db,
    required this.cycleService,
    required this.historyService,
  });

  static const int maxCustomersPerGroup = 6;
  static const int maxGroups = 3;

  // ---------------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------------

  List<Group> get groups {
    final list = db.groupsBox.values.toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  Group? groupById(String id) {
    try {
      return db.groupsBox.get(id);
    } catch (_) {
      return null;
    }
  }

  List<Customer> customersOf(String groupId) {
    return db.customersBox.values
        .where((c) => c.groupId == groupId && c.isActive)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  int activeCustomerCountOf(String groupId) => customersOf(groupId).length;

  // ---------------------------------------------------------------------------
  // Group calculations
  // ---------------------------------------------------------------------------

  double groupCollected(String groupId) => customersOf(groupId)
      .where((c) => c.isPaid)
      .fold<double>(0.0, (sum, c) => sum + c.price);

  double groupPending(String groupId) => customersOf(groupId)
      .where((c) => !c.isPaid)
      .fold<double>(0.0, (sum, c) => sum + c.price);

  double groupExpectedSales(String groupId) =>
      groupCollected(groupId) + groupPending(groupId);

  double groupNetProfit(Group g) =>
      groupCollected(g.id) - g.currentCompanyCost;

  // ---------------------------------------------------------------------------
  // Dashboard calculations
  // ---------------------------------------------------------------------------

  double get dashboardTotalCollected {
    return groups.fold<double>(0.0, (sum, g) => sum + groupCollected(g.id));
  }

  double get dashboardTotalPending {
    return groups.fold<double>(0.0, (sum, g) => sum + groupPending(g.id));
  }

  double get dashboardExpectedSales =>
      dashboardTotalCollected + dashboardTotalPending;

  double get dashboardCompanyCosts =>
      groups.fold<double>(0.0, (sum, g) => sum + g.currentCompanyCost);

  double get dashboardNetProfit =>
      dashboardTotalCollected - dashboardCompanyCosts;

  int get paidCustomersCount {
    return db.customersBox.values
        .where((c) => c.isActive && c.isPaid)
        .length;
  }

  int get unpaidCustomersCount {
    return db.customersBox.values
        .where((c) => c.isActive && !c.isPaid)
        .length;
  }

  // ---------------------------------------------------------------------------
  // History
  // ---------------------------------------------------------------------------

  List<MonthlyHistory> history({String? groupId}) {
    if (groupId == null) return historyService.all();
    return historyService.byGroup(groupId);
  }

  // ---------------------------------------------------------------------------
  // Mutations — Groups
  // ---------------------------------------------------------------------------

  Future<void> updateGroup({
    required String id,
    String? name,
    int? renewalDay,
    double? companyCost,
  }) async {
    final g = db.groupsBox.get(id);
    if (g == null) return;

    var updated = g.copyWith(
      name: name,
      renewalDay: renewalDay,
      currentCompanyCost: companyCost,
    );

    // If the renewal day was changed, recompute the current cycle start so the
    // dashboard / details screen reflect the new schedule immediately.
    if (renewalDay != null && renewalDay != g.renewalDay) {
      final newStart = CycleDateUtils.getCurrentCycleStartDate(
          renewalDay, DateTime.now());
      updated = updated.copyWith(
        currentCycleStartDate: newStart,
        lastResetCycleStartDate: newStart,
      );
    }

    await db.groupsBox.put(id, updated);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Mutations — Customers
  // ---------------------------------------------------------------------------

  /// Returns false if the group already has [maxCustomersPerGroup] active
  /// customers.
  Future<bool> addCustomer({
    required String groupId,
    required String name,
    required String phone,
    required double gigabytes,
    required double price,
    String notes = '',
  }) async {
    if (activeCustomerCountOf(groupId) >= maxCustomersPerGroup) {
      return false;
    }
    final c = Customer(
      id: const Uuid().v4(),
      groupId: groupId,
      name: name,
      phone: phone,
      gigabytes: gigabytes,
      price: price,
      notes: notes,
    );
    await db.customersBox.put(c.id, c);
    notifyListeners();
    return true;
  }

  Future<void> updateCustomer({
    required String id,
    String? name,
    String? phone,
    double? gigabytes,
    double? price,
    String? notes,
  }) async {
    final c = db.customersBox.get(id);
    if (c == null) return;
    final updated = c.copyWith(
      name: name,
      phone: phone,
      gigabytes: gigabytes,
      price: price,
      notes: notes,
    );
    await db.customersBox.put(id, updated);
    notifyListeners();
  }

  Future<void> deleteCustomer(String id) async {
    await db.customersBox.delete(id);
    notifyListeners();
  }

  Future<void> markPaid(String id) async {
    final c = db.customersBox.get(id);
    if (c == null) return;
    final updated = c.copyWith(isPaid: true, lastPaidDate: DateTime.now());
    await db.customersBox.put(id, updated);
    notifyListeners();
  }

  Future<void> markUnpaid(String id) async {
    final c = db.customersBox.get(id);
    if (c == null) return;
    final updated = c.copyWith(isPaid: false, clearLastPaidDate: true);
    await db.customersBox.put(id, updated);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Demo reset
  // ---------------------------------------------------------------------------

  Future<void> resetDemoData() async {
    await db.resetAllAndReseed();
    notifyListeners();
  }

  /// Should be called once after services are ready, before notifying the UI.
  Future<void> bootstrap() async {
    await cycleService.checkAndResetCycles();
    notifyListeners();
  }
}
