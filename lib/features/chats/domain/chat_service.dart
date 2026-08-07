import '../domain/chat.dart';

final class ChatService {
  final ChatRepository repository;
  const ChatService(this.repository);
  Future<List<Chat>> load() => repository.getChats();
}
