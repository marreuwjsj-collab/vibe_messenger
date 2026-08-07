import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

final class RealtimeClient {
  final Uri endpoint;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  final _events = StreamController<Map<String, dynamic>>.broadcast();

  RealtimeClient(this.endpoint);

  Stream<Map<String, dynamic>> get events => _events.stream;

  Future<void> connect() async {
    await disconnect();
    _channel = WebSocketChannel.connect(endpoint);
    await _channel!.ready;
    _subscription = _channel!.stream.listen(
      (event) {
        if (event is String) {
          final decoded = jsonDecode(event);
          if (decoded is Map<String, dynamic>) _events.add(decoded);
        }
      },
      onError: _events.addError,
    );
  }

  void send(Map<String, dynamic> event) {
    final channel = _channel;
    if (channel == null) throw StateError('Realtime client is not connected');
    channel.sink.add(jsonEncode(event));
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _events.close();
  }
}
