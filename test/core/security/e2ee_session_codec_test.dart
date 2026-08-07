import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/core/security/e2ee_session_codec.dart';
import '../../../lib/features/messages/domain/e2ee_session.dart';

void main(){
  test('session codec round trips ratchet and skipped keys',(){final s=E2eeSessionState(sessionId:'s',peerKeyId:'k',role:E2eeRole.initiator,rootKey:Uint8List(32),sendChainKey:Uint8List.fromList(List.filled(32,1)),receiveChainKey:Uint8List.fromList(List.filled(32,2)),sendCounter:4,receiveCounter:7,skippedMessageKeys:{5:Uint8List.fromList(List.filled(32,3))});final restored=E2eeSessionCodec.decode(E2eeSessionCodec.encode(s));expect(restored.sessionId,'s');expect(restored.sendCounter,4);expect(restored.receiveCounter,7);expect(restored.skippedMessageKeys[5],isNotNull);});
  test('rejects invalid version',()=>expect(()=>E2eeSessionCodec.decode('{"v":99}'),throwsFormatException));
}
