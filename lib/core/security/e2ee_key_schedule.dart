import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

final class E2eeKeySchedule {
  static final _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
  const E2eeKeySchedule();

  Future<Uint8List> deriveRoot(Uint8List sharedSecret, Uint8List transcript) async => _derive(sharedSecret, transcript, const <int>[0x56, 0x49, 0x42, 0x45, 0x2D, 0x52, 0x4F, 0x4F, 0x54]);

  Future<Uint8List> deriveChainKey(Uint8List rootKey, {required bool initiator, required bool sending}) async {
    final direction = initiator == sending ? 0x49 : 0x52;
    return _derive(rootKey, Uint8List.fromList([direction]), const <int>[0x56, 0x49, 0x42, 0x45, 0x2D, 0x43, 0x48, 0x41, 0x49, 0x4E]);
  }

  Future<Uint8List> deriveMessageKey(Uint8List chainKey, int counter) async {
    final nonce = ByteData(8)..setUint64(0, counter, Endian.big);
    return _derive(chainKey, nonce.buffer.asUint8List(), const <int>[0x56, 0x49, 0x42, 0x45, 0x2D, 0x4D, 0x53, 0x47]);
  }

  Future<Uint8List> ratchet(Uint8List chainKey, Uint8List messageKey) async => _derive(chainKey, messageKey, const <int>[0x56, 0x49, 0x42, 0x45, 0x2D, 0x52, 0x41, 0x54, 0x43, 0x48, 0x45, 0x54]);

  Future<Uint8List> _derive(Uint8List secret, Uint8List nonce, List<int> info) async {
    final key = await _hkdf.deriveKey(secretKey: SecretKey(secret), nonce: nonce, info: info);
    return Uint8List.fromList(await key.extractBytes());
  }
}
