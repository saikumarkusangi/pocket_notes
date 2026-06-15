import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';

class ConflictVersionCard extends StatelessWidget {
  const ConflictVersionCard({
    super.key,
    required this.title,
    required this.noteTitle,
    required this.noteBody,
    this.updatedAt,
  });

  final String title;
  final String noteTitle;
  final String noteBody;
  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.light),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (updatedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Updated ${updatedAt!.toLocal()}',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.gray),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            noteTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                noteBody,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
