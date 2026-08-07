import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/chats/data/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return DemoChatRepository();
});
