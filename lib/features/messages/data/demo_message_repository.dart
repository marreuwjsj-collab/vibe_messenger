import '../domain/message.dart';

/// Deterministic development repository. Replace with a network-backed
/// implementation behind [MessageRepository] for staging/production.
final class DemoMessageRepository implements MessageRepository {
  final List<Message> _messages = <Message>[];

  DemoMessageRepository() {
    final now = DateTime.now().toUtc();
    _messages.addAll([
      Message(id: 'm1', chatId: '1', senderId: 'demo', text: 'Добро пожаловать в Vibe.', createdAt: now.subtract(const Duration(minutes: 3))),
      Message(id: 'm2', chatId: '1', senderId: 'demo', text: 'Это development message engine.', createdAt: now.subtract(const Duration(minutes: 2))),
    ]);
  }

  @override
  Future<List<Message>> getMessages(String chatId, {String? cursor, int limit = 50}) async {
    final result = _messages.where((message) => message.chatId == chatId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return result.take(limit).toList(growable: false);
  }

  @override
  Future<Message> sendMessage({required String chatId, required String senderId, required String text}) async {
    final value = text.trim();
    if (value.isEmpty) throw ArgumentError.value(text, 'text', 'Message cannot be empty');
    final message = Message(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      chatId: chatId,
      senderId: senderId,
      text: value,
      createdAt: DateTime.now().toUtc(),
      status: MessageStatus.sent,
    );
    _messages.add(message);
    return message;
  }
}
