import 'package:pocket_notes/features/notes/data/local/local_note_record.dart';
import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/data/models/note_model.dart';
import 'package:pocket_notes/features/notes/data/models/note_sync_status.dart';

class NotesTestFixtures {
  NotesTestFixtures._();

  static const userId = 'user-test-1';
  static const localId = 'local-note-1';
  static const remoteId = 'remote-note-1';

  static final lastSyncedAt = DateTime(2025, 6, 10, 10);
  static final localEditedAt = DateTime(2025, 6, 15, 14);
  static final remoteEditedAt = DateTime(2025, 6, 14, 9);

  static LocalNoteRecord syncedLocalNote({
    String title = 'Meeting notes',
    String body = 'Discuss roadmap',
    NoteSyncStatus syncStatus = NoteSyncStatus.synced,
    DateTime? localUpdatedAt,
    DateTime? remoteUpdatedAt,
  }) {
    return LocalNoteRecord(
      localId: localId,
      remoteId: remoteId,
      userId: userId,
      title: title,
      body: body,
      category: NoteCategory.journal,
      createdAt: lastSyncedAt,
      updatedAt: localUpdatedAt ?? lastSyncedAt,
      localUpdatedAt: localUpdatedAt ?? lastSyncedAt,
      remoteUpdatedAt: remoteUpdatedAt ?? lastSyncedAt,
      syncStatus: syncStatus,
    );
  }

  static LocalNoteRecord conflictedLocalNote() {
    return syncedLocalNote(
      title: 'My edited title',
      body: 'My edited body',
      syncStatus: NoteSyncStatus.conflict,
      localUpdatedAt: localEditedAt,
      remoteUpdatedAt: lastSyncedAt,
    ).copyWith(
      conflictRemoteTitle: 'Server title',
      conflictRemoteBody: 'Server body',
      conflictRemoteUpdatedAt: remoteEditedAt,
    );
  }

  static NoteModel remoteNote({
    String title = 'Server title',
    String body = 'Server body',
    DateTime? updatedAt,
  }) {
    return NoteModel(
      localId: remoteId,
      remoteId: remoteId,
      userId: userId,
      title: title,
      body: body,
      createdAt: lastSyncedAt,
      updatedAt: updatedAt ?? remoteEditedAt,
      remoteUpdatedAt: updatedAt ?? remoteEditedAt,
      category: NoteCategory.journal,
      syncStatus: NoteSyncStatus.synced,
    );
  }
}
