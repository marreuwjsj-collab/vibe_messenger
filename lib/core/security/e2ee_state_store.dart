import 'dart:convert';
import 'dart:typed_data';
import '../../features/messages/domain/e2ee_session.dart';

abstract interface class E2eeStateStore {
  Future<void> put(E2eeSessionState state);
  Future<E2eeSessionState?> get(String sessionId);
  Future<void> delete(String sessionId);
}

final class E2eeSessionCodec {
  static const int version = 2;

  static String encode(E2eeSessionState state) => jsonEncode({
        'v': version,
        'sid': state.sessionId,
        'peerKeyId': state.peerKeyId,
        'role': state.role.name,
        'root': base64Encode(state.rootKey),
        'send': base64Encode(state.sendChainKey),
        'recv': base64Encode(state.receiveChainKey),
        'sendCounter': state.sendCounter,
        'recvCounter': state.receiveCounter,
        'skipped': {for (final e in state.skippedMessageKeys.entries) e.key.toString(): base64Encode(e.value)},
      });

  static E2eeSessionState decode(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic> || decoded['v'] != version) throw const FormatException('Unsupported E2EE state version');
    final raw = decoded['skipped'];
    if (raw is! Map) throw const FormatException('Invalid skipped-key state');
    final skipped = <int, Uint8List>{};
    for (final e in raw.entries) {
      final counter = int.tryParse(e.key.toString());
      if (counter == null || e.value is! String) throw const FormatException('Invalid skipped-key entry');
      final key = base64Decode(e.value as String);
      if (key.length != 32) throw const FormatException('Invalid skipped-key length');
      skipped[counter] = Uint8List.fromList(key);
    }
    return E2eeSessionState(
      sessionId: decoded['sid'] as String,
      peerKeyId: decoded['peerKeyId'] as String,
      role: E2eeRole.values.byName(decoded['role'] as String),
      rootKey: Uint8List.fromList(base64Decode(decoded['root'] as String)),
      sendChainKey: Uint8List.fromList(base64Decode(decoded['send'] as String)),
      receiveChainKey: Uint8List.fromList(base64Decode(decoded['recv'] as String)),
      sendCounter: decoded['sendCounter'] as int,
      receiveCounter: decoded['recvCounter'] as int,
      skippedMessageKeys: skipped,
    );
  }
}
