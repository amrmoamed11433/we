import 'package:hive/hive.dart';

/// Group model representing one of the 3 fixed WE package groups.
/// Each group has its own renewal cycle (day 1 or day 16 of each month).
class Group {
  final String id;
  String name;
  int renewalDay; // 1 or 16
  double currentCompanyCost;
  DateTime currentCycleStartDate;
  DateTime lastResetCycleStartDate;

  Group({
    required this.id,
    required this.name,
    required this.renewalDay,
    required this.currentCompanyCost,
    required this.currentCycleStartDate,
    required this.lastResetCycleStartDate,
  });

  Group copyWith({
    String? name,
    int? renewalDay,
    double? currentCompanyCost,
    DateTime? currentCycleStartDate,
    DateTime? lastResetCycleStartDate,
  }) {
    return Group(
      id: id,
      name: name ?? this.name,
      renewalDay: renewalDay ?? this.renewalDay,
      currentCompanyCost: currentCompanyCost ?? this.currentCompanyCost,
      currentCycleStartDate:
          currentCycleStartDate ?? this.currentCycleStartDate,
      lastResetCycleStartDate:
          lastResetCycleStartDate ?? this.lastResetCycleStartDate,
    );
  }
}

/// Manual Hive adapter — no build_runner required at build time.
class GroupAdapter extends TypeAdapter<Group> {
  @override
  final int typeId = 1;

  @override
  Group read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };
    return Group(
      id: fields[0] as String,
      name: fields[1] as String,
      renewalDay: fields[2] as int,
      currentCompanyCost: fields[3] as double,
      currentCycleStartDate: fields[4] as DateTime,
      lastResetCycleStartDate: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Group obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.renewalDay)
      ..writeByte(3)
      ..write(obj.currentCompanyCost)
      ..writeByte(4)
      ..write(obj.currentCycleStartDate)
      ..writeByte(5)
      ..write(obj.lastResetCycleStartDate);
  }
}
