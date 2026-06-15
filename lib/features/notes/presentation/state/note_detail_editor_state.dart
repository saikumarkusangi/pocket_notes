import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/data/models/note_model.dart';

enum NoteDetailAction { saved, deleted }

class NoteDetailEditorState {
  const NoteDetailEditorState({
    required this.note,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isSaving,
    required this.isDirty,
    this.errorMessage,
    this.completedAction,
  });

  const NoteDetailEditorState.missing()
    : note = null,
      title = '',
      body = '',
      createdAt = null,
      isSaving = false,
      isDirty = false,
      errorMessage = null,
      completedAction = null;

  factory NoteDetailEditorState.fromNote(NoteModel note) {
    return NoteDetailEditorState(
      note: note,
      title: note.title,
      body: note.body,
      createdAt: note.createdAt,
      isSaving: false,
      isDirty: false,
    );
  }

  final NoteModel? note;
  final String title;
  final String body;
  final DateTime? createdAt;
  final bool isSaving;
  final bool isDirty;
  final String? errorMessage;
  final NoteDetailAction? completedAction;

  bool get isMissing => note == null;
  bool get hasConflict => note?.hasConflict ?? false;
  NoteCategory? get category => note?.category;
  String? get noteId => note?.localId;

  NoteDetailEditorState copyWith({
    NoteModel? note,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isSaving,
    bool? isDirty,
    String? errorMessage,
    NoteDetailAction? completedAction,
    bool clearCompletedAction = false,
    bool clearError = false,
  }) {
    return NoteDetailEditorState(
      note: note ?? this.note,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isSaving: isSaving ?? this.isSaving,
      isDirty: isDirty ?? this.isDirty,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      completedAction: clearCompletedAction
          ? null
          : (completedAction ?? this.completedAction),
    );
  }
}
