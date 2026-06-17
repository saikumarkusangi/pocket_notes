import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:pocket_notes/core/services/notes_sync_service.dart';
import 'package:pocket_notes/features/notes/data/local/hive_notes_storage.dart';
import 'package:pocket_notes/features/notes/data/models/note_sync_status.dart';
import 'package:pocket_notes/features/notes/data/models/sync_operation_type.dart';
import 'package:pocket_notes/features/notes/data/repositories/notes_offline_repository.dart';
import 'package:pocket_notes/features/notes/presentation/state/note_conflict_state.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_conflict_body.dart';

import 'helpers/fake_connectivity_service.dart';
import 'helpers/fake_remote_notes_repository.dart';
import 'helpers/notes_test_fixtures.dart';

/// Run with:
/// `flutter test test/notes_conflict_merge_test.dart`
///
/// These tests document how Pocket Notes detects sync conflicts and resolves
/// them when you choose "Keep my version" or "Keep server version".
void main() {
  late Directory tempDir;
  late Box<dynamic> notesBox;
  late Box<dynamic> queueBox;
  late HiveNotesStorage storage;
  late NotesOfflineRepository repository;
  late FakeRemoteNotesRepository fakeRemote;
  late TestableRemoteNotesRepository remoteRepository;
  late NotesSyncService syncService;

  Future<void> openFreshStorage() async {
    final suffix = DateTime.now().microsecondsSinceEpoch;
    notesBox = await Hive.openBox('notes_$suffix');
    queueBox = await Hive.openBox('queue_$suffix');
    storage = HiveNotesStorage(notesBox, queueBox);
    repository = NotesOfflineRepository(storage);
    fakeRemote = FakeRemoteNotesRepository();
    remoteRepository = TestableRemoteNotesRepository(fakeRemote);
    syncService = NotesSyncService(
      storage: storage,
      remoteRepository: remoteRepository,
      connectivityService: FakeConnectivityService(),
    );
  }

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('pocket_notes_test');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() async {
    await openFreshStorage();
  });

  tearDown(() async {
    await notesBox.clear();
    await queueBox.clear();
    await notesBox.close();
    await queueBox.close();
  });

  group('1. Conflict detection during pull', () {
    test(
      'flags a note when local pending edits and server both changed since last sync',
      () async {
        // Device last synced on Jun 10. User edits locally on Jun 15 (pending).
        // Server was updated on Jun 14. Both sides diverged -> conflict.
        final local = NotesTestFixtures.syncedLocalNote(
          title: 'My edited title',
          body: 'My edited body',
          syncStatus: NoteSyncStatus.pendingSync,
          localUpdatedAt: NotesTestFixtures.localEditedAt,
          remoteUpdatedAt: NotesTestFixtures.lastSyncedAt,
        );
        await storage.saveNote(local);

        fakeRemote.seedNote(
          NotesTestFixtures.remoteNote(
            title: 'Server title',
            body: 'Server body',
            updatedAt: NotesTestFixtures.remoteEditedAt,
          ),
        );

        await syncService.sync(NotesTestFixtures.userId);

        final stored = storage.getNoteByLocalId(NotesTestFixtures.localId)!;

        expect(stored.syncStatus, NoteSyncStatus.conflict);
        expect(stored.title, 'My edited title');
        expect(stored.body, 'My edited body');
        expect(stored.conflictRemoteTitle, 'Server title');
        expect(stored.conflictRemoteBody, 'Server body');
        expect(stored.conflictRemoteUpdatedAt, NotesTestFixtures.remoteEditedAt);
      },
    );
  });

  group('2. Conflict detection during push', () {
    test(
      'flags a note when uploading local edits but server already has newer data',
      () async {
        final local = NotesTestFixtures.syncedLocalNote(
          title: 'My edited title',
          body: 'My edited body',
          syncStatus: NoteSyncStatus.pendingSync,
          localUpdatedAt: NotesTestFixtures.localEditedAt,
          remoteUpdatedAt: NotesTestFixtures.lastSyncedAt,
        );
        await storage.saveNote(local);
        await storage.upsertQueueOperation(
          localNoteId: NotesTestFixtures.localId,
          userId: NotesTestFixtures.userId,
          operation: SyncOperationType.update,
          queueItemId: 'queue-1',
        );

        fakeRemote.seedNote(
          NotesTestFixtures.remoteNote(
            title: 'Server title',
            body: 'Server body',
            updatedAt: NotesTestFixtures.remoteEditedAt,
          ),
        );

        await syncService.sync(NotesTestFixtures.userId);

        final stored = storage.getNoteByLocalId(NotesTestFixtures.localId)!;

        expect(stored.syncStatus, NoteSyncStatus.conflict);
        expect(stored.conflictRemoteTitle, 'Server title');
        expect(stored.conflictRemoteBody, 'Server body');
        expect(storage.getQueueForUser(NotesTestFixtures.userId), isEmpty);
      },
    );
  });

  group('3. Auto-merge (no conflict)', () {
    test('overwrites a synced local note when only the server changed', () async {
      final local = NotesTestFixtures.syncedLocalNote(
        title: 'Old local title',
        body: 'Old local body',
        syncStatus: NoteSyncStatus.synced,
        localUpdatedAt: NotesTestFixtures.lastSyncedAt,
        remoteUpdatedAt: NotesTestFixtures.lastSyncedAt,
      );
      await storage.saveNote(local);

      fakeRemote.seedNote(
        NotesTestFixtures.remoteNote(
          title: 'Server title',
          body: 'Server body',
          updatedAt: NotesTestFixtures.remoteEditedAt,
        ),
      );

      await syncService.sync(NotesTestFixtures.userId);

      final stored = storage.getNoteByLocalId(NotesTestFixtures.localId)!;

      expect(stored.syncStatus, NoteSyncStatus.synced);
      expect(stored.title, 'Server title');
      expect(stored.body, 'Server body');
      expect(stored.remoteUpdatedAt, NotesTestFixtures.remoteEditedAt);
      expect(stored.syncStatus, isNot(NoteSyncStatus.conflict));
    });

    test(
      'pulls server edits even when updatedAt was not changed in the database',
      () async {
        final local = NotesTestFixtures.syncedLocalNote(
          title: 'Old local title',
          body: 'Old local body',
          syncStatus: NoteSyncStatus.synced,
          localUpdatedAt: NotesTestFixtures.lastSyncedAt,
          remoteUpdatedAt: NotesTestFixtures.lastSyncedAt,
        );
        await storage.saveNote(local);

        fakeRemote.seedNote(
          NotesTestFixtures.remoteNote(
            title: 'Edited directly in DB',
            body: 'New body from admin',
            updatedAt: NotesTestFixtures.lastSyncedAt,
          ),
        );

        await syncService.sync(NotesTestFixtures.userId);

        final stored = storage.getNoteByLocalId(NotesTestFixtures.localId)!;

        expect(stored.title, 'Edited directly in DB');
        expect(stored.body, 'New body from admin');
      },
    );

    test('removes local notes deleted on the server', () async {
      await storage.saveNote(NotesTestFixtures.syncedLocalNote());
      fakeRemote.notesByUser.clear();
      fakeRemote.notesById.clear();

      await syncService.sync(NotesTestFixtures.userId);

      expect(storage.getNoteByLocalId(NotesTestFixtures.localId), isNull);
    });
  });

  group('4. Manual merge — Keep my version', () {
    test('clears conflict metadata and queues an update for sync', () async {
      await storage.saveNote(NotesTestFixtures.conflictedLocalNote());

      final resolved = await repository.resolveConflictKeepLocal(
        NotesTestFixtures.localId,
      );

      expect(resolved, isNotNull);
      expect(resolved!.syncStatus, NoteSyncStatus.pendingSync);
      expect(resolved.title, 'My edited title');
      expect(resolved.body, 'My edited body');
      expect(resolved.hasConflict, isFalse);

      final queue = storage.getQueueForUser(NotesTestFixtures.userId);
      expect(queue, hasLength(1));
      expect(queue.first.operation, SyncOperationType.update);
    });
  });

  group('5. Manual merge — Keep server version', () {
    test('applies remote fields locally and marks the note synced', () async {
      await storage.saveNote(NotesTestFixtures.conflictedLocalNote());

      final resolved = await repository.resolveConflictKeepRemote(
        NotesTestFixtures.localId,
      );

      expect(resolved, isNotNull);
      expect(resolved!.syncStatus, NoteSyncStatus.synced);
      expect(resolved.title, 'Server title');
      expect(resolved.body, 'Server body');
      expect(resolved.updatedAt, NotesTestFixtures.remoteEditedAt);
      expect(resolved.hasConflict, isFalse);
      expect(storage.getQueueForUser(NotesTestFixtures.userId), isEmpty);
    });
  });

  group('6. Conflict UI review', () {
    testWidgets('shows both local and server versions side by side', (
      tester,
    ) async {
      final note = NotesTestFixtures.conflictedLocalNote().toNoteModel();
      final state = NoteConflictState(note: note);

      expect(state.isMissing, isFalse);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteConflictBody(
              note: note,
              isResolving: false,
              onKeepLocal: () {},
              onKeepRemote: () {},
            ),
          ),
        ),
      );

      expect(find.text('Resolve Conflict'), findsOneWidget);
      expect(find.text('Your Version'), findsOneWidget);
      expect(find.text('Cloud Version'), findsOneWidget);
      expect(find.text('My edited title'), findsOneWidget);
      expect(find.text('My edited body'), findsOneWidget);
      expect(find.text('Server title'), findsOneWidget);
      expect(find.text('Server body'), findsOneWidget);
      expect(find.text('Use Local Version'), findsOneWidget);
      expect(find.text('Use Cloud Version'), findsOneWidget);
    });
  });
}
