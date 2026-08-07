import 'dart:convert';
import 'dart:typed_data';
import '../../features/messages/domain/e2ee_session.dart';

final class E2eeSessionSnapshot {
  final E2eeSessionState state;
  const E2eeSessionSnapshot(this.state);

  String encode() => jsonEncode({'v': 2, 'sessionId': state.sessionId, 'peerKeyId': state.peerKeyId, 'role': state.role.name, 'rootKey': base64Encode(state.rootKey), 'sendChainKey': base64Encode(state.sendChainKey), 'receiveChainKey': base64Encode(state.receiveChainKey), 'sendCounter': state.sendCounter, 'receiveCounter': state.receiveCounter, 'skipped': [for (final e in state.skippedMessageKeys.entries) {'n': e.key, 'k': base64Encode(e.value)}]});

  static E2eeSessionSnapshot decode(String encoded) {
    final value = jsonDecode(encoded);
    if (value is! Map<String, dynamic> || value['v'] != 2) throw const FormatException('Unsupported E2EE session snapshot');
    final raw = value['skipped'];
    if (raw is! List || raw.length > 256) throw const FormatException('Invalid skipped-key state');
    final skipped = <int, Uint8List>{};
    for (final item in raw) {
      if (item is! Map || item['n'] is! int || item['k'] is! String) throw const FormatException('Invalid skipped-key entry');
      final key = base64Decode(item['k'] as String);
      if (key.length != 32 || (item['n'] as int) < 0) throw const FormatException('Invalid skipped-key');
      skipped[item['n'] as int] = Uint8List.fromList(key);
    }
    return E2eeSessionSnapshot(E2eeSessionState(
      sessionId: value['sessionId'] as String,
      peerKeyId: value['peerKeyId'] as String,
      role: E2eeRole.values.byName(value['role'] as String),
      rootKey: Uint8List.fromList(base64Decode(value['rootKey'] as String)),
      sendChainKey: Uint8List.fromList(base64Decode(value['sendChainKey'] as String)),
      receiveChainKey: Uint8List.fromList(base64Decode(value['receiveChainKey'] as String)),
      sendCounter: value['sendCounter'] as int,
      receiveCounter: value['receiveCounter'] as int,
      skippedMessageKeys: skipped,
    ));
  }
}
