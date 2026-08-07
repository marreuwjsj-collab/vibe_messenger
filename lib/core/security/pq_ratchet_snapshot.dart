import 'dart:convert';
import 'dart:typed_data';
import 'pq_ratchet.dart';

final class PqRatchetSnapshot {
  final String sessionId;
  final int epoch;
  final Uint8List rootKey;
  final Uint8List sendChain;
  final Uint8List receiveChain;

  const PqRatchetSnapshot({required this.sessionId, required this.epoch, required this.rootKey, required this.sendChain, required this.receiveChain});

  String encode() => jsonEncode({'v': 1, 'sessionId': sessionId, 'epoch': epoch, 'rootKey': base64Encode(rootKey), 'sendChain': base64Encode(sendChain), 'receiveChain': base64Encode(receiveChain)});

  static PqRatchetSnapshot decode(String value) {
    final map = jsonDecode(value);
    if (map is! Map<String, dynamic> || map['v'] != 1) throw const FormatException('Unsupported ratchet snapshot');
    return PqRatchetSnapshot(
      sessionId: map['sessionId'] as String,
      epoch: map['epoch'] as int,
      rootKey: Uint8List.fromList(base64Decode(map['rootKey'] as String)),
      sendChain: Uint8List.fromList(base64Decode(map['sendChain'] as String)),
      receiveChain: Uint8List.fromList(base64Decode(map['receiveChain'] as String)),
    );
  }

  PqRatchet restore() => PqRatchet(rootKey: rootKey, sendChain: sendChain, receiveChain: receiveChain, epoch: epoch);
}
