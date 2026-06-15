import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/services/notes_sync_coordinator.dart';
import 'package:pocket_notes/features/notes/presentation/state/note_conflict_state.dart';
import 'package:pocket_notes/features/notes/providers/notes_offline_provider.dart';
import 'package:pocket_notes/features/notes/providers/notes_provider.dart';

final noteConflictProvider = NotifierProvider.autoDispose.family<
  NoteConflictNotifier,
  NoteConflictState,
  String
>(NoteConflictNotifier.new);

class NoteConflictNotifier extends Notifier<NoteConflictState> {
  NoteConflictNotifier(this._localId);

  final String _localId;
  NoteConflictState? _cachedState;

  @override
  NoteConflictState build() {
    ref.watch(notesRefreshProvider);
    final note = ref.watch(noteDetailProvider(_localId));

    final cached = _cachedState;
    if (cached != null) {
      final updated = cached.copyWith(note: note);
      _cachedState = updated;
      return updated;
    }

    final initial = NoteConflictState(note: note);
    _cachedState = initial;
    return initial;
  }

  void _emit(NoteConflictState next) {
    _cachedState = next;
    state = next;
  }

  void clearResolved() {
    if (!state.isResolved) return;
    _emit(state.copyWith(clearResolved: true));
  }

  Future<void> resolve({required bool keepLocal}) async {
    if (state.isResolving) return;

    _emit(state.copyWith(isResolving: true, clearError: true));

    try {
      final repo = ref.read(notesOfflineRepositoryProvider);
      final note = keepLocal
          ? await repo.resolveConflictKeepLocal(_localId)
          : await repo.resolveConflictKeepRemote(_localId);

      if (note != null) {
        ref.read(notesRefreshProvider.notifier).bump();
        if (keepLocal) {
          await ref.read(notesSyncCoordinatorProvider).run(
            showNotification: true,
            notifyWhenIdle: true,
          );
        }
      }

      _emit(state.copyWith(isResolving: false, isResolved: true));
    } catch (error) {
      _emit(
        state.copyWith(
          isResolving: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
