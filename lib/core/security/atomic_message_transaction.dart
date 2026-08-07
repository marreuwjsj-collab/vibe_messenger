import 'encrypted_message_service.dart';
import 'pq_session.dart';

abstract interface class MessageTransactionStore {
  Future<void> begin();
  Future<void> saveEncryptedMessage(EncryptedMessage message);
  Future<void> saveSessionState(PqSession session);
  Future<void> enqueueSync(EncryptedMessage message);
  Future<void> commit();
  Future<void> rollback();
}

final class AtomicMessageTransaction {
  final MessageTransactionStore store;
  const AtomicMessageTransaction(this.store);

  Future<EncryptedMessage> send({required PqSession session, required String plaintext, required EncryptedMessageService crypto}) async {
    await store.begin();
    try {
      final encrypted = await crypto.encrypt(session, plaintext);
      await store.saveEncryptedMessage(encrypted);
      await store.saveSessionState(session);
      await store.enqueueSync(encrypted);
      await store.commit();
      return encrypted;
    } catch (_) {
      await store.rollback();
      rethrow;
    }
  }
}
