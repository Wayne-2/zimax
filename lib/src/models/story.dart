class StoryItem {
  final String id;
  final String name;
  final String? imageUrl;
  final String? avatar;
  final bool isText;
  final String? text;

  StoryItem({
    required this.id,
    required this.name,
    this.imageUrl,
    this.avatar,
    this.isText = false,
    this.text,
  });
}
