import 'package:sqflite/sqflite.dart';
import '../../features/messages/domain/e2ee_session.dart';
import 'e2ee_state_store.dart';

final class SqfliteE2eeStateStore implements E2eeStateStore {
  final Database db;
  const SqfliteE2eeStateStore(this.db);

  static Future<void> createSchema(DatabaseExecutor db) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS e2ee_sessions (
      session_id TEXT PRIMARY KEY,
      state TEXT NOT NULL,
      updated_at INTEGER NOT NULL
    )''');
  }

  @override
  Future<void> put(E2eeSessionState state) async {
    await db.insert('e2ee_sessions', {'session_id': state.sessionId, 'state': E2eeSessionCodec.encode(state), 'updated_at': DateTime.now().millisecondsSinceEpoch}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<E2eeSessionState?> get(String sessionId) async {
    final rows = await db.query('e2ee_sessions', where: 'session_id = ?', whereArgs: [sessionId], limit: 1);
    if (rows.isEmpty) return null;
    return E2eeSessionCodec.decode(rows.first['state'] as String);
  }

  @override
  Future<void> delete(String sessionId) async => db.delete('e2ee_sessions', where: 'session_id = ?', whereArgs: [sessionId]);

  Future<T> transaction<T>(Future<T> Function(Transaction tx) action) => db.transaction(action);
}
