import 'dart:typed_data';

import 'package:pqcrypto/pqcrypto.dart';

import 'post_quantum.dart';

final class MlDsa65 implements PostQuantumSigner {
  const MlDsa65();

  @override
  String get algorithm => 'ML-DSA-65';

  @override
  Future<PqSigningKeyPair> generateKeyPair() async {
    final (publicKey, privateKey) = MlDsa.generateKeyPair(DilithiumParams.mlDsa65);
    return PqSigningKeyPair(
      publicKey: Uint8List.fromList(publicKey),
      privateKey: Uint8List.fromList(privateKey),
    );
  }

  @override
  Future<Uint8List> sign(Uint8List message, Uint8List privateKey) async {
    final signature = MlDsa.sign(
      privateKey,
      message,
      DilithiumParams.mlDsa65,
      ctx: Uint8List.fromList('vibe/message/v1'.codeUnits),
    );
    return Uint8List.fromList(signature);
  }

  @override
  Future<bool> verify(Uint8List message, Uint8List signature, Uint8List publicKey) async {
    return MlDsa.verify(
      publicKey,
      message,
      signature,
      DilithiumParams.mlDsa65,
      ctx: Uint8List.fromList('vibe/message/v1'.codeUnits),
    );
  }
}
