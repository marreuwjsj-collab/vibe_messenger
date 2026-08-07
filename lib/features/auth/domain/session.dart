class Session {
  final String userId;
  final String accessToken;
  final DateTime expiresAt;

  const Session({required this.userId, required this.accessToken, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

abstract interface class SessionRepository {
  Future<Session?> restore();
  Future<void> save(Session session);
  Future<void> clear();
}
