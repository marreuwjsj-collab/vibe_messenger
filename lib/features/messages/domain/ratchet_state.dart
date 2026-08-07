import 'dart:typed_data';

final class RatchetState {
  final Uint8List rootKey;
  final Uint8List sendingChainKey;
  final Uint8List receivingChainKey;
  final int sendCounter;
  final int receiveCounter;

  const RatchetState({
    required this.rootKey,
    required this.sendingChainKey,
    required this.receivingChainKey,
    this.sendCounter = 0,
    this.receiveCounter = 0,
  });

  RatchetState copyWith({Uint8List? rootKey, Uint8List? sendingChainKey, Uint8List? receivingChainKey, int? sendCounter, int? receiveCounter}) => RatchetState(
    rootKey: rootKey ?? this.rootKey,
    sendingChainKey: sendingChainKey ?? this.sendingChainKey,
    receivingChainKey: receivingChainKey ?? this.receivingChainKey,
    sendCounter: sendCounter ?? this.sendCounter,
    receiveCounter: receiveCounter ?? this.receiveCounter,
  );
}
