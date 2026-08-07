enum MessageStatus { sending, sent, delivered, read, failed }

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final MessageStatus status;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.status = MessageStatus.sent,
  });
}

abstract interface class MessageRepository {
  Future<List<Message>> getMessages(String chatId, {String? cursor, int limit = 50});
  Future<Message> sendMessage({required String chatId, required String senderId, required String text});
}
