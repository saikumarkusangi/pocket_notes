import 'package:pocket_notes/features/notes/data/local/hive_notes_storage.dart';
import 'package:pocket_notes/features/notes/data/local/local_note_record.dart';
import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/data/models/note_model.dart';
import 'package:pocket_notes/features/notes/data/models/note_sync_status.dart';
import 'package:pocket_notes/features/notes/data/models/sync_operation_type.dart';
import 'package:uuid/uuid.dart';

class NotesOfflineRepository {
  NotesOfflineRepository(this._storage);

  final HiveNotesStorage _storage;
  final _uuid = const Uuid();

  List<NoteModel> getNotesByUserAndCategory({
    required String userId,
    required NoteCategory category,
  }) {
    return _storage
        .getNotesForUserAndCategory(userId: userId, category: category)
        .map((record) => record.toNoteModel())
        .toList();
  }

  List<NoteModel> getOrphanedNotesByCategory(NoteCategory category) {
    return _storage
        .getOrphanedNotes()
        .where((note) => note.category == category)
        .map((record) => record.toNoteModel())
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  NoteModel? getNoteByLocalId(String localId) {
    return _storage.getNoteByLocalId(localId)?.toNoteModel();
  }

  bool hasNotesForUser(String userId) {
    return _storage.getNotesForUser(userId).isNotEmpty;
  }

  bool hasOrphanedNotes() {
    return _storage.getOrphanedNotes().isNotEmpty;
  }

  Future<NoteModel> createNote({
    required String userId,
    required String title,
    required String body,
    required NoteCategory category,
  }) async {
    if (userId.isEmpty) {
      throw StateError('Cannot create a note without a valid user id.');
    }

    final now = DateTime.now();
    final record = LocalNoteRecord(
      localId: _uuid.v4(),
      userId: userId,
      title: title,
      body: body,
      category: category,
      createdAt: now,
      updatedAt: now,
      localUpdatedAt: now,
      syncStatus: NoteSyncStatus.pendingSync,
    );

    await _storage.saveNote(record);
    await _storage.upsertQueueOperation(
      localNoteId: record.localId,
      userId: userId,
      operation: SyncOperationType.create,
      queueItemId: _uuid.v4(),
    );

    return record.toNoteModel();
  }

  Future<NoteModel?> updateNote({
    required String localId,
    required String title,
    required String body,
  }) async {
    final existing = _storage.getNoteByLocalId(localId);
    if (existing == null || existing.isDeleted) return null;

    final now = DateTime.now();
    final updated = existing.copyWith(
      title: title,
      body: body,
      updatedAt: now,
      localUpdatedAt: now,
      syncStatus: existing.syncStatus == NoteSyncStatus.conflict
          ? NoteSyncStatus.conflict
          : NoteSyncStatus.pendingSync,
    );

    await _storage.saveNote(updated);
    await _storage.upsertQueueOperation(
      localNoteId: localId,
      userId: existing.userId,
      operation: existing.remoteId == null
          ? SyncOperationType.create
          : SyncOperationType.update,
      queueItemId: _uuid.v4(),
    );

    return updated.toNoteModel();
  }

  Future<void> deleteNote(String localId) async {
    final existing = _storage.getNoteByLocalId(localId);
    if (existing == null) return;

    final deleted = existing.copyWith(
      isDeleted: true,
      updatedAt: DateTime.now(),
      localUpdatedAt: DateTime.now(),
      syncStatus: NoteSyncStatus.pendingSync,
    );
    await _storage.saveNote(deleted);
    await _storage.upsertQueueOperation(
      localNoteId: localId,
      userId: existing.userId,
      operation: SyncOperationType.delete,
      queueItemId: _uuid.v4(),
    );
  }

  Future<NoteModel?> resolveConflictKeepLocal(String localId) async {
    final existing = _storage.getNoteByLocalId(localId);
    if (existing == null) return null;

    final resolved = existing.copyWith(
      syncStatus: NoteSyncStatus.pendingSync,
      clearConflict: true,
      localUpdatedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _storage.saveNote(resolved);
    await _storage.upsertQueueOperation(
      localNoteId: localId,
      userId: existing.userId,
      operation: SyncOperationType.update,
      queueItemId: _uuid.v4(),
    );
    return resolved.toNoteModel();
  }

  Future<NoteModel?> resolveConflictKeepRemote(String localId) async {
    final existing = _storage.getNoteByLocalId(localId);
    if (existing == null) return null;

    final resolved = existing.copyWith(
      title: existing.conflictRemoteTitle ?? existing.title,
      body: existing.conflictRemoteBody ?? existing.body,
      updatedAt: existing.conflictRemoteUpdatedAt ?? existing.updatedAt,
      remoteUpdatedAt:
          existing.conflictRemoteUpdatedAt ?? existing.remoteUpdatedAt,
      syncStatus: NoteSyncStatus.synced,
      clearConflict: true,
      localUpdatedAt: DateTime.now(),
    );
    await _storage.saveNote(resolved);
    await _storage.removeQueueItemsForNote(localId);
    return resolved.toNoteModel();
  }

  HiveNotesStorage get storage => _storage;

  Future<void> repairOrphanedNotes(String userId) async {
    await _storage.reassignOrphanedNotesToUser(userId);
  }
}
