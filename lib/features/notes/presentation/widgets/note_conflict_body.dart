import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/features/notes/data/models/note_model.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/conflict_version_card.dart';

class NoteConflictBody extends StatelessWidget {
  const NoteConflictBody({
    super.key,
    required this.note,
    required this.isResolving,
    required this.onKeepLocal,
    required this.onKeepRemote,
  });

  final NoteModel note;
  final bool isResolving;
  final VoidCallback onKeepLocal;
  final VoidCallback onKeepRemote;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sync conflict',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This note was changed on this device and on the server. '
            'Choose which version to keep.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ConflictVersionCard(
                    title: 'Your version',
                    noteTitle: note.title,
                    noteBody: note.body,
                    updatedAt: note.updatedAt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ConflictVersionCard(
                    title: 'Server version',
                    noteTitle: note.conflictRemoteTitle ?? '',
                    noteBody: note.conflictRemoteBody ?? '',
                    updatedAt: note.conflictRemoteUpdatedAt,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: isResolving ? null : onKeepLocal,
            child: const Text('Keep my version'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: isResolving ? null : onKeepRemote,
            child: const Text('Keep server version'),
          ),
        ],
      ),
    );
  }
}
