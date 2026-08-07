import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/chats/data/chat_repository.dart';
import '../../features/messages/data/sqlite_message_repository.dart';
import '../../features/messages/domain/message.dart';
import '../storage/database.dart';
import '../storage/secure_store.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final secureStoreProvider = Provider<SecureStore>((ref) {
  return const FlutterSecureStore();
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return DemoChatRepository();
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return SqliteMessageRepository(
    database: ref.watch(appDatabaseProvider),
    localUserId: 'local-user',
  );
});
