import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/features/notes/data/models/note_model.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_link_text.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_sync_status_badge.dart';

class ShoppingListCard extends StatelessWidget {
  const ShoppingListCard({super.key, required this.note, this.onTap});

  final NoteModel note;
  final VoidCallback? onTap;

  static const _previewLimit = 3;

  @override
  Widget build(BuildContext context) {
    final items = note.lineItems;
    final previewItems = items.take(_previewLimit).toList();
    final remaining = items.length - previewItems.length;
    final remainingCount = note.remainingItemCount;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.orange.shade800,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$remainingCount left',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  NoteSyncStatusBadge(status: note.syncStatus, showText: false),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                children: [
                  for (var i = 0; i < previewItems.length; i++)
                    _ChecklistPreviewRow(
                      label: previewItems[i],
                      isCompleted: _isItemCompleted(note, i),
                    ),
                  if (remaining > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 36),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '+ $remaining more items',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.gray),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
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

class _ChecklistPreviewRow extends StatelessWidget {
  const _ChecklistPreviewRow({required this.label, required this.isCompleted});

  final String label;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: isCompleted ? Colors.orange : AppColors.gray,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: NoteLinkText(
              text: label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isCompleted ? AppColors.gray : AppColors.text,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
