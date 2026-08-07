import 'package:uuid/uuid.dart';

import '../domain/message.dart';

final class InMemoryMessageRepository implements MessageRepository {
  final List<Message> _messages = <Message>[];
  final Uuid _uuid;

  InMemoryMessageRepository({Uuid uuid = const Uuid()}) : _uuid = uuid;

  @override
  Future<List<Message>> getMessages(String chatId, {String? cursor, int limit = 50}) async {
    final result = _messages.where((m) => m.chatId == chatId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result.take(limit).toList(growable: false);
  }

  @override
  Future<Message> sendMessage({required String chatId, required String senderId, required String text}) async {
    final normalized = text.trim();
    if (normalized.isEmpty) throw ArgumentError.value(text, 'text', 'Message cannot be empty');
    final message = Message(
      id: _uuid.v4(),
      chatId: chatId,
      senderId: senderId,
      text: normalized,
      createdAt: DateTime.now().toUtc(),
      status: MessageStatus.sent,
    );
    _messages.add(message);
    return message;
  }
}
