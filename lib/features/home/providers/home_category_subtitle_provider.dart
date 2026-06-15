import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/utils/date_formats.dart';
import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/data/models/note_model.dart';
import 'package:pocket_notes/features/notes/providers/notes_provider.dart';

final homeCategorySubtitleProvider = Provider.family<String, NoteCategory>((
  ref,
  category,
) {
  final notes = ref.watch(notesListProvider(category));
  return HomeCategorySubtitle.forCategory(category, notes);
});

class HomeCategorySubtitle {
  HomeCategorySubtitle._();

  static String forCategory(NoteCategory category, List<NoteModel> notes) {
    if (notes.isEmpty) {
      return switch (category) {
        NoteCategory.shoppingList => 'No items yet',
        _ => 'No notes yet',
      };
    }

    return switch (category) {
      NoteCategory.shoppingList => _shoppingSubtitle(notes),
      _ => _lastUpdatedSubtitle(notes),
    };
  }

  static String _lastUpdatedSubtitle(List<NoteModel> notes) {
    final latest = notes.reduce(
      (current, note) =>
          note.updatedAt.isAfter(current.updatedAt) ? note : current,
    );
    return 'Last updated: ${DateFormats.formatHomeSubtitleDate(latest.updatedAt)}';
  }

  static String _shoppingSubtitle(List<NoteModel> notes) {
    final remaining = notes.fold<int>(
      0,
      (total, note) => total + note.remainingItemCount,
    );

    if (remaining == 0) return 'All items done';
    if (remaining == 1) return '1 item left';
    return '$remaining items left';
  }
}
