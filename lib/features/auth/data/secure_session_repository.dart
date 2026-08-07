import '../../../core/storage/secure_store.dart';
import '../domain/session.dart';

final class SecureSessionRepository implements SessionRepository {
  static const _userId = 'session.user_id';
  static const _token = 'session.access_token';
  static const _expiresAt = 'session.expires_at';

  final SecureStore _store;
  const SecureSessionRepository(this._store);

  @override
  Future<Session?> restore() async {
    final userId = await _store.read(_userId);
    final token = await _store.read(_token);
    final expiresRaw = await _store.read(_expiresAt);
    if (userId == null || token == null || expiresRaw == null) return null;
    final expiresAt = DateTime.tryParse(expiresRaw);
    if (expiresAt == null || DateTime.now().isAfter(expiresAt)) {
      await clear();
      return null;
    }
    return Session(userId: userId, accessToken: token, expiresAt: expiresAt);
  }

  @override
  Future<void> save(Session session) async {
    await _store.write(_userId, session.userId);
    await _store.write(_token, session.accessToken);
    await _store.write(_expiresAt, session.expiresAt.toIso8601String());
  }

  @override
  Future<void> clear() async {
    await _store.delete(_userId);
    await _store.delete(_token);
    await _store.delete(_expiresAt);
  }
}
