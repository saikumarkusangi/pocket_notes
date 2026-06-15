import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';

class LogoutDialog extends ConsumerWidget {
  const LogoutDialog({super.key, required this.onConfirm});
  final Function() onConfirm;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gray.withValues(alpha: 0.2)),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      title: Text(
        'Confirm Logout',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
      content: Text(
        'Are you sure you want to logout? \nDon\'t worry your notes are safe with us.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.text),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            minimumSize: const Size(100, 40),
            maximumSize: const Size(100, 40),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: AppColors.gray.withValues(alpha: 0.2)),
          ),
          child: Text(
            'Cancel',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.text),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            foregroundColor: AppColors.white,
            minimumSize: const Size(100, 40),
            maximumSize: const Size(100, 40),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: AppColors.gray.withValues(alpha: 0.2)),
          ),
          child: Text(
            'Logout',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.white),
          ),
        ),
      ],
    );
  }
}
