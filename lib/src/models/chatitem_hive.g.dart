// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatitem_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatItemHiveAdapter extends TypeAdapter<ChatItemHive> {
  @override
  final int typeId = 1;

  @override
  ChatItemHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatItemHive(
      name: fields[0] as String,
      preview: fields[1] as String,
      avatar: fields[2] as String,
      time: fields[3] as String,
      online: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ChatItemHive obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.preview)
      ..writeByte(2)
      ..write(obj.avatar)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.online);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatItemHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
