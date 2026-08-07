import 'dart:typed_data';

import 'crypto_kdf.dart';

final class PqSession {
  final String sessionId;
  Uint8List _sendChain;
  Uint8List _receiveChain;
  int _sendCounter;
  int _receiveCounter;

  PqSession({
    required this.sessionId,
    required Uint8List rootKey,
    required Uint8List sendingChain,
    required Uint8List receivingChain,
    int sendCounter = 0,
    int receiveCounter = 0,
  })  : _sendChain = Uint8List.fromList(sendingChain),
        _receiveChain = Uint8List.fromList(receivingChain),
        _sendCounter = sendCounter,
        _receiveCounter = receiveCounter {
    if (rootKey.length != 32 || sendingChain.length != 32 || receivingChain.length != 32) {
      throw ArgumentError('Session keys must be 32 bytes');
    }
  }

  int get sendCounter => _sendCounter;
  int get receiveCounter => _receiveCounter;

  Future<Uint8List> nextSendKey() async {
    final key = await _derive(_sendChain, 'vibe/msg/send/$_sendCounter');
    _sendChain = await _derive(_sendChain, 'vibe/chain/send/$_sendCounter');
    _sendCounter++;
    return key;
  }

  Future<Uint8List> nextReceiveKey() async {
    final key = await _derive(_receiveChain, 'vibe/msg/recv/$_receiveCounter');
    _receiveChain = await _derive(_receiveChain, 'vibe/chain/recv/$_receiveCounter');
    _receiveCounter++;
    return key;
  }

  Future<Uint8List> _derive(Uint8List chain, String info) => CryptoKdf.derive(
        ikm: chain,
        salt: Uint8List(32),
        info: info,
      );
}
