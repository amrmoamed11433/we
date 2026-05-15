import 'package:hive/hive.dart';
import 'customer_snapshot_model.dart';

/// One closed cycle for one group.
class MonthlyHistory {
  final String id;
  final String groupId;
  final String groupName;
  final DateTime cycleStartDate;
  final DateTime cycleEndDate;
  final double companyCost;
  final double totalCollected;
  final double totalPending;
  final double totalExpectedSales;
  final double netProfit;
  final List<CustomerSnapshot> customersSnapshot;

  const MonthlyHistory({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.cycleStartDate,
    required this.cycleEndDate,
    required this.companyCost,
    required this.totalCollected,
    required this.totalPending,
    required this.totalExpectedSales,
    required this.netProfit,
    required this.customersSnapshot,
  });
}

class MonthlyHistoryAdapter extends TypeAdapter<MonthlyHistory> {
  @override
  final int typeId = 4;

  @override
  MonthlyHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };
    return MonthlyHistory(
      id: fields[0] as String,
      groupId: fields[1] as String,
      groupName: fields[2] as String,
      cycleStartDate: fields[3] as DateTime,
      cycleEndDate: fields[4] as DateTime,
      companyCost: fields[5] as double,
      totalCollected: fields[6] as double,
      totalPending: fields[7] as double,
      totalExpectedSales: fields[8] as double,
      netProfit: fields[9] as double,
      customersSnapshot: (fields[10] as List).cast<CustomerSnapshot>(),
    );
  }

  @override
  void write(BinaryWriter writer, MonthlyHistory obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.groupId)
      ..writeByte(2)
      ..write(obj.groupName)
      ..writeByte(3)
      ..write(obj.cycleStartDate)
      ..writeByte(4)
      ..write(obj.cycleEndDate)
      ..writeByte(5)
      ..write(obj.companyCost)
      ..writeByte(6)
      ..write(obj.totalCollected)
      ..writeByte(7)
      ..write(obj.totalPending)
      ..writeByte(8)
      ..write(obj.totalExpectedSales)
      ..writeByte(9)
      ..write(obj.netProfit)
      ..writeByte(10)
      ..write(obj.customersSnapshot);
  }
}
