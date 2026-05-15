import 'package:hive/hive.dart';

/// Immutable snapshot of a customer at the time a cycle was closed.
class CustomerSnapshot {
  final String name;
  final String phone;
  final double gigabytes;
  final double price;
  final bool isPaid;
  final DateTime? paidDate;
  final String notes;

  const CustomerSnapshot({
    required this.name,
    required this.phone,
    required this.gigabytes,
    required this.price,
    required this.isPaid,
    required this.paidDate,
    required this.notes,
  });
}

class CustomerSnapshotAdapter extends TypeAdapter<CustomerSnapshot> {
  @override
  final int typeId = 3;

  @override
  CustomerSnapshot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };
    return CustomerSnapshot(
      name: fields[0] as String,
      phone: fields[1] as String,
      gigabytes: fields[2] as double,
      price: fields[3] as double,
      isPaid: fields[4] as bool,
      paidDate: fields[5] as DateTime?,
      notes: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerSnapshot obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.gigabytes)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.isPaid)
      ..writeByte(5)
      ..write(obj.paidDate)
      ..writeByte(6)
      ..write(obj.notes);
  }
}
