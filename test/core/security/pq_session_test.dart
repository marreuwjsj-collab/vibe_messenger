import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_messenger/core/security/pq_session.dart';

void main() {
  test('derives distinct sequential send keys', () async {
    final session = PqSession(
      sessionId: 'test-session',
      rootKey: Uint8List(32),
      sendingChain: Uint8List.fromList(List<int>.filled(32, 1)),
      receivingChain: Uint8List.fromList(List<int>.filled(32, 2)),
    );

    final first = await session.nextSendKey();
    final second = await session.nextSendKey();

    expect(first, hasLength(32));
    expect(second, hasLength(32));
    expect(first, isNot(equals(second)));
    expect(session.sendCounter, 2);
  });

  test('send and receive directions do not share a key', () async {
    final session = PqSession(
      sessionId: 'test-session',
      rootKey: Uint8List(32),
      sendingChain: Uint8List.fromList(List<int>.filled(32, 7)),
      receivingChain: Uint8List.fromList(List<int>.filled(32, 7)),
    );

    final send = await session.nextSendKey();
    final receive = await session.nextReceiveKey();

    expect(send, isNot(equals(receive)));
  });
}
