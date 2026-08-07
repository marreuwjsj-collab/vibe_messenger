import 'dart:async';
import 'dart:convert';

final class SyncQueueItem {
  final String id;
  final String operation;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  int attempts;
  SyncQueueItem({required this.id, required this.operation, required this.payload, required this.createdAt, this.attempts = 0});
  String encode() => jsonEncode({'id': id, 'operation': operation, 'payload': payload, 'createdAt': createdAt.toIso8601String(), 'attempts': attempts});
}

final class SyncEngine {
  final List<SyncQueueItem> _queue = [];
  bool _running = false;
  bool get isRunning => _running;
  int get pendingCount => _queue.length;
  void enqueue(SyncQueueItem item) => _queue.add(item);
  Future<void> drain(Future<void> Function(SyncQueueItem item) handler) async {
    if (_running) return;
    _running = true;
    try {
      while (_queue.isNotEmpty) {
        final item = _queue.first;
        try { await handler(item); _queue.removeAt(0); }
        catch (_) { item.attempts++; break; }
      }
    } finally { _running = false; }
  }
}
