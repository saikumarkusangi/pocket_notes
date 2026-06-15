import 'package:pocket_notes/features/notes/data/models/note_model.dart';

class NoteConflictState {
  const NoteConflictState({
    this.note,
    this.isResolving = false,
    this.errorMessage,
    this.isResolved = false,
  });

  final NoteModel? note;
  final bool isResolving;
  final String? errorMessage;
  final bool isResolved;

  bool get isMissing => note == null || !note!.hasConflict;

  NoteConflictState copyWith({
    NoteModel? note,
    bool? isResolving,
    String? errorMessage,
    bool? isResolved,
    bool clearError = false,
    bool clearResolved = false,
  }) {
    return NoteConflictState(
      note: note ?? this.note,
      isResolving: isResolving ?? this.isResolving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isResolved: clearResolved ? false : (isResolved ?? this.isResolved),
    );
  }
}
