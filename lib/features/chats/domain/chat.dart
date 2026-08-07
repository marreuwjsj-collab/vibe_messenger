class Chat {
  final String id;
  final String title;
  final String preview;
  final DateTime updatedAt;
  final int unreadCount;

  const Chat({
    required this.id,
    required this.title,
    required this.preview,
    required this.updatedAt,
    this.unreadCount = 0,
  });
}
