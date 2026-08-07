import 'dart:typed_data';

import 'package:pqcrypto/pqcrypto.dart';

final class PqIdentityMaterial {
  final MlDsaKeyPair identity;
  final MlKemKeyPair signedPreKey;

  const PqIdentityMaterial({required this.identity, required this.signedPreKey});
}

final class PqOneTimePreKey {
  final int id;
  final MlKemKeyPair keyPair;

  const PqOneTimePreKey({required this.id, required this.keyPair});

  Uint8List get publicKey => keyPair.publicKey;
}

abstract final class PqKeyMaterialFactory {
  static PqIdentityMaterial generateIdentity() => PqIdentityMaterial(
        identity: MlDsaKeyPair.generate(MlDsaParameterSet.mlDsa65),
        signedPreKey: MlKemKeyPair.generate(MlKemParameterSet.mlKem768),
      );

  static PqOneTimePreKey generateOneTimePreKey(int id) => PqOneTimePreKey(
        id: id,
        keyPair: MlKemKeyPair.generate(MlKemParameterSet.mlKem768),
      );
}
