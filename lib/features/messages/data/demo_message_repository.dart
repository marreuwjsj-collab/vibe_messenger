import 'package:uuid/uuid.dart';

import '../domain/message.dart';

final class DemoMessageRepository implements MessageRepository {
  static const _uuid = Uuid();

  @override
  Future<List<Message>> getMessages(String chatId, {String? cursor, int limit = 50}) async {
    final now = DateTime.now();
    return [
      Message(id: 'demo-1', chatId: chatId, senderId: 'other', text: 'Добро пожаловать в Vibe.', createdAt: now.subtract(const Duration(minutes: 3))),
      Message(id: 'demo-2', chatId: chatId, senderId: 'me', text: 'Делаем по-взрослому.', createdAt: now.subtract(const Duration(minutes: 2)), status: MessageStatus.read),
    ];
  }

  @override
  Future<Message> sendMessage({required String chatId, required String senderId, required String text}) async {
    return Message(id: _uuid.v4(), chatId: chatId, senderId: senderId, text: text, createdAt: DateTime.now(), status: MessageStatus.sent);
  }
}
