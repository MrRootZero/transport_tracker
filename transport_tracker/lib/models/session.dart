import 'package:hive/hive.dart';

/// Represents the two possible trip sessions: morning or afternoon.
@HiveType(typeId: 2)
enum Session {
  @HiveField(0)
  morning,
  @HiveField(1)
  afternoon,
}

/// Adapter for serializing [Session] with Hive.
class SessionAdapter extends TypeAdapter<Session> {
  @override
  final int typeId = 2;

  @override
  Session read(BinaryReader reader) {
    return reader.readByte() == 0 ? Session.morning : Session.afternoon;
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer.writeByte(obj == Session.morning ? 0 : 1);
  }
}