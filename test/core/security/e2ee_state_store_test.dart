import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/core/security/e2ee_state_store.dart';
import '../../../lib/features/messages/domain/e2ee_session.dart';

void main() {
  test('E2EE state round-trips including skipped keys', () {
    final state = E2eeSessionState(sessionId: 's1', peerKeyId: 'k1', role: E2eeRole.initiator, rootKey: Uint8List.fromList(List<int>.filled(32, 1)), sendChainKey: Uint8List.fromList(List<int>.filled(32, 2)), receiveChainKey: Uint8List.fromList(List<int>.filled(32, 3)), sendCounter: 7, receiveCounter: 9, skippedMessageKeys: {8: Uint8List.fromList(List<int>.filled(32, 4))});
    final restored = E2eeSessionCodec.decode(E2eeSessionCodec.encode(state));
    expect(restored.sessionId, state.sessionId);
    expect(restored.sendCounter, 7);
    expect(restored.receiveCounter, 9);
    expect(restored.skippedMessageKeys[8], orderedEquals(List<int>.filled(32, 4)));
  });

  test('rejects wrong version', () {
    expect(() => E2eeSessionCodec.decode('{"v":1}'), throwsFormatException);
  });
}
