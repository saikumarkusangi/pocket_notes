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
    final localCard = ConflictVersionCard(
      title: 'Your Version',
      noteTitle: note.title,
      noteBody: note.body,
      updatedAt: note.updatedAt,
      type: 'quickNotes',
    );
    final remoteCard = ConflictVersionCard(
      title: 'Cloud Version',
      noteTitle: note.conflictRemoteTitle ?? '',
      noteBody: note.conflictRemoteBody ?? '',
      updatedAt: note.conflictRemoteUpdatedAt,
      type: 'quickNotes',
    );

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sync_problem_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Sync Conflict',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'This note was modified on both your device and the cloud. Choose which version you would like to keep.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(padding: const EdgeInsets.all(8.0), child: localCard),
                const SizedBox(height: 16),
                Padding(padding: const EdgeInsets.all(8.0), child: remoteCard),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isResolving ? null : onKeepRemote,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Use Cloud Version'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isResolving ? null : onKeepLocal,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    elevation: 0,
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isResolving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Use Local Version'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
