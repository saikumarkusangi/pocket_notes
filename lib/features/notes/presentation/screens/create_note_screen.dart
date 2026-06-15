import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/presentation/state/create_note_editor_state.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/create_note_editor_body.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_editor_app_bar.dart';
import 'package:pocket_notes/features/notes/providers/create_note_editor_provider.dart';

class CreateNoteScreen extends ConsumerWidget {
  const CreateNoteScreen({super.key, this.category = NoteCategory.journal});

  final NoteCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(createNoteEditorProvider(category));
    final notifier = ref.read(createNoteEditorProvider(category).notifier);

    ref.listen(createNoteEditorProvider(category), (previous, next) {
      _handleEditorSideEffects(context, notifier, previous, next);
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: NoteEditorAppBar(
        appBarColor: category.appBarColor,
        actionButtonTap: editorState.isSaving ? null : notifier.save,
        actionButtonText: 'Save',
      ),
      body: SafeArea(
        child: CreateNoteEditorBody(
          state: editorState,
          onTitleChanged: notifier.updateTitle,
          onBodyChanged: notifier.updateBody,
          onSave: editorState.isSaving ? null : notifier.save,
        ),
      ),
    );
  }

  void _handleEditorSideEffects(
    BuildContext context,
    CreateNoteEditorNotifier notifier,
    CreateNoteEditorState? previous,
    CreateNoteEditorState next,
  ) {
    if (next.errorMessage != null &&
        next.errorMessage != previous?.errorMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.errorMessage!)),
      );
    }

    if (!next.isCompleted || previous?.isCompleted == true) return;

    notifier.clearCompleted();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.pop();
    });
  }
}
