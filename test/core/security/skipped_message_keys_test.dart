import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_messenger/core/security/skipped_message_keys.dart';

void main() {
  test('bounds skipped keys and consumes once', () {
    final store = SkippedMessageKeyStore(maxEntries: 2);
    store.put(1, List<int>.filled(32, 1).toUint8List());
    store.put(2, List<int>.filled(32, 2).toUint8List());
    store.put(3, List<int>.filled(32, 3).toUint8List());
    expect(store.contains(1), isFalse);
    expect(store.take(2), isNotNull);
    expect(store.take(2), isNull);
    expect(store.length, 1);
  });
}

extension on List<int> {
  List<int> toUint8List() => this;
}
