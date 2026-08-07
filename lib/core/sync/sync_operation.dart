enum SyncOperationType { sendMessage, editMessage, deleteMessage, markRead }

enum SyncOperationState { pending, processing, completed, failed }

class SyncOperation {
  final String id;
  final SyncOperationType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attempts;
  final SyncOperationState state;

  const SyncOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
    this.state = SyncOperationState.pending,
  });

  SyncOperation copyWith({int? attempts, SyncOperationState? state}) => SyncOperation(
        id: id,
        type: type,
        payload: payload,
        createdAt: createdAt,
        attempts: attempts ?? this.attempts,
        state: state ?? this.state,
      );
}
