import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class SessionKeyStore {
  final FlutterSecureStorage storage;
  const SessionKeyStore({this.storage = const FlutterSecureStorage()});

  Future<void> write(String sessionId, Uint8List key) => storage.write(
        key: 'vibe.session.key.$sessionId',
        value: _hex(key),
      );

  Future<Uint8List?> read(String sessionId) async {
    final value = await storage.read(key: 'vibe.session.key.$sessionId');
    return value == null ? null : _fromHex(value);
  }

  Future<void> delete(String sessionId) => storage.delete(key: 'vibe.session.key.$sessionId');

  String _hex(Uint8List bytes) => bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  Uint8List _fromHex(String value) {
    if (value.length.isOdd) throw const FormatException('Invalid key encoding');
    return Uint8List.fromList(List<int>.generate(value.length ~/ 2, (i) => int.parse(value.substring(i * 2, i * 2 + 2), radix: 16)));
  }
}
