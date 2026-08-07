import 'dart:typed_data';
import 'crypto_kdf.dart';

/// Root/chain ratchet boundary. This is not claimed to be Signal Double Ratchet.
final class PqRatchet {
  Uint8List _rootKey;
  Uint8List _sendChain;
  Uint8List _receiveChain;
  int _epoch;

  PqRatchet({required Uint8List rootKey, required Uint8List sendChain, required Uint8List receiveChain, int epoch = 0})
      : _rootKey = Uint8List.fromList(rootKey), _sendChain = Uint8List.fromList(sendChain), _receiveChain = Uint8List.fromList(receiveChain), _epoch = epoch {
    if (rootKey.length != 32 || sendChain.length != 32 || receiveChain.length != 32) throw ArgumentError('Ratchet material must be 32 bytes');
  }

  int get epoch => _epoch;
  Uint8List get rootKey => Uint8List.fromList(_rootKey);

  Future<void> advance(Uint8List newSecret, {required String direction}) async {
    if (newSecret.isEmpty) throw ArgumentError('Ratchet secret must not be empty');
    final nextRoot = await CryptoKdf.combine(secrets: <Uint8List>[_rootKey, newSecret], transcriptHash: _rootKey, info: 'vibe/pq-ratchet/root/v1/$_epoch');
    _sendChain = await CryptoKdf.derive(ikm: nextRoot, salt: _rootKey, info: 'vibe/pq-ratchet/$direction/send/$_epoch');
    _receiveChain = await CryptoKdf.derive(ikm: nextRoot, salt: _rootKey, info: 'vibe/pq-ratchet/$direction/receive/$_epoch');
    _rootKey = nextRoot;
    _epoch++;
  }

  Uint8List get sendChain => Uint8List.fromList(_sendChain);
  Uint8List get receiveChain => Uint8List.fromList(_receiveChain);
}
