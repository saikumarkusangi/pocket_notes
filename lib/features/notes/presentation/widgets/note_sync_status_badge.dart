import 'package:flutter/material.dart';
import 'package:pocket_notes/features/notes/data/models/note_sync_status.dart';

class NoteSyncStatusBadge extends StatelessWidget {
  const NoteSyncStatusBadge({
    super.key,
    required this.status,
    this.opacityValue = 0.12,
    this.showText = true,
  });

  final NoteSyncStatus status;
  final double opacityValue;
  final bool showText;
  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      NoteSyncStatus.synced => (
        Colors.green.shade600,
        Icons.cloud_done_outlined,
      ),
      NoteSyncStatus.pendingSync => (
        Colors.orange.shade700,
        Icons.cloud_upload_outlined,
      ),
      NoteSyncStatus.conflict => (
        Colors.red.shade700,
        Icons.warning_amber_rounded,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacityValue),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: opacityValue == 0.12 ? color : Colors.white,
          ),
          if (showText) const SizedBox(width: 4),
          if (showText)
            Text(
              status.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: opacityValue == 0.12 ? color : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
