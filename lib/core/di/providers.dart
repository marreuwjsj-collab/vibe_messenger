import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/chats/data/chat_repository.dart';
import '../../features/messages/data/in_memory_message_repository.dart';
import '../../features/messages/domain/message.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return DemoChatRepository();
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return InMemoryMessageRepository();
});
