import 'package:hive/hive.dart';


/// Defines the billing plan types for passengers.
///
/// `monthlyFull`: fixed monthly rate for both sessions.
/// `monthlyMorning`: fixed monthly rate for morning sessions only.
/// `monthlyAfternoon`: fixed monthly rate for afternoon sessions only.
/// `daily`: per-session rate.
@HiveType(typeId: 1)
enum PlanType {
  @HiveField(0)
  monthlyFull,
  @HiveField(1)
  monthlyMorning,
  @HiveField(2)
  monthlyAfternoon,
  @HiveField(3)
  daily,
}

/// Adapter for serializing [PlanType] with Hive.
class PlanTypeAdapter extends TypeAdapter<PlanType> {
  @override
  final int typeId = 1;

  @override
  PlanType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PlanType.monthlyFull;
      case 1:
        return PlanType.monthlyMorning;
      case 2:
        return PlanType.monthlyAfternoon;
      case 3:
        return PlanType.daily;
      default:
        return PlanType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, PlanType obj) {
    switch (obj) {
      case PlanType.monthlyFull:
        writer.writeByte(0);
        break;
      case PlanType.monthlyMorning:
        writer.writeByte(1);
        break;
      case PlanType.monthlyAfternoon:
        writer.writeByte(2);
        break;
      case PlanType.daily:
        writer.writeByte(3);
        break;
    }
  }
}