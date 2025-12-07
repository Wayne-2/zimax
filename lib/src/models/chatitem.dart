class ChatItem {
  final String name;
  final String preview;
  final String avatar;
  final String time;
  final bool verified;
  final bool online;

  ChatItem({
    required this.name,
    required this.preview,
    required this.avatar,
    required this.time,
    this.verified = false,
    this.online = false,
  });
}
