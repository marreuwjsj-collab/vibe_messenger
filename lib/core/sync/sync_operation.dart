enum SyncOperationType { createMessage, updateMessage, deleteMessage }

enum SyncOperationStatus { pending, processing, failed, completed }

final class SyncOperation {
  final String id;
  final SyncOperationType type;
  final String entityId;
  final String payload;
  final DateTime createdAt;
  final int attempts;
  final SyncOperationStatus status;
  final String? lastError;

  const SyncOperation({
    required this.id,
    required this.type,
    required this.entityId,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
    this.status = SyncOperationStatus.pending,
    this.lastError,
  });

  SyncOperation copyWith({int? attempts, SyncOperationStatus? status, String? lastError}) => SyncOperation(
    id: id,
    type: type,
    entityId: entityId,
    payload: payload,
    createdAt: createdAt,
    attempts: attempts ?? this.attempts,
    status: status ?? this.status,
    lastError: lastError ?? this.lastError,
  );
}
