import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/services/notes_sync_coordinator.dart';
import 'package:pocket_notes/features/notes/presentation/state/note_detail_editor_state.dart';
import 'package:pocket_notes/features/notes/providers/notes_offline_provider.dart';
import 'package:pocket_notes/features/notes/providers/notes_provider.dart';

final noteDetailEditorProvider = NotifierProvider.autoDispose.family<
  NoteDetailEditorNotifier,
  NoteDetailEditorState,
  String
>(NoteDetailEditorNotifier.new);

class NoteDetailEditorNotifier extends Notifier<NoteDetailEditorState> {
  NoteDetailEditorNotifier(this._noteId);

  final String _noteId;
  NoteDetailEditorState? _cachedState;

  @override
  NoteDetailEditorState build() {
    ref.watch(notesRefreshProvider);
    final note = ref.watch(noteDetailProvider(_noteId));

    if (note == null) {
      _cachedState = null;
      return const NoteDetailEditorState.missing();
    }

    final cached = _cachedState;
    if (cached != null && cached.note?.localId == note.localId) {
      final updated = cached.copyWith(note: note);
      _cachedState = updated;
      return updated;
    }

    final initial = NoteDetailEditorState.fromNote(note);
    _cachedState = initial;
    return initial;
  }

  void _emit(NoteDetailEditorState next) {
    _cachedState = next;
    state = next;
  }

  void updateTitle(String title) {
    if (state.isMissing) return;
    _emit(state.copyWith(title: title, isDirty: true, clearError: true));
  }

  void updateBody(String body) {
    if (state.isMissing) return;
    _emit(state.copyWith(body: body, isDirty: true, clearError: true));
  }

  void clearCompletedAction() {
    if (state.completedAction == null) return;
    _emit(state.copyWith(clearCompletedAction: true));
  }

  Future<void> save() async {
    final note = state.note;
    if (note == null || state.isSaving) return;

    _emit(state.copyWith(isSaving: true, clearError: true));

    try {
      await ref.read(notesOfflineRepositoryProvider).updateNote(
        localId: note.localId,
        title: state.title.trim().isEmpty ? 'Untitled' : state.title.trim(),
        body: state.body.trim(),
      );

      ref.read(notesRefreshProvider.notifier).bump();
      await ref.read(notesSyncCoordinatorProvider).run(
        showNotification: true,
        notifyWhenIdle: true,
      );

      _emit(
        state.copyWith(
          isSaving: false,
          isDirty: false,
          completedAction: NoteDetailAction.saved,
        ),
      );
    } catch (error) {
      _emit(
        state.copyWith(
          isSaving: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> delete() async {
    final note = state.note;
    if (note == null || state.isSaving) return;

    _emit(state.copyWith(isSaving: true, clearError: true));

    try {
      await ref.read(notesOfflineRepositoryProvider).deleteNote(note.localId);
      ref.read(notesRefreshProvider.notifier).bump();
      await ref.read(notesSyncCoordinatorProvider).run(
        showNotification: true,
        notifyWhenIdle: true,
      );

      _emit(
        state.copyWith(
          isSaving: false,
          completedAction: NoteDetailAction.deleted,
        ),
      );
    } catch (error) {
      _emit(
        state.copyWith(
          isSaving: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
