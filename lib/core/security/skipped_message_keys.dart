import 'dart:typed_data';

final class SkippedMessageKeyStore {
  final int maxEntries;
  final Map<int, Uint8List> _keys = <int, Uint8List>{};

  SkippedMessageKeyStore({this.maxEntries = 256}) {
    if (maxEntries <= 0) throw ArgumentError.value(maxEntries, 'maxEntries');
  }

  bool get isEmpty => _keys.isEmpty;
  int get length => _keys.length;

  void put(int counter, Uint8List key) {
    if (counter < 0) throw ArgumentError.value(counter, 'counter');
    if (key.length != 32) throw ArgumentError('Message key must be 32 bytes');
    _keys[counter] = Uint8List.fromList(key);
    while (_keys.length > maxEntries) {
      final oldest = _keys.keys.reduce((a, b) => a < b ? a : b);
      _keys.remove(oldest);
    }
  }

  Uint8List? take(int counter) {
    final key = _keys.remove(counter);
    return key == null ? null : Uint8List.fromList(key);
  }

  bool contains(int counter) => _keys.containsKey(counter);

  Map<int, Uint8List> snapshot() => {
        for (final entry in _keys.entries) entry.key: Uint8List.fromList(entry.value),
      };
}
