import 'dart:convert';
import 'dart:typed_data';

import 'package:pqcrypto/pqcrypto.dart';
import 'package:uuid/uuid.dart';

import '../../features/messages/domain/e2ee_session.dart';
import 'aead_cipher.dart';
import 'e2ee_key_schedule.dart';
import 'pq_prekey_service.dart';

final class PqE2eeSessionEngine implements E2eeSessionEngine {
  static const int _maxSkipped = 256;
  static const int _maxFutureGap = 4096;
  final PqPreKeyService _preKeys;
  final AeadCipher _aead;
  final E2eeKeySchedule _schedule;
  PqPreKeyMaterial? _local;

  PqE2eeSessionEngine({PqPreKeyService? preKeys, AeadCipher? aead, E2eeKeySchedule? schedule}) : _preKeys = preKeys ?? PqPreKeyService(), _aead = aead ?? AeadCipher(), _schedule = schedule ?? const E2eeKeySchedule();

  @override
  Future<E2eePreKeyBundle> createPreKeyBundle({required String userId, required String keyId}) async {
    _local = await _preKeys.generate(userId: userId, keyId: keyId);
    return _local!.bundle;
  }

  @override
  Future<(E2eeSessionState, E2eeHandshake)> initiate(E2eePreKeyBundle peer) async {
    if (!_preKeys.verify(peer)) throw StateError('Peer pre-key signature verification failed');
    final local = _local;
    if (local == null) throw StateError('Local pre-key bundle is not initialized');
    final encapsulated = _preKeys.encapsulate(peer);
    final sessionId = const Uuid().v4();
    final transcript = _handshakeBytes(sessionId, peer.keyId, encapsulated.ciphertext, local.bundle.identitySigningPublicKey);
    final signature = MlDsa.sign(local.identitySecretKey, transcript, DilithiumParams.mlDsa65, ctx: _context);
    final root = await _schedule.deriveRoot(encapsulated.sharedSecret, transcript);
    final send = await _schedule.deriveChainKey(root, initiator: true, sending: true);
    final receive = await _schedule.deriveChainKey(root, initiator: true, sending: false);
    return (E2eeSessionState(sessionId: sessionId, peerKeyId: peer.keyId, role: E2eeRole.initiator, rootKey: root, sendChainKey: send, receiveChainKey: receive), E2eeHandshake(sessionId: sessionId, keyId: peer.keyId, kemCiphertext: encapsulated.ciphertext, initiatorIdentityKey: local.bundle.identitySigningPublicKey, signature: Uint8List.fromList(signature)));
  }

  @override
  Future<E2eeSessionState> accept(E2eeHandshake handshake) async {
    final local = _local;
    if (local == null) throw StateError('Local pre-key bundle is not initialized');
    if (handshake.keyId != local.bundle.keyId) throw StateError('Handshake targets a different pre-key epoch');
    final transcript = _handshakeBytes(handshake.sessionId, handshake.keyId, handshake.kemCiphertext, handshake.initiatorIdentityKey);
    if (!MlDsa.verify(handshake.initiatorIdentityKey, transcript, handshake.signature, DilithiumParams.mlDsa65, ctx: _context)) throw StateError('Handshake signature verification failed');
    final shared = _preKeys.decapsulate(local, handshake.kemCiphertext);
    final root = await _schedule.deriveRoot(shared, transcript);
    final send = await _schedule.deriveChainKey(root, initiator: false, sending: true);
    final receive = await _schedule.deriveChainKey(root, initiator: false, sending: false);
    return E2eeSessionState(sessionId: handshake.sessionId, peerKeyId: handshake.keyId, role: E2eeRole.responder, rootKey: root, sendChainKey: send, receiveChainKey: receive);
  }

  @override
  Future<(E2eeSessionState, Uint8List)> encrypt(E2eeSessionState session, Uint8List plaintext, {required Uint8List aad}) async {
    final messageKey = await _schedule.deriveMessageKey(session.sendChainKey, session.sendCounter);
    final encrypted = await _aead.encrypt(plaintext: plaintext, key: messageKey, aad: _aad(session.sessionId, session.sendCounter, aad));
    final packet = _encodePacket(session.sessionId, session.sendCounter, encrypted);
    final nextChain = await _schedule.ratchet(session.sendChainKey, messageKey);
    return (session.copyWith(sendChainKey: nextChain, sendCounter: session.sendCounter + 1), packet);
  }

