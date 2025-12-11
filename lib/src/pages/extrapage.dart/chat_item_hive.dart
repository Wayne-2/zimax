import 'package:hive/hive.dart';

part 'chat_item_hive.g.dart';

@HiveType(typeId: 1)
class ChatItemHive extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String preview;

  @HiveField(2)
  final String avatar;

  @HiveField(3)
  final String userId;

  @HiveField(4)
  final String time;

  @HiveField(5)
  final bool verified;

  @HiveField(6)
  final bool online;

  ChatItemHive({
    required this.name,
    required this.preview,
    required this.avatar,
    required this.userId,
    required this.time,
    this.verified = false,
    this.online = false,
  });
}
