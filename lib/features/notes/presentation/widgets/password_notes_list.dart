import 'package:flutter/material.dart';
import 'package:pocket_notes/features/notes/data/models/note_model.dart';
import 'package:pocket_notes/features/notes/data/models/password_entry.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/password_list_filter.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/password_manager_card.dart';

class PasswordNotesList extends StatefulWidget {
  const PasswordNotesList({
    super.key,
    required this.notes,
    required this.onOpenNote,
  });

  final List<NoteModel> notes;
  final ValueChanged<NoteModel> onOpenNote;

  @override
  State<PasswordNotesList> createState() => _PasswordNotesListState();
}

class _PasswordNotesListState extends State<PasswordNotesList> {
  String _selected = PasswordListFilter.all;

  @override
  Widget build(BuildContext context) {
    final categories = [
      for (final note in widget.notes)
        PasswordEntry.fromBody(note.body).category,
    ];
    final labels = PasswordListFilter.labelsFor(categories);
    final selected = labels.contains(_selected)
        ? _selected
        : PasswordListFilter.all;
    final visibleNotes = [
      for (final note in widget.notes)
        if (PasswordListFilter.matches(
          category: PasswordEntry.fromBody(note.body).category,
          selected: selected,
        ))
          note,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            itemCount: labels.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final label = labels[index];
              final isSelected = label == selected;
              return FilterChip(
                label: Text(label),
                selected: isSelected,
                showCheckmark: false,
                onSelected: (_) => setState(() => _selected = label),
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFFEDE9FE),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF7C3AED)
                      : const Color(0xFFE5E7EB),
                ),
                labelStyle: TextStyle(
                  color: isSelected
                      ? const Color(0xFF6D28D9)
                      : const Color(0xFF374151),
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        Expanded(child: _PasswordFilteredList(
          notes: visibleNotes,
          onOpenNote: widget.onOpenNote,
        )),
      ],
    );
  }
}

class _PasswordFilteredList extends StatelessWidget {
  const _PasswordFilteredList({required this.notes, required this.onOpenNote});

  final List<NoteModel> notes;
  final ValueChanged<NoteModel> onOpenNote;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.4,
            child: const Center(
              child: Text(
                'No passwords in this category',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) => PasswordManagerCard(
        note: notes[index],
        onTap: () => onOpenNote(notes[index]),
      ),
    );
  }
}
