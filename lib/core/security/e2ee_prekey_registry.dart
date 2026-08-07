import 'dart:typed_data';

abstract interface class E2eePreKeyRegistry {
  Future<bool> tryConsume(String keyId);
}

final class MemoryE2eePreKeyRegistry implements E2eePreKeyRegistry {
  final Set<String> _consumed=<String>{};
  @override Future<bool> tryConsume(String keyId) async => _consumed.add(keyId);
}

final class E2eePreKeyConsumption {
  final E2eePreKeyRegistry registry;
  const E2eePreKeyConsumption(this.registry);
  Future<T> once<T>(String keyId, Future<T> Function() action) async {
    if(!await registry.tryConsume(keyId))throw StateError('One-time PQ pre-key has already been consumed');
    return action();
  }
}
