import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/group_model.dart';
import '../models/customer_model.dart';
import '../models/customer_snapshot_model.dart';
import '../models/monthly_history_model.dart';
import '../utils/date_utils.dart';

class LocalDatabaseService {
  static const String groupsBoxName = 'groups_box';
  static const String customersBoxName = 'customers_box';
  static const String historyBoxName = 'history_box';

  static const String _firstLaunchKey = 'we_first_launch_done_v1';

  late Box<Group> _groupsBox;
  late Box<Customer> _customersBox;
  late Box<MonthlyHistory> _historyBox;

  Box<Group> get groupsBox => _groupsBox;
  Box<Customer> get customersBox => _customersBox;
  Box<MonthlyHistory> get historyBox => _historyBox;

  /// Must be called from main() before runApp.
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(GroupAdapter());
    Hive.registerAdapter(CustomerAdapter());
    Hive.registerAdapter(CustomerSnapshotAdapter());
    Hive.registerAdapter(MonthlyHistoryAdapter());
  }

  Future<void> open() async {
    _groupsBox = await Hive.openBox<Group>(groupsBoxName);
    _customersBox = await Hive.openBox<Customer>(customersBoxName);
    _historyBox = await Hive.openBox<MonthlyHistory>(historyBoxName);
  }

  /// Seed the 3 default groups + a couple of demo customers on the very first
  /// launch only. Subsequent launches see [_firstLaunchKey] and skip seeding.
  Future<void> ensureFirstLaunchSeed() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_firstLaunchKey) == true) return;

    await _seedDefaultGroups();
    await _seedDemoCustomers();

    await prefs.setBool(_firstLaunchKey, true);
  }

  Future<void> _seedDefaultGroups() async {
    await _groupsBox.clear();
    final today = DateTime.now();

    final groups = <Group>[
      _buildGroup(name: 'Group 1', renewalDay: 1, today: today),
      _buildGroup(name: 'Group 2', renewalDay: 16, today: today),
      _buildGroup(name: 'Group 3', renewalDay: 1, today: today),
    ];
    for (final g in groups) {
      await _groupsBox.put(g.id, g);
    }
  }

  Group _buildGroup({
    required String name,
    required int renewalDay,
    required DateTime today,
  }) {
    final start = CycleDateUtils.getCurrentCycleStartDate(renewalDay, today);
    return Group(
      id: const Uuid().v4(),
      name: name,
      renewalDay: renewalDay,
      currentCompanyCost: 0,
      currentCycleStartDate: start,
      lastResetCycleStartDate: start,
    );
  }

  Future<void> _seedDemoCustomers() async {
    await _customersBox.clear();
    final uuid = const Uuid();
    final groups = _groupsBox.values.toList();
    if (groups.isEmpty) return;

    // 2 demo customers in each group
    for (var i = 0; i < groups.length; i++) {
      final g = groups[i];
      final c1 = Customer(
        id: uuid.v4(),
        groupId: g.id,
        name: 'Demo ${i + 1}-A',
        phone: '0100000000${i}1',
        gigabytes: 20,
        price: 200,
      );
      final c2 = Customer(
        id: uuid.v4(),
        groupId: g.id,
        name: 'Demo ${i + 1}-B',
        phone: '0100000000${i}2',
        gigabytes: 40,
        price: 350,
      );
      await _customersBox.put(c1.id, c1);
      await _customersBox.put(c2.id, c2);
    }
  }

  /// Used by the Settings "Reset Demo Data" action.
  Future<void> resetAllAndReseed() async {
    await _groupsBox.clear();
    await _customersBox.clear();
    await _historyBox.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firstLaunchKey);
    await ensureFirstLaunchSeed();
  }
}
