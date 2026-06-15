import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_body_field.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_editor_app_bar.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_editor_toolbar.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_title_field.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.noteEditorBackground,
      appBar: NoteEditorAppBar(
        onMenuTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note options coming soon')),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NoteTitleField(
                      controller: _titleController,
                      hintText: 'Untitled note',
                    ),
                    const SizedBox(height: 20),
                    NoteBodyField(
                      controller: _bodyController,
                      autofocus: true,
                    ),
                  ],
                ),
              ),
            ),
            NoteEditorToolbar(
              onAddTap: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