  @override
  Future<(E2eeSessionState, Uint8List)> decrypt(E2eeSessionState session, Uint8List packet, {required Uint8List aad}) async {
    final parsed = _decodePacket(packet);
    if (parsed.sessionId != session.sessionId) throw StateError('E2EE session mismatch');
    if (parsed.counter < 0) throw StateError('Invalid E2EE message counter');

    final skipped = Map<int, Uint8List>.from(session.skippedMessageKeys);
    if (parsed.counter < session.receiveCounter) {
      final key = skipped.remove(parsed.counter);
      if (key == null) throw StateError('Expired or replayed E2EE message');
      final plaintext = await _aead.decrypt(payload: parsed.payload, key: key, aad: _aad(session.sessionId, parsed.counter, aad));
      return (session.copyWith(skippedMessageKeys: skipped), plaintext);
    }

    final gap = parsed.counter - session.receiveCounter;
    if (gap > _maxFutureGap) throw StateError('E2EE message counter gap is too large');

    var chain = session.receiveChainKey;
    var counter = session.receiveCounter;
    while (counter < parsed.counter) {
      final key = await _schedule.deriveMessageKey(chain, counter);
      if (skipped.length >= _maxSkipped) {
        final oldest = skipped.keys.reduce((a, b) => a < b ? a : b);
        skipped.remove(oldest);
      }
      skipped[counter] = Uint8List.fromList(key);
      chain = await _schedule.ratchet(chain, key);
      counter++;
    }

    final messageKey = await _schedule.deriveMessageKey(chain, parsed.counter);
    final plaintext = await _aead.decrypt(payload: parsed.payload, key: messageKey, aad: _aad(session.sessionId, parsed.counter, aad));
    final nextChain = await _schedule.ratchet(chain, messageKey);
    return (session.copyWith(receiveChainKey: nextChain, receiveCounter: parsed.counter + 1, skippedMessageKeys: skipped), plaintext);
  }

  static final Uint8List _context = Uint8List.fromList([0x56, 0x49, 0x42, 0x45, 0x2D, 0x45, 0x32, 0x45, 0x45, 0x2D, 0x31]);

  Uint8List _handshakeBytes(String sessionId, String keyId, Uint8List ciphertext, Uint8List identityKey) {
    final builder = BytesBuilder();
    for (final field in [utf8.encode('VIBE-E2EE-HANDSHAKE-V1'), utf8.encode(sessionId), utf8.encode(keyId), ciphertext, identityKey]) {
      final length = ByteData(4)..setUint32(0, field.length, Endian.big);
      builder.add(length.buffer.asUint8List());
      builder.add(field);
    }
    return builder.toBytes();
  }

  Uint8List _aad(String sessionId, int counter, Uint8List aad) {
    final builder = BytesBuilder()..add(utf8.encode(sessionId));
    final number = ByteData(8)..setUint64(0, counter, Endian.big);
    builder.add(number.buffer.asUint8List());
    builder.add(aad);
    return builder.toBytes();
  }

  Uint8List _encodePacket(String sessionId, int counter, EncryptedPayload payload) => Uint8List.fromList(utf8.encode(jsonEncode({'v': 1, 'sid': sessionId, 'n': counter, 'p': payload.toJson()})));

  ({String sessionId, int counter, EncryptedPayload payload}) _decodePacket(Uint8List packet) {
    final decoded = jsonDecode(utf8.decode(packet));
    if (decoded is! Map<String, dynamic> || decoded['v'] != 1 || decoded['sid'] is! String || decoded['n'] is! int || decoded['p'] is! Map) throw StateError('Malformed E2EE packet');
    final counter = decoded['n'] as int;
    if (counter < 0) throw StateError('Invalid E2EE message counter');
    return (sessionId: decoded['sid'] as String, counter: counter, payload: EncryptedPayload.fromJson(Map<String, dynamic>.from(decoded['p'] as Map)));
  }
}
