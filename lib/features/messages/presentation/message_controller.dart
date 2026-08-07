import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../domain/message.dart';

final messageListProvider = AsyncNotifierProviderFamily<MessageController, List<Message>, String>(
  MessageController.new,
);

final class MessageController extends FamilyAsyncNotifier<List<Message>, String> {
  @override
  Future<List<Message>> build(String chatId) async {
    return ref.read(messageRepositoryProvider).getMessages(chatId);
  }

  Future<void> send({required String senderId, required String text}) async {
    final value = await ref.read(messageRepositoryProvider).sendMessage(
          chatId: arg,
          senderId: senderId,
          text: text,
        );
    state = AsyncData([...state.valueOrNull ?? const [], value]);
  }
}
