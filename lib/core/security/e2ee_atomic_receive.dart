import 'dart:typed_data';
import '../../features/messages/domain/e2ee_session.dart';

abstract interface class E2eeAtomicStore {
  Future<void> transaction(Future<void> Function() action);
  Future<void> saveState(E2eeSessionState state);
  Future<void> saveCiphertext({required String sessionId, required int counter, required Uint8List packet});
}

final class E2eeAtomicReceive {
  final E2eeAtomicStore store;
  const E2eeAtomicReceive(this.store);

  Future<void> commit({required E2eeSessionState nextState, required Uint8List packet}) async {
    await store.transaction(() async {
      await store.saveCiphertext(sessionId: nextState.sessionId, counter: nextState.receiveCounter, packet: packet);
      await store.saveState(nextState);
    });
  }
}
