import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:vibe_messenger/core/security/atomic_message_transaction.dart';
import 'package:vibe_messenger/core/security/encrypted_message_service.dart';
import 'package:vibe_messenger/core/security/pq_session.dart';

final class _FakeStore implements MessageTransactionStore {
  bool active = false;
  bool committed = false;
  bool rolledBack = false;
  bool failMessage = false;
  bool failSession = false;
  bool failQueue = false;
  int messages = 0;
  int sessions = 0;
  int queued = 0;

  @override
  Future<void> begin() async {
    if (active) throw StateError('already active');
    active = true;
  }

  @override
  Future<void> saveEncryptedMessage(EncryptedMessage message) async {
    if (failMessage) throw StateError('message failure');
    messages++;
  }

  @override
  Future<void> saveSessionState(PqSession session) async {
    if (failSession) throw StateError('session failure');
    sessions++;
  }

  @override
  Future<void> enqueueSync(EncryptedMessage message) async {
    if (failQueue) throw StateError('queue failure');
    queued++;
  }

  @override
  Future<void> commit() async {
    committed = true;
    active = false;
  }

  @override
  Future<void> rollback() async {
    rolledBack = true;
    active = false;
    messages = 0;
    sessions = 0;
    queued = 0;
  }
}

PqSession _session() => PqSession(
      sessionId: 'test-session',
      rootKey: Uint8List(32),
      sendingChain: Uint8List.fromList(List<int>.filled(32, 2)),
      receivingChain: Uint8List.fromList(List<int>.filled(32, 3)),
    );

void main() {
  test('commits ciphertext, session state and sync queue together', () async {
    final store = _FakeStore();
    await AtomicMessageTransaction(store).send(
      session: _session(),
      plaintext: 'secret',
      crypto: const EncryptedMessageService(),
    );

    expect(store.committed, isTrue);
    expect(store.rolledBack, isFalse);
    expect(store.messages, 1);
    expect(store.sessions, 1);
    expect(store.queued, 1);
  });

  for (final field in ['message', 'session', 'queue']) {
    test('rolls back when $field persistence fails', () async {
      final store = _FakeStore();
      if (field == 'message') store.failMessage = true;
      if (field == 'session') store.failSession = true;
      if (field == 'queue') store.failQueue = true;

      await expectLater(
        AtomicMessageTransaction(store).send(
          session: _session(),
          plaintext: 'secret',
          crypto: const EncryptedMessageService(),
        ),
        throwsStateError,
      );

      expect(store.committed, isFalse);
      expect(store.rolledBack, isTrue);
      expect(store.messages, 0);
      expect(store.sessions, 0);
      expect(store.queued, 0);
    });
  }
}
