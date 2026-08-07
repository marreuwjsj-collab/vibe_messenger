import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

abstract final class CryptoKdf {
  static Future<Uint8List> derive({
    required Uint8List ikm,
    required Uint8List salt,
    required String info,
    int length = 32,
  }) async {
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: length);
    final secretKey = await hkdf.deriveKey(
      secretKey: SecretKey(ikm),
      nonce: salt,
      info: Uint8List.fromList(info.codeUnits),
    );
    return Uint8List.fromList(await secretKey.extractBytes());
  }

  static Future<Uint8List> combine({
    required Iterable<Uint8List> secrets,
    required Uint8List transcriptHash,
    String info = 'vibe/pq-session/v1',
  }) async {
    final material = BytesBuilder();
    for (final secret in secrets) {
      if (secret.isEmpty) throw ArgumentError('Secret material must not be empty');
      material.add(secret);
    }
    return derive(
      ikm: material.toBytes(),
      salt: transcriptHash,
      info: info,
    );
  }
}
