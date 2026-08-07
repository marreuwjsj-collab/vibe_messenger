import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../domain/chat.dart';

final chatListProvider = AsyncNotifierProvider<ChatListController, List<Chat>>(
  ChatListController.new,
);

final class ChatListController extends AsyncNotifier<List<Chat>> {
  @override
  Future<List<Chat>> build() async {
    return ref.read(chatRepositoryProvider).getChats();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(chatRepositoryProvider).getChats(),
    );
  }
}
