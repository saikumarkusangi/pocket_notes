import 'package:pocket_notes/core/utils/note_text_formatter.dart';
import 'package:pocket_notes/features/notes/data/local/local_note_record.dart';
import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/data/models/note_sync_status.dart';

class NoteModel {
  const NoteModel({
    required this.localId,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.syncStatus,
    this.remoteId,
    this.remoteUpdatedAt,
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? remoteUpdatedAt;
  final NoteCategory category;
  final NoteSyncStatus syncStatus;
  final String? conflictRemoteTitle;
  final String? conflictRemoteBody;
  final DateTime? conflictRemoteUpdatedAt;
  final bool isIdea;

  String get id => localId;

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return NoteModel(
      localId: json['localId']?.toString() ?? json['id']?.toString() ?? '',
      remoteId: json['id']?.toString(),
      userId: json['userId']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: _parseTimestamp(json['createdAt']) ?? now,
      updatedAt: _parseTimestamp(json['updatedAt']) ?? now,
      remoteUpdatedAt: _parseTimestamp(json['updatedAt']),
      category: NoteCategory.fromType(json['type'] as String?),
      syncStatus: NoteSyncStatus.synced,
    );
  }

  factory NoteModel.fromLocalRecord(LocalNoteRecord record) {
    return NoteModel(
      localId: record.localId,
      remoteId: record.remoteId,
      userId: record.userId,
      title: record.title,
      body: record.body,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      remoteUpdatedAt: record.remoteUpdatedAt,
      category: record.category,
      syncStatus: record.syncStatus,
      conflictRemoteTitle: record.conflictRemoteTitle,
      conflictRemoteBody: record.conflictRemoteBody,
      conflictRemoteUpdatedAt: record.conflictRemoteUpdatedAt,
      isIdea: record.isIdea,
    );
  }

  Map<String, dynamic> toRemoteJson() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': category.apiType,
      'createdAt': createdAt.millisecondsSinceEpoch ~/ 1000,
      'updatedAt': now,
      if (remoteId != null) 'id': remoteId,
    };
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return DateTime.fromMillisecondsSinceEpoch(parsed * 1000);
      }
      return DateTime.tryParse(value);
    }
    return null;
  }


  String get preview {
    final trimmed = NoteFormattedText.stripMarkers(body.trim());
    if (trimmed.isEmpty) return 'No content yet';
    return trimmed.length > 120 ? '${trimmed.substring(0, 120)}...' : trimmed;
  }

  List<String> get lineItems {
    return body
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map(_stripCheckPrefix)
        .toList();
  }

  int get itemCount => lineItems.length;

  int get completedItemCount {
    return body
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .where(_isCompletedLine)
        .length;
  }

  int get remainingItemCount => itemCount - completedItemCount;

  bool get hasConflict => syncStatus == NoteSyncStatus.conflict;

  static String _stripCheckPrefix(String line) {
    if (line.startsWith('[x] ') || line.startsWith('[X] ')) {
      return line.substring(4);
    }
    if (line.startsWith('[ ] ')) return line.substring(4);
    return line;
  }

  static bool _isCompletedLine(String line) {
    return line.startsWith('[x] ') || line.startsWith('[X] ');
  }

  NoteModel copyWith({
    String? localId,
    String? remoteId,
    String? userId,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? remoteUpdatedAt,
    NoteCategory? category,
    NoteSyncStatus? syncStatus,
    String? conflictRemoteTitle,
    String? conflictRemoteBody,
    DateTime? conflictRemoteUpdatedAt,
    bool? isIdea,
  }) {
    return NoteModel(
      localId: localId ?? this.localId,
      remoteId: remoteId ?? this.remoteId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      category: category ?? this.category,
      syncStatus: syncStatus ?? this.syncStatus,
      conflictRemoteTitle: conflictRemoteTitle ?? this.conflictRemoteTitle,
      conflictRemoteBody: conflictRemoteBody ?? this.conflictRemoteBody,
      conflictRemoteUpdatedAt:
          conflictRemoteUpdatedAt ?? this.conflictRemoteUpdatedAt,
      isIdea: isIdea ?? this.isIdea,
    );
  }
}
