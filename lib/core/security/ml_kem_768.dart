import 'dart:typed_data';

import 'package:pqcrypto/pqcrypto.dart';

import 'post_quantum.dart';

final class MlKem768 implements PostQuantumKem {
  const MlKem768();

  @override
  String get algorithm => 'ML-KEM-768';

  @override
  Future<PqKeyPair> generateKeyPair() async {
    final (publicKey, privateKey) = PqcKem.kyber768.generateKeyPair();
    return PqKeyPair(
      publicKey: Uint8List.fromList(publicKey),
      privateKey: Uint8List.fromList(privateKey),
    );
  }

  @override
  Future<PqEncapsulation> encapsulate(Uint8List recipientPublicKey) async {
    final (ciphertext, sharedSecret) = PqcKem.kyber768.encapsulate(recipientPublicKey);
    return PqEncapsulation(
      ciphertext: Uint8List.fromList(ciphertext),
      sharedSecret: Uint8List.fromList(sharedSecret),
    );
  }

  @override
  Future<Uint8List> decapsulate(Uint8List ciphertext, Uint8List privateKey) async {
    return Uint8List.fromList(PqcKem.kyber768.decapsulate(privateKey, ciphertext));
  }
}
