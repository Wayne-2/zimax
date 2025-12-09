import 'package:hive/hive.dart';

part 'chatitem_hive.g.dart';

@HiveType(typeId: 1)
class ChatItemHive extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String preview;

  @HiveField(2)
  String avatar;

  @HiveField(3)
  String time;

  @HiveField(4)
  bool online;

  ChatItemHive({
    required this.name,
    required this.preview,
    required this.avatar,
    required this.time,
    this.online = false,
  });
}
