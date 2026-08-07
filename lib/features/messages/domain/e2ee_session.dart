import 'dart:typed_data';

final class E2eePreKeyBundle {
  final String userId;
  final String keyId;
  final Uint8List kemPublicKey;
  final Uint8List identitySigningPublicKey;
  final Uint8List signature;

  const E2eePreKeyBundle({required this.userId, required this.keyId, required this.kemPublicKey, required this.identitySigningPublicKey, required this.signature});
}

final class E2eeSessionState {
  final String sessionId;
  final String peerKeyId;
  final Uint8List rootKey;
  final int sendCounter;
  final int receiveCounter;

  const E2eeSessionState({required this.sessionId, required this.peerKeyId, required this.rootKey, this.sendCounter = 0, this.receiveCounter = 0});

  E2eeSessionState copyWith({Uint8List? rootKey, int? sendCounter, int? receiveCounter}) => E2eeSessionState(
        sessionId: sessionId,
        peerKeyId: peerKeyId,
        rootKey: rootKey ?? this.rootKey,
        sendCounter: sendCounter ?? this.sendCounter,
        receiveCounter: receiveCounter ?? this.receiveCounter,
      );
}

abstract interface class E2eeSessionEngine {
  Future<E2eePreKeyBundle> createPreKeyBundle({required String userId, required String keyId});
  Future<E2eeSessionState> initiate(E2eePreKeyBundle peer);
  Future<Uint8List> encrypt(E2eeSessionState session, Uint8List plaintext, {required Uint8List aad});
  Future<(E2eeSessionState, Uint8List)> decrypt(E2eeSessionState session, Uint8List packet, {required Uint8List aad});
}
