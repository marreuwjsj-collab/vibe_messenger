import '../../features/messages/domain/e2ee_session.dart';
import 'e2ee_state_store.dart';

final class InMemoryE2eeStateStore implements E2eeStateStore {
  final Map<String, String> _states = <String, String>{};
  @override
  Future<void> put(E2eeSessionState state) async => _states[state.sessionId] = E2eeSessionCodec.encode(state);
  @override
  Future<E2eeSessionState?> get(String sessionId) async {
    final value = _states[sessionId];
    return value == null ? null : E2eeSessionCodec.decode(value);
  }
  @override
  Future<void> delete(String sessionId) async => _states.remove(sessionId);
}
