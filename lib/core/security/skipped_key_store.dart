import 'dart:typed_data';

final class SkippedKeyStore {
  final int maxKeys;
  final Map<String, Uint8List> _keys = <String, Uint8List>{};

  SkippedKeyStore({this.maxKeys = 200});

  void put(String sessionId, int counter, Uint8List key) {
    if (_keys.length >= maxKeys) {
      _keys.remove(_keys.keys.first);
    }
    _keys['$sessionId:$counter'] = Uint8List.fromList(key);
  }

  Uint8List? take(String sessionId, int counter) {
    final value = _keys.remove('$sessionId:$counter');
    return value == null ? null : Uint8List.fromList(value);
  }

  void clearSession(String sessionId) {
    _keys.removeWhere((key, _) => key.startsWith('$sessionId:'));
  }
}
