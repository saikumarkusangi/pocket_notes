import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/data/models/note_model.dart';
import 'package:pocket_notes/features/notes/data/models/note_sync_status.dart';

class LocalNoteRecord {
  const LocalNoteRecord({
    required this.localId,
    required this.userId,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.localUpdatedAt,
    required this.syncStatus,
    this.remoteId,
    this.remoteUpdatedAt,
    this.isDeleted = false,
    this.conflictRemoteTitle,
    this.conflictRemoteBody,
    this.conflictRemoteUpdatedAt,
    this.isIdea = false,
  });

  final String localId;
  final String? remoteId;
  final String userId;
  final String title;
  final String body;
  final NoteCategory category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime localUpdatedAt;
  final DateTime? remoteUpdatedAt;
  final NoteSyncStatus syncStatus;
  final bool isDeleted;
  final String? conflictRemoteTitle;
  final String? conflictRemoteBody;
  final DateTime? conflictRemoteUpdatedAt;
  final bool isIdea;

  factory LocalNoteRecord.fromMap(Map<dynamic, dynamic> map) {
    return LocalNoteRecord(
      localId: map['localId'] as String,
      remoteId: map['remoteId'] as String?,
      userId: map['userId'] as String,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      category: NoteCategory.fromType(map['category'] as String?),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      localUpdatedAt: DateTime.parse(map['localUpdatedAt'] as String),
      remoteUpdatedAt: map['remoteUpdatedAt'] == null
          ? null
          : DateTime.parse(map['remoteUpdatedAt'] as String),
      syncStatus: NoteSyncStatus.fromValue(map['syncStatus'] as String?),
      isDeleted: map['isDeleted'] as bool? ?? false,
      conflictRemoteTitle: map['conflictRemoteTitle'] as String?,
      conflictRemoteBody: map['conflictRemoteBody'] as String?,
      conflictRemoteUpdatedAt: map['conflictRemoteUpdatedAt'] == null
          ? null
          : DateTime.parse(map['conflictRemoteUpdatedAt'] as String),
      isIdea: map['isIdea'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'localId': localId,
      'remoteId': remoteId,
      'userId': userId,
      'title': title,
      'body': body,
      'category': category.apiType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'localUpdatedAt': localUpdatedAt.toIso8601String(),
      'remoteUpdatedAt': remoteUpdatedAt?.toIso8601String(),
      'syncStatus': syncStatus.name,
      'isDeleted': isDeleted,
      'conflictRemoteTitle': conflictRemoteTitle,
      'conflictRemoteBody': conflictRemoteBody,
      'conflictRemoteUpdatedAt': conflictRemoteUpdatedAt?.toIso8601String(),
      'isIdea': isIdea,
    };
  }

  NoteModel toNoteModel() => NoteModel.fromLocalRecord(this);

  LocalNoteRecord copyWith({
    String? localId,
    String? remoteId,
    String? userId,
    String? title,
    String? body,
    NoteCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? localUpdatedAt,
    DateTime? remoteUpdatedAt,
    NoteSyncStatus? syncStatus,
    bool? isDeleted,
    String? conflictRemoteTitle,
    String? conflictRemoteBody,
    DateTime? conflictRemoteUpdatedAt,
    bool? isIdea,
    bool clearConflict = false,
    bool clearRemoteId = false,
  }) {
    return LocalNoteRecord(
      localId: localId ?? this.localId,
      remoteId: clearRemoteId ? null : remoteId ?? this.remoteId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      conflictRemoteTitle: clearConflict
          ? null
          : conflictRemoteTitle ?? this.conflictRemoteTitle,
      conflictRemoteBody: clearConflict
          ? null
          : conflictRemoteBody ?? this.conflictRemoteBody,
      conflictRemoteUpdatedAt: clearConflict
          ? null
          : conflictRemoteUpdatedAt ?? this.conflictRemoteUpdatedAt,
      isIdea: isIdea ?? this.isIdea,
    );
  }
}
