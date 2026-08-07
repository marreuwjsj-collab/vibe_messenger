import '../domain/message.dart';

final class DemoMessageRepository implements MessageRepository {
  @override
  Future<List<Message>> getMessages(String chatId, {String? cursor, int limit = 50}) async {
    return [
      Message(id: 'm1', chatId: chatId, senderId: 'demo', text: 'Добро пожаловать в Vibe.', createdAt: DateTime.now().subtract(const Duration(minutes: 3))),
      Message(id: 'm2', chatId: chatId, senderId: 'demo', text: 'Это локальный development engine.', createdAt: DateTime.now().subtract(const Duration(minutes: 2))),
    ];
  }

  @override
  Future<Message> sendMessage({required String chatId, required String senderId, required String text}) async {
    return Message(id: DateTime.now().microsecondsSinceEpoch.toString(), chatId: chatId, senderId: senderId, text: text, createdAt: DateTime.now(), status: MessageStatus.sent);
  }
}
