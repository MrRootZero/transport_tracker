import 'package:hive/hive.dart';
import 'session.dart';

/// Represents a single trip session for a passenger on a given date.
/// Each [TripEntry] is one session (morning or afternoon).
@HiveType(typeId: 4)
class TripEntry extends HiveObject {
  @HiveField(0)
  String id;

  /// Passenger Hive key (same as Passenger.id).
  @HiveField(1)
  String passengerId;

  /// Date of the trip (only date portion considered).
  @HiveField(2)
  DateTime date;

  /// One entry is a single session (morning or afternoon).
  @HiveField(3)
  Session session;

  @HiveField(4)
  DateTime createdAt;

  TripEntry({
    required this.id,
    required this.passengerId,
    required this.date,
    required this.session,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// Adapter for serializing [TripEntry] with Hive.
class TripEntryAdapter extends TypeAdapter<TripEntry> {
  @override
  final int typeId = 4;

  @override
  TripEntry read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < n; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return TripEntry(
      id: fields[0] as String,
      passengerId: fields[1] as String,
      date: fields[2] as DateTime,
      session: fields[3] as Session,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TripEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.passengerId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.session)
      ..writeByte(4)
      ..write(obj.createdAt);
  }
}