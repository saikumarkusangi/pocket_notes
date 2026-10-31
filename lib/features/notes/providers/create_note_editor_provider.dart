import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/services/notes_sync_coordinator.dart';
import 'package:pocket_notes/features/auth/providers/auth_provider.dart';
import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/presentation/state/create_note_editor_state.dart';
import 'package:pocket_notes/features/notes/providers/notes_offline_provider.dart';
import 'package:pocket_notes/features/notes/providers/notes_provider.dart';

final createNoteEditorProvider = NotifierProvider.autoDispose.family<
  CreateNoteEditorNotifier,
  CreateNoteEditorState,
  NoteCategory
>(CreateNoteEditorNotifier.new);

class CreateNoteEditorNotifier extends Notifier<CreateNoteEditorState> {
  CreateNoteEditorNotifier(this._category);

  final NoteCategory _category;

  @override
  CreateNoteEditorState build() {
    return CreateNoteEditorState(category: _category);
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title, clearError: true);
  }

  void updateBody(String body) {
    state = state.copyWith(body: body, clearError: true);
  }

  void clearCompleted() {
    if (!state.isCompleted) return;
    state = state.copyWith(clearCompleted: true);
  }

  Future<void> save() async {
    if (state.isSaving) return;

    final user = ref.read(authProvider).user;
    if (user == null || user.id.isEmpty) {
      state = state.copyWith(
        errorMessage: 'You must be logged in to save a note.',
      );
      return;
    }

    final title = state.title.trim();
    final body = state.body.trim();
    if (title.isEmpty && body.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Add a title or some content before saving.',
      );
      return;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      await ref.read(notesOfflineRepositoryProvider).createNote(
        userId: user.id,
        title: title.isEmpty ? 'Untitled' : title,
        body: body,
        category: state.category,
      );

      ref.read(notesRefreshProvider.notifier).bump();
      final sync = ref.read(notesSyncCoordinatorProvider);
      state = state.copyWith(isSaving: false, isCompleted: true);
      unawaited(sync.run(showNotification: false));
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: error.toString(),
      );
    }
  }
}
