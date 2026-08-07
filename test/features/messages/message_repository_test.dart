import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_messenger/features/messages/data/demo_message_repository.dart';

void main() {
  test('demo message repository returns messages', () async {
    final repository = DemoMessageRepository();
    final messages = await repository.getMessages('chat-1');
    expect(messages, isNotEmpty);
    expect(messages.first.chatId, 'chat-1');
  });
}
