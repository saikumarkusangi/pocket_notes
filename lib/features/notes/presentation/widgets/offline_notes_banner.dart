import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/core/utils/date_formats.dart';

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
      final formattedTime = DateFormats.formatTime(local);
      return 'Offline — last synced $formattedTime';
    }

    return 'Offline — showing notes saved on this device';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSyncing ? AppColors.gray.withValues(alpha: 0.1) : Colors.red,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSyncing ? Icons.sync : Icons.cloud_off_outlined,
              size: 18,
              color: isSyncing ? AppColors.gray : AppColors.white,
            ),
            const SizedBox(width: 10),
            Text(
              _message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSyncing ? AppColors.gray : AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
