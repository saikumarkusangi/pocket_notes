import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';

class NoteNewEntryButton extends StatelessWidget {
  const NoteNewEntryButton({
    super.key,
    required this.onPressed,
    this.label = 'Start a new entry',
    this.backgroundColor = AppColors.card,
  });

  final VoidCallback onPressed;
  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
