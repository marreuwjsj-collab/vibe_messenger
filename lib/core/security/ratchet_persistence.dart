import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'pq_ratchet_snapshot.dart';
import 'session_key_store.dart';
import 'session_protector.dart';

abstract interface class RatchetEnvelopeStore {
  Future<void> write(String sessionId, String envelope);
  Future<String?> read(String sessionId);
  Future<void> delete(String sessionId);
}

final class RatchetPersistence {
  final RatchetEnvelopeStore store;
  final SessionKeyStore keyStore;
  final SessionProtector protector;
  const RatchetPersistence({required this.store, required this.keyStore, required this.protector});

  Future<void> save(PqRatchetSnapshot snapshot) async {
    final keyBytes = await keyStore.read(snapshot.sessionId);
    if (keyBytes == null || keyBytes.length != 32) throw StateError('Missing session protection key');
    final aad = Uint8List.fromList(utf8.encode('vibe/ratchet/${snapshot.sessionId}/v1'));
    final envelope = await protector.protect(plaintext: Uint8List.fromList(utf8.encode(snapshot.encode())), key: SecretKey(keyBytes), aad: aad);
    await store.write(snapshot.sessionId, envelope.encode());
  }

  Future<PqRatchetSnapshot?> load(String sessionId) async {
    final encoded = await store.read(sessionId);
    if (encoded == null) return null;
    final keyBytes = await keyStore.read(sessionId);
    if (keyBytes == null || keyBytes.length != 32) return null;
    final aad = Uint8List.fromList(utf8.encode('vibe/ratchet/$sessionId/v1'));
    final plaintext = await protector.unprotect(protected: ProtectedSession.decode(encoded), key: SecretKey(keyBytes), aad: aad);
    return PqRatchetSnapshot.decode(utf8.decode(plaintext));
  }

  Future<void> delete(String sessionId) async {
    await store.delete(sessionId);
    await keyStore.delete(sessionId);
  }
}
