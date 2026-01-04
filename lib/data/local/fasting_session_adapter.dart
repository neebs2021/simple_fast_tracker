import 'package:hive/hive.dart';
import '../../domain/entities/fasting_session.dart';

class FastingSessionAdapter extends TypeAdapter<FastingSession> {
  @override
  final int typeId = 0;

  @override
  FastingSession read(BinaryReader reader) {
    final id = reader.readString();
    final startTime = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final hasEnd = reader.readBool();
    final endTime = hasEnd ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null;
    return FastingSession(id: id, startTime: startTime, endTime: endTime);
  }

  @override
  void write(BinaryWriter writer, FastingSession obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.startTime.millisecondsSinceEpoch);
    writer.writeBool(obj.endTime != null);
    if (obj.endTime != null) {
      writer.writeInt(obj.endTime!.millisecondsSinceEpoch);
    }
  }
}
