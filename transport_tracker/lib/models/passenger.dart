import 'package:hive/hive.dart';
import 'plan_type.dart';

/// Represents a passenger who travels with you.
/// Stores their billing plan and rates.
@HiveType(typeId: 3)
class Passenger extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  /// Determines how billing works for this passenger.
  @HiveField(2)
  PlanType planType;

  /// Monthly rate applicable for monthly plans (Full/Morning/Afternoon).
  @HiveField(3)
  double? monthlyRate;

  /// Per-trip session rate for daily plan.
  @HiveField(4)
  double? perTripRate;

  @HiveField(5)
  bool active;

  @HiveField(6)
  DateTime createdAt;

  Passenger({
    required this.id,
    required this.name,
    required this.planType,
    this.monthlyRate,
    this.perTripRate,
    this.active = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// Adapter for serializing [Passenger] with Hive.
class PassengerAdapter extends TypeAdapter<Passenger> {
  @override
  final int typeId = 3;

  @override
  Passenger read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Passenger(
      id: fields[0] as String,
      name: fields[1] as String,
      planType: fields[2] as PlanType,
      monthlyRate: fields[3] as double?,
      perTripRate: fields[4] as double?,
      active: fields[5] as bool,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Passenger obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.planType)
      ..writeByte(3)
      ..write(obj.monthlyRate)
      ..writeByte(4)
      ..write(obj.perTripRate)
      ..writeByte(5)
      ..write(obj.active)
      ..writeByte(6)
      ..write(obj.createdAt);
  }
}