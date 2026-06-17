import 'package:pocket_notes/core/network/connectivity_service.dart';

import 'package:pocket_notes/core/services/notes_sync_result.dart';

import 'package:pocket_notes/features/notes/data/local/hive_notes_storage.dart';

import 'package:pocket_notes/features/notes/data/local/local_note_record.dart';

import 'package:pocket_notes/features/notes/data/models/note_model.dart';

import 'package:pocket_notes/features/notes/data/models/note_sync_status.dart';

import 'package:pocket_notes/features/notes/data/models/sync_operation_type.dart';

import 'package:pocket_notes/features/notes/data/repositories/remote_notes_repository.dart';

import 'package:uuid/uuid.dart';

class NotesSyncService {
  NotesSyncService({
    required HiveNotesStorage storage,

    required RemoteNotesRepository remoteRepository,

    required ConnectivityService connectivityService,
  }) : _storage = storage,

       _remoteRepository = remoteRepository,

       _connectivityService = connectivityService;

  final HiveNotesStorage _storage;

  final RemoteNotesRepository _remoteRepository;

  final ConnectivityService _connectivityService;

  final _uuid = const Uuid();

  bool _isSyncing = false;
  bool _pullRemoteBeforePush = true;

  Future<void> syncIfOnline(
    String userId, {

    SyncProgressCallback? onProgress,
  }) async {
    if (userId.isEmpty) return;

    if (await _connectivityService.isConnected) {
      await sync(userId, onProgress: onProgress);
    }
  }

  Future<NotesSyncResult> sync(
    String userId, {

    SyncProgressCallback? onProgress,
  }) async {
    if (userId.isEmpty) {
      return const NotesSyncResult(
        pushedCount: 0,

        pulledCount: 0,

        pendingCount: 0,

        success: false,
      );
    }

    if (_isSyncing) {
      return NotesSyncResult(
        pushedCount: 0,

        pulledCount: 0,

        pendingCount: _storage.getQueueForUser(userId).length,

        success: false,
      );
    }

    if (await _connectivityService.isDisconnected) {
      return NotesSyncResult(
        pushedCount: 0,

        pulledCount: 0,

        pendingCount: _storage.getQueueForUser(userId).length,

        success: false,
      );
    }

    _isSyncing = true;

    var pushedCount = 0;

    var pulledCount = 0;

    try {
      onProgress?.call(8, 'Preparing your notes…');

      final pullFirst = _pullRemoteBeforePush;
      if (pullFirst) {
        _pullRemoteBeforePush = false;
        pulledCount = await _pullRemoteChanges(userId, onProgress);
        onProgress?.call(45, 'Uploading your changes…');
        pushedCount = await _pushPendingChanges(userId, onProgress);
      } else {
        pushedCount = await _pushPendingChanges(userId, onProgress);
        onProgress?.call(52, 'Checking the cloud for updates…');
        pulledCount = await _pullRemoteChanges(userId, onProgress);
      }

      onProgress?.call(100, 'Finishing up…');

      return NotesSyncResult(
        pushedCount: pushedCount,

        pulledCount: pulledCount,

        pendingCount: _storage.getQueueForUser(userId).length,

        success: true,
      );
    } catch (_) {
      return NotesSyncResult(
        pushedCount: pushedCount,

        pulledCount: pulledCount,

        pendingCount: _storage.getQueueForUser(userId).length,

        success: false,
      );
    } finally {
      _isSyncing = false;
    }
  }

  Future<int> _pushPendingChanges(
    String userId,

    SyncProgressCallback? onProgress,
  ) async {
    final queue = _storage.getQueueForUser(userId);

    if (queue.isEmpty) {
      onProgress?.call(45, 'Nothing new to upload');

      return 0;
    }

    var pushedCount = 0;

    for (var i = 0; i < queue.length; i++) {
      final item = queue[i];

      final note = _storage.getNoteByLocalId(item.localNoteId);

      if (note == null) {
        await _storage.removeQueueItem(item.id);

        continue;
      }

      final progress = 10 + ((i + 1) / queue.length * 35).round();

      onProgress?.call(progress, 'Uploading your changes…');

      switch (item.operation) {
        case SyncOperationType.create:
          final pushed = await _pushCreate(note, item.id);

          if (pushed) pushedCount++;

        case SyncOperationType.update:
          final pushed = await _pushUpdate(note, item.id);

          if (pushed) pushedCount++;

        case SyncOperationType.delete:
          final pushed = await _pushDelete(note, item.id);

          if (pushed) pushedCount++;
      }
    }

    return pushedCount;
  }

  Future<bool> _pushCreate(LocalNoteRecord note, String queueItemId) async {
    if (note.userId.isEmpty) return false;

    if (note.isDeleted) {
      await _storage.removeQueueItem(queueItemId);

      await _storage.deleteNotePermanently(note.localId);

      return true;
    }

    final remote = await _remoteRepository.createNote(
      userId: note.userId,

      title: note.title,

      body: note.body,

      category: note.category,
    );

    final synced = note.copyWith(
      remoteId: remote.remoteId,

      remoteUpdatedAt: remote.updatedAt,

      syncStatus: NoteSyncStatus.synced,

      clearConflict: true,
    );

    await _storage.saveNote(synced);

    await _storage.removeQueueItem(queueItemId);

    return true;
  }

