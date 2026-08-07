import 'dart:convert';
import 'dart:typed_data';

import 'package:pqcrypto/pqcrypto.dart';

import '../../features/messages/domain/e2ee_session.dart';

final class PqPreKeyService {
  static final _kem = PqcKem.kyber768;
  static final _dsa = DilithiumParams.mlDsa65;
  static const _context = <int>[0x56, 0x49, 0x42, 0x45, 0x2D, 0x50, 0x52, 0x45, 0x4B, 0x45, 0x59, 0x2D, 0x31];

  Future<PqPreKeyMaterial> generate({required String userId, required String keyId}) async {
    final (kemPublicKey, kemSecretKey) = _kem.generateKeyPair();
    final (identityPublicKey, identitySecretKey) = MlDsa.generateKeyPair(_dsa);
    final transcript = _transcript(userId, keyId, kemPublicKey, identityPublicKey);
    final signature = MlDsa.sign(identitySecretKey, transcript, _dsa, ctx: Uint8List.fromList(_context));
    return PqPreKeyMaterial(
      bundle: E2eePreKeyBundle(
        userId: userId,
        keyId: keyId,
        kemPublicKey: Uint8List.fromList(kemPublicKey),
        identitySigningPublicKey: Uint8List.fromList(identityPublicKey),
        signature: Uint8List.fromList(signature),
      ),
      kemSecretKey: Uint8List.fromList(kemSecretKey),
      identitySecretKey: Uint8List.fromList(identitySecretKey),
    );
  }

  bool verify(E2eePreKeyBundle bundle) {
    final transcript = _transcript(bundle.userId, bundle.keyId, bundle.kemPublicKey, bundle.identitySigningPublicKey);
    return MlDsa.verify(bundle.identitySigningPublicKey, transcript, bundle.signature, _dsa, ctx: Uint8List.fromList(_context));
  }

  ({Uint8List ciphertext, Uint8List sharedSecret}) encapsulate(E2eePreKeyBundle bundle) {
    final result = _kem.encapsulate(bundle.kemPublicKey);
    return (ciphertext: Uint8List.fromList(result.$1), sharedSecret: Uint8List.fromList(result.$2));
  }

  Uint8List decapsulate(PqPreKeyMaterial material, Uint8List ciphertext) {
    return Uint8List.fromList(_kem.decapsulate(material.kemSecretKey, ciphertext));
  }

  Uint8List _transcript(String userId, String keyId, Uint8List kemPublicKey, Uint8List identityPublicKey) {
    final fields = [utf8.encode(userId), utf8.encode(keyId), kemPublicKey, identityPublicKey];
    final output = BytesBuilder();
    for (final field in fields) {
      final length = ByteData(4)..setUint32(0, field.length, Endian.big);
      output.add(length.buffer.asUint8List());
      output.add(field);
    }
    return output.toBytes();
  }
}

final class PqPreKeyMaterial {
  final E2eePreKeyBundle bundle;
  final Uint8List kemSecretKey;
  final Uint8List identitySecretKey;

  const PqPreKeyMaterial({required this.bundle, required this.kemSecretKey, required this.identitySecretKey});
}
