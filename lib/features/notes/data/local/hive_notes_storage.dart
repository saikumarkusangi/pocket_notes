import 'package:hive_flutter/hive_flutter.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/features/notes/data/local/local_note_record.dart';
import 'package:pocket_notes/features/notes/data/local/sync_queue_item.dart';
import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/data/models/sync_operation_type.dart';

class HiveNotesStorage {
  HiveNotesStorage(this._notesBox, this._queueBox);

  final Box<dynamic> _notesBox;
  final Box<dynamic> _queueBox;

  static Future<HiveNotesStorage> open() async {
    final notesBox = await Hive.openBox(AppConstants.notes);
    final queueBox = await Hive.openBox(AppConstants.offlineSyncQueue);
    return HiveNotesStorage(notesBox, queueBox);
  }

  List<LocalNoteRecord> getNotesForUser(String userId) {
    return _notesBox.values
        .whereType<Map>()
        .map((map) => LocalNoteRecord.fromMap(Map<dynamic, dynamic>.from(map)))
        .where(
          (note) =>
              !note.isDeleted &&
              (note.userId == userId ||
                  (userId.isNotEmpty && note.userId.isEmpty)),
        )
        .toList();
  }

  List<LocalNoteRecord> getOrphanedNotes() {
    return _notesBox.values
        .whereType<Map>()
        .map((map) => LocalNoteRecord.fromMap(Map<dynamic, dynamic>.from(map)))
        .where((note) => !note.isDeleted && note.userId.isEmpty)
        .toList();
  }

  List<LocalNoteRecord> getNotesForUserAndCategory({
    required String userId,
    required NoteCategory category,
  }) {
    return getNotesForUser(userId)
        .where((note) => note.category == category)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  LocalNoteRecord? getNoteByLocalId(String localId) {
    final raw = _notesBox.get(localId);
    if (raw is! Map) return null;
    return LocalNoteRecord.fromMap(Map<dynamic, dynamic>.from(raw));
  }

  LocalNoteRecord? getNoteByRemoteId(String remoteId) {
    for (final value in _notesBox.values) {
      if (value is! Map) continue;
      final note = LocalNoteRecord.fromMap(Map<dynamic, dynamic>.from(value));
      if (note.remoteId == remoteId) return note;
    }
    return null;
  }

  Future<void> saveNote(LocalNoteRecord note) async {
    await _notesBox.put(note.localId, note.toMap());
  }

  Future<void> deleteNotePermanently(String localId) async {
    await _notesBox.delete(localId);
  }

  Future<void> reassignOrphanedNotesToUser(String userId) async {
    if (userId.isEmpty) return;

    for (final key in _notesBox.keys) {
      final raw = _notesBox.get(key);
      if (raw is! Map) continue;

      final note = LocalNoteRecord.fromMap(Map<dynamic, dynamic>.from(raw));
      if (note.userId.isEmpty) {
        await saveNote(note.copyWith(userId: userId));
      }
    }

    for (final key in _queueBox.keys) {
      final raw = _queueBox.get(key);
      if (raw is! Map) continue;

      final map = Map<dynamic, dynamic>.from(raw);
      if ((map['userId'] as String?)?.isEmpty ?? true) {
        map['userId'] = userId;
        await _queueBox.put(key, map);
      }
    }
  }

  List<SyncQueueItem> getQueueForUser(String userId) {
    return _queueBox.values
        .whereType<Map>()
        .map((map) => SyncQueueItem.fromMap(Map<dynamic, dynamic>.from(map)))
        .where((item) => item.userId == userId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> enqueue(SyncQueueItem item) async {
    await _queueBox.put(item.id, item.toMap());
  }

  Future<void> removeQueueItem(String queueItemId) async {
    await _queueBox.delete(queueItemId);
  }

  Future<void> removeQueueItemsForNote(String localNoteId) async {
    final keysToDelete = <dynamic>[];
    for (final entry in _queueBox.toMap().entries) {
      final value = entry.value;
      if (value is Map && value['localNoteId'] == localNoteId) {
        keysToDelete.add(entry.key);
      }
    }
    await _queueBox.deleteAll(keysToDelete);
  }

  Future<void> upsertQueueOperation({
    required String localNoteId,
    required String userId,
    required SyncOperationType operation,
    required String queueItemId,
  }) async {
    final existing = getQueueForUser(userId)
        .where((item) => item.localNoteId == localNoteId)
        .toList();

    if (operation == SyncOperationType.create) {
      final hasCreate = existing.any(
        (item) => item.operation == SyncOperationType.create,
      );
      if (!hasCreate) {
        await enqueue(
          SyncQueueItem(
            id: queueItemId,
            localNoteId: localNoteId,
            userId: userId,
            operation: operation,
            createdAt: DateTime.now(),
          ),
        );
      }
      return;
    }

    if (operation == SyncOperationType.delete) {
      for (final item in existing) {
        await removeQueueItem(item.id);
      }
      await enqueue(
        SyncQueueItem(
          id: queueItemId,
          localNoteId: localNoteId,
          userId: userId,
          operation: SyncOperationType.delete,
          createdAt: DateTime.now(),
        ),
      );
      return;
    }

    final hasCreate = existing.any(
      (item) => item.operation == SyncOperationType.create,
    );
    if (hasCreate) return;

    final updateItems = existing
        .where((item) => item.operation == SyncOperationType.update)
        .toList();
    if (updateItems.isEmpty) {
      await enqueue(
        SyncQueueItem(
          id: queueItemId,
          localNoteId: localNoteId,
          userId: userId,
          operation: SyncOperationType.update,
          createdAt: DateTime.now(),
        ),
      );
    }
  }
}
