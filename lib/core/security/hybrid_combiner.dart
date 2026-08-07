import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'post_quantum.dart';

/// HKDF-SHA-256 combiner for hybrid key material.
/// The classical and PQ secrets are independently bound to a protocol context
/// before deriving the message/session key.
final class HkdfHybridCombiner implements HybridKeyCombiner {
  final Hkdf _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

  @override
  Future<Uint8List> combine(HybridKeyMaterial material, {required Uint8List context}) async {
    final ikm = <int>[...material.classicalSecret, ...material.postQuantumSecret];
    final derived = await _hkdf.deriveKey(
      secretKey: SecretKey(ikm),
      nonce: context,
    );
    return Uint8List.fromList(await derived.extractBytes());
  }
}