  Future<bool> _pushUpdate(LocalNoteRecord note, String queueItemId) async {
    if (note.isDeleted) {
      return _pushDelete(note, queueItemId);
    }

    final remoteId = note.remoteId;

    if (remoteId == null) {
      return _pushCreate(note, queueItemId);
    }

    final remoteNote = await _remoteRepository.getNoteById(remoteId);

    if (remoteNote != null &&
        note.remoteUpdatedAt != null &&
        remoteNote.updatedAt.isAfter(note.remoteUpdatedAt!) &&
        note.localUpdatedAt.isAfter(note.remoteUpdatedAt!)) {
      await _markConflict(
        note,

        remoteNote.title,

        remoteNote.body,

        remoteNote.updatedAt,
      );

      await _storage.removeQueueItem(queueItemId);

      return false;
    }

    final updatedRemote = await _remoteRepository.updateNote(
      id: remoteId,

      title: note.title,

      body: note.body,

      userId: note.userId,

      category: note.category,
    );

    final synced = note.copyWith(
      remoteUpdatedAt: updatedRemote.updatedAt,

      syncStatus: NoteSyncStatus.synced,

      clearConflict: true,
    );

    await _storage.saveNote(synced);

    await _storage.removeQueueItem(queueItemId);

    return true;
  }

  Future<bool> _pushDelete(LocalNoteRecord note, String queueItemId) async {
    if (note.remoteId != null) {
      await _remoteRepository.deleteNote(note.remoteId!);
    }

    await _storage.removeQueueItem(queueItemId);

    await _storage.deleteNotePermanently(note.localId);

    return true;
  }

  Future<int> _pullRemoteChanges(
    String userId,

    SyncProgressCallback? onProgress,
  ) async {
    final remoteNotes = await _remoteRepository.getNotesByUserId(userId);

    if (remoteNotes.isEmpty) {
      onProgress?.call(92, 'Your notes are already current');
      await _reconcileRemoteDeletions(userId, remoteNotes);
      return 0;
    }

    var pulledCount = 0;

    for (var i = 0; i < remoteNotes.length; i++) {
      final remote = remoteNotes[i];

      final remoteId = remote.remoteId;

      if (remoteId == null) continue;

      final progress = 55 + ((i + 1) / remoteNotes.length * 35).round();

      onProgress?.call(progress, 'Refreshing your notes…');

      final local = _storage.getNoteByRemoteId(remoteId);

      if (local == null) {
        final imported = LocalNoteRecord(
          localId: _uuid.v4(),

          remoteId: remoteId,

          userId: remote.userId,

          title: remote.title,

          body: remote.body,

          category: remote.category,

          createdAt: remote.createdAt,

          updatedAt: remote.updatedAt,

          localUpdatedAt: remote.updatedAt,

          remoteUpdatedAt: remote.updatedAt,

          syncStatus: NoteSyncStatus.synced,
        );

        await _storage.saveNote(imported);

        pulledCount++;

        continue;
      }

      if (local.syncStatus == NoteSyncStatus.conflict) continue;

      final remoteIsNewer =
          local.remoteUpdatedAt == null ||
          remote.updatedAt.isAfter(local.remoteUpdatedAt!);

      final localIsNewer = local.localUpdatedAt.isAfter(
        local.remoteUpdatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      );

      final contentDiffers = _remoteDiffers(local, remote);

      if (local.syncStatus == NoteSyncStatus.pendingSync &&
          remoteIsNewer &&
          localIsNewer) {
        await _markConflict(local, remote.title, remote.body, remote.updatedAt);

        continue;
      }

      final shouldAdoptRemote =
          (local.syncStatus == NoteSyncStatus.synced &&
              (remoteIsNewer || contentDiffers)) ||
          (local.syncStatus == NoteSyncStatus.pendingSync &&
              !localIsNewer &&
              (remoteIsNewer || contentDiffers));

      if (shouldAdoptRemote) {
        await _adoptRemoteVersion(local, remote);
        pulledCount++;
      }
    }

    await _reconcileRemoteDeletions(userId, remoteNotes);

    return pulledCount;
  }

  bool _remoteDiffers(LocalNoteRecord local, NoteModel remote) {
    return local.title != remote.title ||
        local.body != remote.body ||
        local.category != remote.category;
  }

  Future<void> _adoptRemoteVersion(
    LocalNoteRecord local,
    NoteModel remote,
  ) async {
    final merged = local.copyWith(
      title: remote.title,
      body: remote.body,
      updatedAt: remote.updatedAt,
      remoteUpdatedAt: remote.updatedAt,
      localUpdatedAt: remote.updatedAt,
      category: remote.category,
      syncStatus: NoteSyncStatus.synced,
      clearConflict: true,
    );

    await _storage.saveNote(merged);
    await _storage.removeQueueItemsForNote(local.localId);
  }

  Future<void> _reconcileRemoteDeletions(
    String userId,
    List<NoteModel> remoteNotes,
  ) async {
    final remoteIds = remoteNotes
        .map((note) => note.remoteId)
        .whereType<String>()
        .toSet();

    final locals = _storage.getNotesForUser(userId).where(
      (note) =>
          note.remoteId != null &&
          note.syncStatus == NoteSyncStatus.synced &&
          !note.isDeleted,
    );

    for (final local in locals) {
      if (!remoteIds.contains(local.remoteId)) {
        await _storage.deleteNotePermanently(local.localId);
      }
    }
  }

  Future<void> _markConflict(
    LocalNoteRecord local,

    String remoteTitle,

    String remoteBody,

    DateTime remoteUpdatedAt,
  ) async {
    final conflicted = local.copyWith(
      syncStatus: NoteSyncStatus.conflict,

      conflictRemoteTitle: remoteTitle,

      conflictRemoteBody: remoteBody,

      conflictRemoteUpdatedAt: remoteUpdatedAt,
    );

    await _storage.saveNote(conflicted);
  }
}
