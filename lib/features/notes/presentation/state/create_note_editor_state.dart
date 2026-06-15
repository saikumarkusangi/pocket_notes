import 'package:pocket_notes/features/notes/data/models/note_category.dart';

class CreateNoteEditorState {
  const CreateNoteEditorState({
    required this.category,
    this.title = '',
    this.body = '',
    this.isSaving = false,
    this.errorMessage,
    this.isCompleted = false,
  });

  final NoteCategory category;
  final String title;
  final String body;
  final bool isSaving;
  final String? errorMessage;
  final bool isCompleted;

  CreateNoteEditorState copyWith({
    String? title,
    String? body,
    bool? isSaving,
    String? errorMessage,
    bool? isCompleted,
    bool clearError = false,
    bool clearCompleted = false,
  }) {
    return CreateNoteEditorState(
      category: category,
      title: title ?? this.title,
      body: body ?? this.body,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isCompleted: clearCompleted ? false : (isCompleted ?? this.isCompleted),
    );
  }
}
