import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'pq_session.dart';
import 'pq_session_snapshot.dart';
import 'session_key_store.dart';
import 'session_protector.dart';

final class ProtectedSessionStore {
  final SessionKeyStore keyStore;
  final SessionProtector protector;
  final Future<void> Function(String sessionId, String envelope) persist;
  final Future<String?> Function(String sessionId) load;

  const ProtectedSessionStore({
    required this.keyStore,
    required this.protector,
    required this.persist,
    required this.load,
  });

  Future<void> save(PqSessionSnapshot snapshot) async {
    final keyBytes = await keyStore.read(snapshot.sessionId) ?? _randomKey();
    if (keyBytes.length != 32) throw StateError('Invalid session protection key length');
    await keyStore.write(snapshot.sessionId, keyBytes);

    final aad = Uint8List.fromList(utf8.encode('vibe/session/${snapshot.sessionId}/v1'));
    final encrypted = await protector.protect(
      plaintext: Uint8List.fromList(utf8.encode(snapshot.encode())),
      key: SecretKey(keyBytes),
      aad: aad,
    );
    await persist(snapshot.sessionId, encrypted.encode());
  }

  Future<PqSession?> restore(String sessionId) async {
    final encoded = await load(sessionId);
    if (encoded == null) return null;
    final keyBytes = await keyStore.read(sessionId);
    if (keyBytes == null || keyBytes.length != 32) return null;

    final aad = Uint8List.fromList(utf8.encode('vibe/session/$sessionId/v1'));
    final plaintext = await protector.unprotect(
      protected: ProtectedSession.decode(encoded),
      key: SecretKey(keyBytes),
      aad: aad,
    );
    return PqSessionSnapshot.decode(utf8.decode(plaintext)).restore();
  }

  Future<void> delete(String sessionId) async {
    await persist(sessionId, '');
    await keyStore.delete(sessionId);
  }

  Uint8List _randomKey() {
    final random = Random.secure();
    return Uint8List.fromList(List<int>.generate(32, (_) => random.nextInt(256)));
  }
}
