import 'dart:typed_data';

enum E2eeRole { initiator, responder }

final class E2eePreKeyBundle {
  final String userId;
  final String keyId;
  final Uint8List kemPublicKey;
  final Uint8List identitySigningPublicKey;
  final Uint8List signature;
  const E2eePreKeyBundle({required this.userId, required this.keyId, required this.kemPublicKey, required this.identitySigningPublicKey, required this.signature});
}

final class E2eeHandshake {
  final String sessionId;
  final String keyId;
  final Uint8List kemCiphertext;
  final Uint8List initiatorIdentityKey;
  final Uint8List signature;
  const E2eeHandshake({required this.sessionId, required this.keyId, required this.kemCiphertext, required this.initiatorIdentityKey, required this.signature});
}

final class E2eeSessionState {
  final String sessionId;
  final String peerKeyId;
  final E2eeRole role;
  final Uint8List rootKey;
  final Uint8List sendChainKey;
  final Uint8List receiveChainKey;
  final int sendCounter;
  final int receiveCounter;
  const E2eeSessionState({required this.sessionId, required this.peerKeyId, required this.role, required this.rootKey, required this.sendChainKey, required this.receiveChainKey, this.sendCounter = 0, this.receiveCounter = 0});
  E2eeSessionState copyWith({Uint8List? rootKey, Uint8List? sendChainKey, Uint8List? receiveChainKey, int? sendCounter, int? receiveCounter}) => E2eeSessionState(
        sessionId: sessionId, peerKeyId: peerKeyId, role: role, rootKey: rootKey ?? this.rootKey,
        sendChainKey: sendChainKey ?? this.sendChainKey, receiveChainKey: receiveChainKey ?? this.receiveChainKey,
        sendCounter: sendCounter ?? this.sendCounter, receiveCounter: receiveCounter ?? this.receiveCounter,
      );
}

abstract interface class E2eeSessionEngine {
  Future<E2eePreKeyBundle> createPreKeyBundle({required String userId, required String keyId});
  Future<(E2eeSessionState, E2eeHandshake)> initiate(E2eePreKeyBundle peer);
  Future<E2eeSessionState> accept(E2eeHandshake handshake);
  Future<(E2eeSessionState, Uint8List)> encrypt(E2eeSessionState session, Uint8List plaintext, {required Uint8List aad});
  Future<(E2eeSessionState, Uint8List)> decrypt(E2eeSessionState session, Uint8List packet, {required Uint8List aad});
}
