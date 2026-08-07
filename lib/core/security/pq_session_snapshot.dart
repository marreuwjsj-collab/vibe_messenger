import 'dart:convert';
import 'dart:typed_data';
import 'pq_session.dart';

final class PqSessionSnapshot {
  final String sessionId;
  final Uint8List rootKey;
  final Uint8List sendingChain;
  final Uint8List receivingChain;
  final int sendCounter;
  final int receiveCounter;

  const PqSessionSnapshot({required this.sessionId, required this.rootKey, required this.sendingChain, required this.receivingChain, required this.sendCounter, required this.receiveCounter});

  String encode() => jsonEncode({'v': 1, 'sessionId': sessionId, 'rootKey': base64Encode(rootKey), 'sendingChain': base64Encode(sendingChain), 'receivingChain': base64Encode(receivingChain), 'sendCounter': sendCounter, 'receiveCounter': receiveCounter});

  static PqSessionSnapshot decode(String value) {
    final map = jsonDecode(value);
    if (map is! Map<String, dynamic> || map['v'] != 1) throw const FormatException('Unsupported PQ session snapshot');
    return PqSessionSnapshot(
      sessionId: map['sessionId'] as String,
      rootKey: Uint8List.fromList(base64Decode(map['rootKey'] as String)),
      sendingChain: Uint8List.fromList(base64Decode(map['sendingChain'] as String)),
      receivingChain: Uint8List.fromList(base64Decode(map['receivingChain'] as String)),
      sendCounter: map['sendCounter'] as int,
      receiveCounter: map['receiveCounter'] as int,
    );
  }

  PqSession restore() => PqSession(sessionId: sessionId, rootKey: rootKey, sendingChain: sendingChain, receivingChain: receivingChain, sendCounter: sendCounter, receiveCounter: receiveCounter);
}
