import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'atomic_message_transaction.dart';
import 'encrypted_message_service.dart';
import 'pq_session.dart';

final class SqfliteMessageTransactionStore implements MessageTransactionStore {
  final Database db;
  bool _active = false;
  SqfliteMessageTransactionStore(this.db);

  @override
  Future<void> begin() async {
    if (_active) throw StateError('Transaction already active');
    await db.execute('BEGIN IMMEDIATE');
    _active = true;
  }

  @override
  Future<void> saveEncryptedMessage(EncryptedMessage message) async {
    _requireActive();
    await db.insert('vibe_messages', {
      'session_id': message.sessionId,
      'counter': message.counter,
      'version': message.version,
      'nonce': base64Encode(message.nonce),
      'ciphertext': base64Encode(message.ciphertext),
      'mac': base64Encode(message.mac),
    });
  }

  @override
  Future<void> saveSessionState(PqSession session) async {
    _requireActive();
    await db.insert('vibe_sessions', {
      'session_id': session.sessionId,
      'send_counter': session.sendCounter,
      'receive_counter': session.receiveCounter,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> enqueueSync(EncryptedMessage message) async {
    _requireActive();
    await db.insert('vibe_sync_queue', {
      'session_id': message.sessionId,
      'counter': message.counter,
      'payload': message.encode(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> commit() async {
    _requireActive();
    try {
      await db.execute('COMMIT');
    } finally {
      _active = false;
    }
  }

  @override
  Future<void> rollback() async {
    if (!_active) return;
    try {
      await db.execute('ROLLBACK');
    } finally {
      _active = false;
    }
  }

  void _requireActive() {
    if (!_active) throw StateError('No active transaction');
  }
}

abstract final class VibeSecuritySchema {
  static const statements = <String>[
    '''CREATE TABLE IF NOT EXISTS vibe_messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      session_id TEXT NOT NULL,
      counter INTEGER NOT NULL,
      version INTEGER NOT NULL,
      nonce TEXT NOT NULL,
      ciphertext TEXT NOT NULL,
      mac TEXT NOT NULL,
      UNIQUE(session_id, counter)
    )''',
    '''CREATE TABLE IF NOT EXISTS vibe_sessions (
      session_id TEXT PRIMARY KEY,
      send_counter INTEGER NOT NULL,
      receive_counter INTEGER NOT NULL
    )''',
    '''CREATE TABLE IF NOT EXISTS vibe_sync_queue (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      session_id TEXT NOT NULL,
      counter INTEGER NOT NULL,
      payload TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      UNIQUE(session_id, counter)
    )''',
  ];
}
