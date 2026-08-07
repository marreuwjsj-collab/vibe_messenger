import '../domain/chat.dart';

abstract interface class ChatRepository {
  Future<List<Chat>> getChats();
}

final class DemoChatRepository implements ChatRepository {
  @override
  Future<List<Chat>> getChats() async {
    final now = DateTime.now();
    return [
      Chat(id: '1', title: 'Алексей', preview: 'Залетаем в релиз?', updatedAt: now.subtract(const Duration(minutes: 2))),
      Chat(id: '2', title: 'Команда Vibe', preview: 'Денис: макеты готовы', updatedAt: now.subtract(const Duration(minutes: 18))),
      Chat(id: '3', title: 'Маркетинг', preview: 'Новый пост опубликован', updatedAt: now.subtract(const Duration(hours: 1))),
    ];
  }
}
