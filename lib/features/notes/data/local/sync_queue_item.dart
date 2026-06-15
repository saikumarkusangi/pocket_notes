import 'package:pocket_notes/features/notes/data/models/sync_operation_type.dart';

class SyncQueueItem {
  const SyncQueueItem({
    required this.id,
    required this.localNoteId,
    required this.userId,
    required this.operation,
    required this.createdAt,
  });

  final String id;
  final String localNoteId;
  final String userId;
  final SyncOperationType operation;
  final DateTime createdAt;

  factory SyncQueueItem.fromMap(Map<dynamic, dynamic> map) {
    return SyncQueueItem(
      id: map['id'] as String,
      localNoteId: map['localNoteId'] as String,
      userId: map['userId'] as String,
      operation: SyncOperationType.fromValue(map['operation'] as String?),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'localNoteId': localNoteId,
      'userId': userId,
      'operation': operation.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
