import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/features/notes/data/notes_sample_data.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_list_card.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_new_entry_button.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/notes_list_app_bar.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({
    super.key,
    this.title = 'Journal',
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final notes = NotesSampleData.notes;

    return Scaffold(
      backgroundColor: AppColors.notesListBackground,
      appBar: NotesListAppBar(title: title),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        itemCount: notes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteListCard(
            note: note,
            onTap: () => context.push(
              '${AppConstants.noteDetailRoute}/${note.id}',
            ),
          );
        },
      ),
      bottomNavigationBar: NoteNewEntryButton(
        onPressed: () => context.push(AppConstants.createNoteRoute),
      ),
    );
  }
}
