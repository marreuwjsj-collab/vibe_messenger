import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_messenger/core/security/pq_e2ee_session_engine.dart';

void main() {
  test('ML-KEM handshake establishes matching directional E2EE chains', () async {
    final alice = PqE2eeSessionEngine();
    final bob = PqE2eeSessionEngine();
    await alice.createPreKeyBundle(userId: 'alice', keyId: 'alice-1');
    final bobBundle = await bob.createPreKeyBundle(userId: 'bob', keyId: 'bob-1');
    final (aliceSession, handshake) = await alice.initiate(bobBundle);
    final bobSession = await bob.accept(handshake);
    final aad = Uint8List.fromList(utf8.encode('chat:secure-room'));

    final (aliceNext, packet) = await alice.encrypt(aliceSession, Uint8List.fromList(utf8.encode('hello from alice')), aad: aad);
    final (bobNext, plaintext) = await bob.decrypt(bobSession, packet, aad: aad);
    expect(utf8.decode(plaintext), 'hello from alice');
    expect(aliceNext.sendCounter, 1);
    expect(bobNext.receiveCounter, 1);

    final (bobSendNext, replyPacket) = await bob.encrypt(bobNext, Uint8List.fromList(utf8.encode('hello from bob')), aad: aad);
    final (_, reply) = await alice.decrypt(aliceNext, replyPacket, aad: aad);
    expect(utf8.decode(reply), 'hello from bob');
    expect(bobSendNext.sendCounter, 1);
  });

  test('tampered packet is rejected', () async {
    final alice = PqE2eeSessionEngine();
    final bob = PqE2eeSessionEngine();
    await alice.createPreKeyBundle(userId: 'alice', keyId: 'alice-1');
    final bobBundle = await bob.createPreKeyBundle(userId: 'bob', keyId: 'bob-1');
    final (aliceSession, handshake) = await alice.initiate(bobBundle);
    final bobSession = await bob.accept(handshake);
    final aad = Uint8List.fromList(utf8.encode('chat:secure-room'));
    final (_, packet) = await alice.encrypt(aliceSession, Uint8List.fromList(utf8.encode('secret')), aad: aad);
    final tampered = Uint8List.fromList(packet)..[packet.length - 2] ^= 1;
    expect(() => bob.decrypt(bobSession, tampered, aad: aad), throwsA(anything));
  });
}
