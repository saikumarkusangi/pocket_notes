import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/network/connectivity_service.dart';
import 'package:pocket_notes/core/services/notes_sync_service.dart';
import 'package:pocket_notes/core/services/sync_notification_service.dart';
import 'package:pocket_notes/core/providers/connectivity_provider.dart';
import 'package:pocket_notes/features/auth/providers/auth_provider.dart';
import 'package:pocket_notes/features/notes/data/repositories/notes_offline_repository.dart';
import 'package:pocket_notes/core/services/notes_cache_service.dart';
import 'package:pocket_notes/features/notes/providers/notes_cache_provider.dart';
import 'package:pocket_notes/features/notes/providers/notes_offline_provider.dart';
import 'package:pocket_notes/features/notes/providers/notes_sync_state_provider.dart';

class NotesSyncCoordinator {
  NotesSyncCoordinator({
    required AuthState Function() readAuthState,
    required Future<void> Function() repairSession,
    required ConnectivityService connectivity,
    required NotesSyncService syncService,
    required NotesOfflineRepository offlineRepository,
    required NotesCacheService cacheService,
    required SyncNotificationService notificationService,
    required NotesSyncingNotifier syncingNotifier,
    required NotesRefreshNotifier refreshNotifier,
  }) : _readAuthState = readAuthState,
       _repairSession = repairSession,
       _connectivity = connectivity,
       _syncService = syncService,
       _offlineRepository = offlineRepository,
       _cacheService = cacheService,
       _notificationService = notificationService,
       _syncingNotifier = syncingNotifier,
       _refreshNotifier = refreshNotifier;

  final AuthState Function() _readAuthState;
  final Future<void> Function() _repairSession;
  final ConnectivityService _connectivity;
  final NotesSyncService _syncService;
  final NotesOfflineRepository _offlineRepository;
  final NotesCacheService _cacheService;
  final SyncNotificationService _notificationService;
  final NotesSyncingNotifier _syncingNotifier;
  final NotesRefreshNotifier _refreshNotifier;

  Future<void> run({
    bool showNotification = true,
    bool notifyWhenIdle = false,
  }) async {
    final user = _readAuthState().user;
    if (user == null || user.id.isEmpty) return;
    if (!await _connectivity.isConnected) return;

    _syncingNotifier.setSyncing(true);

    if (showNotification) {
      await _notificationService.showSyncProgress(progress: 0);
    }

    try {
      await _repairSession();
      final activeUser = _readAuthState().user;
      if (activeUser == null || activeUser.id.isEmpty) return;

      await _offlineRepository.repairOrphanedNotes(activeUser.id);

      final result = await _syncService.sync(
        activeUser.id,
        onProgress: showNotification
            ? (progress, message) {
                _notificationService.showSyncProgress(
                  progress: progress,
                  message: message,
                );
              }
            : null,
      );

      if (result.success) {
        await _cacheService.markSynced(activeUser.id);
        if (showNotification &&
            (result.hasChanges || notifyWhenIdle || result.pendingCount > 0)) {
          await _notificationService.showSyncSuccess(
            pushedCount: result.pushedCount,
            pulledCount: result.pulledCount,
            pendingCount: result.pendingCount,
          );
        } else if (showNotification) {
          await _notificationService.dismiss();
        }
      } else if (showNotification) {
        await _notificationService.showSyncFailure();
      }

      _refreshNotifier.bump();
    } catch (_) {
      if (showNotification) {
        await _notificationService.showSyncFailure();
      }
    } finally {
      _syncingNotifier.setSyncing(false);
    }
  }
}

final notesSyncCoordinatorProvider = Provider<NotesSyncCoordinator>((ref) {
  return NotesSyncCoordinator(
    readAuthState: () => ref.read(authProvider),
    repairSession: () => ref.read(authProvider.notifier).repairSessionIfNeeded(),
    connectivity: ref.watch(connectivityServiceProvider),
    syncService: ref.watch(notesSyncServiceProvider),
    offlineRepository: ref.watch(notesOfflineRepositoryProvider),
    cacheService: ref.watch(notesCacheServiceProvider),
    notificationService: ref.watch(syncNotificationServiceProvider),
    syncingNotifier: ref.watch(notesSyncingProvider.notifier),
    refreshNotifier: ref.watch(notesRefreshProvider.notifier),
  );
});
