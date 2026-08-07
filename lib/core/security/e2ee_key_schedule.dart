import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

final class E2eeKeySchedule {
  static final _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

  const E2eeKeySchedule();

  Future<Uint8List> deriveRoot(Uint8List sharedSecret, Uint8List transcript) async {
    final key = await _hkdf.deriveKey(secretKey: SecretKey(sharedSecret), nonce: transcript, info: const <int>[0x56, 0x49, 0x42, 0x45, 0x2D, 0x52, 0x4F, 0x4F, 0x54]);
    return Uint8List.fromList(await key.extractBytes());
  }

  Future<Uint8List> deriveMessageKey(Uint8List rootKey, int counter) async {
    final nonce = ByteData(8)..setUint64(0, counter, Endian.big);
    final key = await _hkdf.deriveKey(
      secretKey: SecretKey(rootKey),
      nonce: nonce.buffer.asUint8List(),
      info: const <int>[0x56, 0x49, 0x42, 0x45, 0x2D, 0x4D, 0x53, 0x47],
    );
    return Uint8List.fromList(await key.extractBytes());
  }

  Future<Uint8List> ratchet(Uint8List rootKey, Uint8List messageKey) async {
    final key = await _hkdf.deriveKey(secretKey: SecretKey(rootKey), nonce: messageKey, info: const <int>[0x56, 0x49, 0x42, 0x45, 0x2D, 0x52, 0x41, 0x54, 0x43, 0x48, 0x45, 0x54]);
    return Uint8List.fromList(await key.extractBytes());
  }
}
