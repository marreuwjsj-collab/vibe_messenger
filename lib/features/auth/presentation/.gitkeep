import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_store.dart';
import '../data/secure_session_repository.dart';
import '../domain/session.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) => SecureSessionRepository(const FlutterSecureStore()));

final sessionProvider = AsyncNotifierProvider<SessionController, Session?>(SessionController.new);

final class SessionController extends AsyncNotifier<Session?> {
  @override Future<Session?> build() => ref.read(sessionRepositoryProvider).restore();
  Future<void> signIn(Session session) async { await ref.read(sessionRepositoryProvider).save(session); state = AsyncData(session); }
  Future<void> signOut() async { await ref.read(sessionRepositoryProvider).clear(); state = const AsyncData(null); }
}
