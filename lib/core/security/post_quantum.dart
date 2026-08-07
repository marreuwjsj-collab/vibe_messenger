import 'dart:typed_data';

/// Contract for the post-quantum E2EE layer.
///
/// Production implementations MUST use audited implementations of the
/// standardized PQC primitives rather than implementing the algorithms here.
/// NIST standardized ML-KEM (FIPS 203) for key encapsulation and ML-DSA
/// (FIPS 204) for signatures. This interface deliberately keeps the algorithm
/// implementation behind a narrow boundary so the protocol remains crypto-agile.
abstract interface class PostQuantumKem {
  String get algorithm;
  Future<PqKeyPair> generateKeyPair();
  Future<PqEncapsulation> encapsulate(Uint8List recipientPublicKey);
  Future<Uint8List> decapsulate(Uint8List ciphertext, Uint8List privateKey);
}

abstract interface class PostQuantumSigner {
  String get algorithm;
  Future<PqSigningKeyPair> generateKeyPair();
  Future<Uint8List> sign(Uint8List message, Uint8List privateKey);
  Future<bool> verify(Uint8List message, Uint8List signature, Uint8List publicKey);
}

final class PqKeyPair {
  final Uint8List publicKey;
  final Uint8List privateKey;
  const PqKeyPair({required this.publicKey, required this.privateKey});
}

final class PqSigningKeyPair {
  final Uint8List publicKey;
  final Uint8List privateKey;
  const PqSigningKeyPair({required this.publicKey, required this.privateKey});
}

final class PqEncapsulation {
  final Uint8List ciphertext;
  final Uint8List sharedSecret;
  const PqEncapsulation({required this.ciphertext, required this.sharedSecret});
}

final class HybridKeyMaterial {
  final Uint8List classicalSecret;
  final Uint8List postQuantumSecret;
  const HybridKeyMaterial({required this.classicalSecret, required this.postQuantumSecret});
}

/// Combines independent classical and PQ secrets before symmetric encryption.
/// A real implementation should use a standards-compliant KDF/key combiner,
/// not concatenate secrets directly.
abstract interface class HybridKeyCombiner {
  Future<Uint8List> combine(HybridKeyMaterial material, {required Uint8List context});
}
