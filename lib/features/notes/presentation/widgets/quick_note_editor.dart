import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_body_field.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_title_field.dart';

class QuickNoteEditor extends StatelessWidget {
  const QuickNoteEditor({
    super.key,
    required this.titleController,
    required this.bodyController,
    this.titleHint = 'Quick note title',
    this.bodyHint = 'Write your note...',
    this.autofocusBody = false,
    this.actionButtonColor = AppColors.card,
  });

  final TextEditingController titleController;
  final TextEditingController bodyController;
  final String titleHint;
  final String bodyHint;
  final bool autofocusBody;
  final Color actionButtonColor;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: NoteBodyField(
        controller: bodyController,
        hintText: bodyHint,
        autofocus: autofocusBody,
      ),
    );
  }
}
