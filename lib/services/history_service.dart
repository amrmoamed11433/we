import '../models/monthly_history_model.dart';
import 'local_database_service.dart';

class HistoryService {
  final LocalDatabaseService _db;
  HistoryService(this._db);

  List<MonthlyHistory> all() {
    final list = _db.historyBox.values.toList();
    list.sort((a, b) => b.cycleStartDate.compareTo(a.cycleStartDate));
    return list;
  }

  List<MonthlyHistory> byGroup(String groupId) {
    return all().where((h) => h.groupId == groupId).toList();
  }
}
