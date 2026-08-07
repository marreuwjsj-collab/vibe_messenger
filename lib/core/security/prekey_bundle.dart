import 'dart:typed_data';

final class OneTimePreKey {
  final int id;
  final Uint8List publicKey;
  final Uint8List signature;
  const OneTimePreKey({required this.id, required this.publicKey, required this.signature});
}

final class PreKeyBundle {
  final int version;
  final Uint8List identityKey;
  final Uint8List signedPreKey;
  final Uint8List signedPreKeySignature;
  final List<OneTimePreKey> oneTimePreKeys;
  const PreKeyBundle({required this.version, required this.identityKey, required this.signedPreKey, required this.signedPreKeySignature, required this.oneTimePreKeys});
  bool get hasOneTimePreKeys => oneTimePreKeys.isNotEmpty;
}
