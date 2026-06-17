import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/features/notes/presentation/state/note_conflict_state.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_conflict_body.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_editor_app_bar.dart';
import 'package:pocket_notes/features/notes/providers/note_conflict_provider.dart';

class NoteConflictScreen extends ConsumerWidget {
  const NoteConflictScreen({super.key, required this.localId});

  final String localId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conflictState = ref.watch(noteConflictProvider(localId));
    final notifier = ref.read(noteConflictProvider(localId).notifier);

    ref.listen(noteConflictProvider(localId), (previous, next) {
      _handleConflictSideEffects(context, notifier, previous, next);
    });

    if (conflictState.isMissing) {
      return Scaffold(
        appBar: const NoteEditorAppBar(appBarColor: Colors.white),
        body: const Center(child: Text('No conflict found for this note.')),
      );
    }

    final note = conflictState.note!;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: NoteEditorAppBar(appBarColor: Colors.white),
      body: NoteConflictBody(
        note: note,
        isResolving: conflictState.isResolving,
        onKeepLocal: () => notifier.resolve(keepLocal: true),
        onKeepRemote: () => notifier.resolve(keepLocal: false),
      ),
    );
  }

  void _handleConflictSideEffects(
    BuildContext context,
    NoteConflictNotifier notifier,
    NoteConflictState? previous,
    NoteConflictState next,
  ) {
    if (next.errorMessage != null &&
        next.errorMessage != previous?.errorMessage) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
    }

    if (!next.isResolved || previous?.isResolved == true) return;

    notifier.clearResolved();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.go('${AppConstants.noteDetailRoute}/$localId');
    });
  }
}
