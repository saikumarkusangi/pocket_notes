import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/features/notes/presentation/state/note_detail_editor_state.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/delete_dialog.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_detail_editor_body.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_editor_app_bar.dart';
import 'package:pocket_notes/features/notes/providers/note_detail_editor_provider.dart';

class NoteDetailScreen extends ConsumerWidget {
  const NoteDetailScreen({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(noteDetailEditorProvider(noteId));
    final notifier = ref.read(noteDetailEditorProvider(noteId).notifier);

    ref.listen(noteDetailEditorProvider(noteId), (previous, next) {
      _handleEditorSideEffects(context, ref, previous, next);
    });

    if (editorState.isMissing) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: const NoteEditorAppBar(appBarColor: Colors.white),
        body: const Center(child: Text('Note not found')),
      );
    }


    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: NoteEditorAppBar(
        appBarColor: Colors.white,
        actionButtonTap: editorState.isSaving
            ? null
            : () => _showDeleteDialog(context, notifier.delete),
        actionButtonText: 'Delete',
        secondaryActionButtonTap: editorState.isSaving ? null : notifier.save,
        secondaryActionButtonText: 'Save',
      ),
      body: SafeArea(
        child: NoteDetailEditorBody(
          state: editorState,
          onTitleChanged: notifier.updateTitle,
          onBodyChanged: notifier.updateBody,
          onSave: editorState.isSaving ? null : notifier.save,
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Future<void> Function() onDelete,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => DeleteDialog(onConfirm: onDelete),
    );
  }

  void _handleEditorSideEffects(
    BuildContext context,
    WidgetRef ref,
    NoteDetailEditorState? previous,
    NoteDetailEditorState next,
  ) {
    final notifier = ref.read(noteDetailEditorProvider(noteId).notifier);

    if (next.errorMessage != null &&
        next.errorMessage != previous?.errorMessage) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
    }

    if (next.hasConflict && previous?.hasConflict != true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.push('${AppConstants.noteConflictRoute}/${next.noteId}');
      });
    }

    final action = next.completedAction;
    if (action == null || action == previous?.completedAction) return;

    notifier.clearCompletedAction();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.pop();
    });
  }
}
