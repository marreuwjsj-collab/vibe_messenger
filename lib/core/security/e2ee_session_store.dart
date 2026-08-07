import '../../features/messages/domain/e2ee_session.dart';

abstract interface class E2eeSessionStore {
  Future<void> put(E2eeSessionState state);
  Future<E2eeSessionState?> get(String sessionId);
  Future<void> delete(String sessionId);
}

abstract interface class E2eeSessionTransaction {
  Future<void> begin();
  Future<void> save(E2eeSessionState state);
  Future<void> commit();
  Future<void> rollback();
}
