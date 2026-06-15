import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/features/notes/data/notes_sample_data.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_body_field.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_editor_app_bar.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_editor_toolbar.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_title_field.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({
    super.key,
    required this.noteId,
  });

  final String noteId;

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    final note = NotesSampleData.findById(widget.noteId);
    _titleController = TextEditingController(text: note?.title ?? '');
    _bodyController = TextEditingController(text: note?.body ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final note = NotesSampleData.findById(widget.noteId);

    if (note == null) {
      return Scaffold(
        backgroundColor: AppColors.noteEditorBackground,
        appBar: const NoteEditorAppBar(),
        body: const Center(child: Text('Note not found')),
      );
    }

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
                    NoteTitleField(controller: _titleController),
                    const SizedBox(height: 20),
                    NoteBodyField(controller: _bodyController),
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
