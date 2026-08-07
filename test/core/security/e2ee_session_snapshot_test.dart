import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_messenger/core/security/e2ee_session_snapshot.dart';
import 'package:vibe_messenger/features/messages/domain/e2ee_session.dart';

void main() {
  final state = E2eeSessionState(sessionId: 's1', peerKeyId: 'k1', role: E2eeRole.responder, rootKey: List<int>.filled(32, 1).toUint8List(), sendChainKey: List<int>.filled(32, 2).toUint8List(), receiveChainKey: List<int>.filled(32, 3).toUint8List(), sendCounter: 4, receiveCounter: 7, skippedMessageKeys: {5: List<int>.filled(32, 9).toUint8List()});

  test('round trips ratchet and skipped keys', () {
    final restored = E2eeSessionSnapshot.decode(E2eeSessionSnapshot(state).encode()).state;
    expect(restored.sessionId, state.sessionId);
    expect(restored.peerKeyId, state.peerKeyId);
    expect(restored.role, state.role);
    expect(restored.sendCounter, 4);
    expect(restored.receiveCounter, 7);
    expect(restored.skippedMessageKeys[5], state.skippedMessageKeys[5]);
  });

  test('rejects unsupported versions', () {
    expect(() => E2eeSessionSnapshot.decode('{"v":1}'), throwsFormatException);
  });
}

extension on List<int> {
  List<int> toUint8List() => this;
}
