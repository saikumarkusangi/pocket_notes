import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/features/notes/data/models/note_model.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_sync_status_badge.dart';

class TodoListCard extends StatelessWidget {
  const TodoListCard({super.key, required this.note, this.onTap});

  final NoteModel note;
  final VoidCallback? onTap;

  static const _previewLimit = 3;

  @override
  Widget build(BuildContext context) {
    final total = note.itemCount;
    final completed = note.completedItemCount;
    final progress = total == 0 ? 0.0 : completed / total;
    final previewItems = note.lineItems.take(_previewLimit).toList();
    final remaining = note.lineItems.length - previewItems.length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              note.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                            ),
                          ),

                          NoteSyncStatusBadge(status: note.syncStatus),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: Colors.green.shade50,
                          color: Colors.green.shade400,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$completed/$total',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      for (var i = 0; i < previewItems.length; i++)
                        _TodoPreviewRow(
                          label: previewItems[i],
                          isCompleted: _isItemCompleted(note, i),
                        ),
                      if (remaining > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 34),
                          child: Text(
                            '+ $remaining more tasks',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.gray),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isItemCompleted(NoteModel note, int index) {
    final lines = note.body
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (index >= lines.length) return false;
    final line = lines[index];
    return line.startsWith('[x] ') || line.startsWith('[X] ');
  }
}

class _TodoPreviewRow extends StatelessWidget {
  const _TodoPreviewRow({required this.label, required this.isCompleted});

  final String label;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green.shade400 : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isCompleted ? Colors.green.shade400 : AppColors.gray,
                width: 1.5,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 14, color: AppColors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isCompleted ? Colors.green.shade700 : AppColors.text,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                decorationColor: isCompleted ? Colors.black : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
