import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

final class AppDatabase {
  Database? _db;

  Future<Database> get database async {
    final current = _db;
    if (current != null) return current;
    final path = p.join(await getDatabasesPath(), 'vibe.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, _) async {
      await db.execute('CREATE TABLE chats (id TEXT PRIMARY KEY, title TEXT NOT NULL, preview TEXT NOT NULL, updated_at INTEGER NOT NULL, unread_count INTEGER NOT NULL DEFAULT 0)');
      await db.execute('CREATE TABLE messages (id TEXT PRIMARY KEY, chat_id TEXT NOT NULL, sender_id TEXT NOT NULL, text TEXT NOT NULL, created_at INTEGER NOT NULL, status INTEGER NOT NULL)');
      await db.execute('CREATE INDEX idx_messages_chat_time ON messages(chat_id, created_at DESC)');
      await db.execute('CREATE TABLE sync_queue (id TEXT PRIMARY KEY, operation TEXT NOT NULL, payload TEXT NOT NULL, created_at INTEGER NOT NULL, attempts INTEGER NOT NULL DEFAULT 0)');
    });
    return _db!;
  }

  Future<void> close() async { await _db?.close(); _db = null; }
}
