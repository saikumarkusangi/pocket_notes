import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/data/models/note_model.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/journal_note_card.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/password_notes_list.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/quick_note_card.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/shopping_list_card.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/todo_list_card.dart';

class CategoryNotesListBody extends StatelessWidget {
  const CategoryNotesListBody({
    super.key,
    required this.category,
    required this.notes,
  });

  final NoteCategory category;
  final List<NoteModel> notes;

  static const _quickNoteColors = [
    Color(0xFFFFF59D),
    Color(0xFFBBDEFB),
    Color(0xFFF8BBD0),
    Color(0xFFE1BEE7),
    Color(0xFFC8E6C9),
  ];

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.5,
            child: Center(
              child: Text(
                'No ${category.title.toLowerCase()} yet',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }

    return switch (category) {
      NoteCategory.journal => ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        itemCount: notes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => JournalNoteCard(
          note: notes[index],
          onTap: () => _openNote(context, notes[index]),
        ),
      ),
      NoteCategory.quickNotes => GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.95,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) => QuickNoteCard(
          note: notes[index],
          color: _quickNoteColors[index % _quickNoteColors.length],
          onTap: () => _openNote(context, notes[index]),
        ),
      ),
      NoteCategory.shoppingList => ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        itemCount: notes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => ShoppingListCard(
          note: notes[index],
          onTap: () => _openNote(context, notes[index]),
        ),
      ),
      NoteCategory.todoList => ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        itemCount: notes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => TodoListCard(
          note: notes[index],
          onTap: () => _openNote(context, notes[index]),
        ),
      ),
      NoteCategory.passwordManager => PasswordNotesList(
        notes: notes,
        onOpenNote: (note) => _openNote(context, note),
      ),
    };
  }

  void _openNote(BuildContext context, NoteModel note) {
    if (note.hasConflict) {
      context.push('${AppConstants.noteConflictRoute}/${note.localId}');
      return;
    }
    context.push('${AppConstants.noteDetailRoute}/${note.localId}');
  }
}
