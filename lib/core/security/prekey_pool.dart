import 'dart:typed_data';

import 'prekey_bundle.dart';

final class PreKeyPool {
  final int refillThreshold;
  final int targetSize;
  final List<OneTimePreKey> _keys = <OneTimePreKey>[];

  PreKeyPool({this.refillThreshold = 20, this.targetSize = 100});

  int get available => _keys.length;
  bool get needsRefill => available < refillThreshold;

  void add(OneTimePreKey key) => _keys.add(key);

  void addAll(Iterable<OneTimePreKey> keys) => _keys.addAll(keys);

  OneTimePreKey? consume() => _keys.isEmpty ? null : _keys.removeAt(0);

  List<OneTimePreKey> takeForRefill() {
    if (!needsRefill) return const [];
    return List<OneTimePreKey>.generate(targetSize - available, (index) {
      final id = DateTime.now().microsecondsSinceEpoch + index;
      return OneTimePreKey(id: id, publicKey: Uint8List(0), signature: Uint8List(0));
    });
  }
}
