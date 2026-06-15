import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';

class OfflineNotesBanner extends StatelessWidget {
  const OfflineNotesBanner({
    super.key,
    this.isSyncing = false,
    this.lastSyncedAt,
  });

  final bool isSyncing;
  final DateTime? lastSyncedAt;

  String get _message {
    if (isSyncing) {
      return 'Syncing notes…';
    }

    if (lastSyncedAt != null) {
      final local = lastSyncedAt!.toLocal();
      final time =
          '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
      return 'Offline — showing notes saved on this device (last synced $time)';
    }

    return 'Offline — showing notes saved on this device';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.gray.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSyncing ? Icons.sync : Icons.cloud_off_outlined,
              size: 18,
              color: AppColors.gray,
            ),
            const SizedBox(width: 10),
            Text(
              _message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.gray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
