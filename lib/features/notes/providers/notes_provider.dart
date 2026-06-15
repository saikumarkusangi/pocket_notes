import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/network/connectivity_service.dart';
import 'package:pocket_notes/core/providers/connectivity_provider.dart';
import 'package:pocket_notes/core/services/notes_sync_coordinator.dart';
import 'package:pocket_notes/features/auth/providers/auth_provider.dart';
import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/data/models/note_model.dart';
import 'package:pocket_notes/features/notes/providers/notes_cache_provider.dart';
import 'package:pocket_notes/features/notes/providers/notes_sync_state_provider.dart';

export 'package:pocket_notes/features/notes/providers/notes_sync_state_provider.dart';

final isOfflineProvider = Provider<bool>((ref) {
  final statusAsync = ref.watch(connectivityStatusProvider);
  return statusAsync.maybeWhen(
    data: (status) => status == ConnectivityStatus.offline,
    orElse: () =>
        ref.read(connectivityServiceProvider).lastKnownStatus ==
        ConnectivityStatus.offline,
  );
});

Future<void> requestNotesSync(WidgetRef ref) async {
  await ref.read(notesSyncCoordinatorProvider).run(
    showNotification: true,
    notifyWhenIdle: true,
  );
}

final notesBackgroundSyncProvider = Provider<void>((ref) {
  Future<void> runSync() async {
    await ref.read(notesSyncCoordinatorProvider).run(
      showNotification: true,
      notifyWhenIdle: false,
    );
  }

  ref.listen(connectivityStatusProvider, (previous, next) {
    if (next.value == ConnectivityStatus.online) {
      runSync();
    }
  });

  ref.listen(authProvider, (previous, next) {
    if (next.isAuthenticated && next.user?.id.isNotEmpty == true) {
      runSync();
    }
  });

  Future.microtask(runSync);
});

/// Reads notes instantly from the on-device cache (Hive).
final notesListProvider = Provider.family<List<NoteModel>, NoteCategory>((
  ref,
  category,
) {
  ref.watch(notesBackgroundSyncProvider);
  ref.watch(notesRefreshProvider);

  final user = ref.watch(authProvider).user;
  if (user == null) return [];

  return ref.read(notesCacheServiceProvider).getNotesForCategory(
    user: user,
    category: category,
  );
});

/// Reads a single note instantly from the on-device cache.
final noteDetailProvider = Provider.family<NoteModel?, String>((ref, localId) {
  ref.watch(notesRefreshProvider);
  return ref.read(notesCacheServiceProvider).getNoteByLocalId(localId);
});

final notesCacheInfoProvider = Provider<NotesCacheInfo?>((ref) {
  ref.watch(notesRefreshProvider);
  final user = ref.watch(authProvider).user;
  if (user == null) return null;

  final cache = ref.read(notesCacheServiceProvider);
  return NotesCacheInfo(
    hasCachedNotes: cache.hasCachedNotesForUser(user.id),
    lastSyncedAt: cache.getLastSyncedAt(user.id),
  );
});

class NotesCacheInfo {
  const NotesCacheInfo({
    required this.hasCachedNotes,
    this.lastSyncedAt,
  });

  final bool hasCachedNotes;
  final DateTime? lastSyncedAt;
}
