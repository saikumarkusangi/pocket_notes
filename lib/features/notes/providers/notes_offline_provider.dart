import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/providers/connectivity_provider.dart';
import 'package:pocket_notes/core/providers/github_provider.dart';
import 'package:pocket_notes/core/services/notes_sync_service.dart';
import 'package:pocket_notes/features/notes/data/local/hive_notes_storage.dart';
import 'package:pocket_notes/features/notes/data/repositories/notes_offline_repository.dart';
import 'package:pocket_notes/features/notes/data/repositories/remote_notes_repository.dart';

final hiveNotesStorageProvider = Provider<HiveNotesStorage>((ref) {
  throw UnimplementedError('HiveNotesStorage must be overridden in main.dart');
});

final notesOfflineRepositoryProvider = Provider<NotesOfflineRepository>((ref) {
  return NotesOfflineRepository(ref.watch(hiveNotesStorageProvider));
});

final remoteNotesRepositoryProvider = Provider<RemoteNotesRepository>((ref) {
  return RemoteNotesRepository(ref.watch(githubDatabaseProvider));
});

final notesSyncServiceProvider = Provider<NotesSyncService>((ref) {
  return NotesSyncService(
    storage: ref.watch(hiveNotesStorageProvider),
    remoteRepository: ref.watch(remoteNotesRepositoryProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
});
