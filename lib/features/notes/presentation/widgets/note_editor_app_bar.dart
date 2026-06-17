import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';

class NoteEditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NoteEditorAppBar({
    super.key,
    this.appBarColor = AppColors.primary,
    this.actionButtonTap,
    this.actionButtonText,
    this.secondaryActionButtonTap,
    this.secondaryActionButtonText,
  });

  final Color appBarColor;
  final VoidCallback? actionButtonTap;
  final String? actionButtonText;
  final VoidCallback? secondaryActionButtonTap;
  final String? secondaryActionButtonText;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: appBarColor,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: IconButton.styleFrom(),
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.text),
          ),
        ),
        actions: [
          if (actionButtonText != null && actionButtonText!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: actionButtonText == 'Delete'
                      ? Colors.red.shade400
                      : actionButtonText == 'Resolve'
                      ? Colors.green.shade400
                      : Colors.white,
                  foregroundColor: actionButtonText == 'Delete'
                      ? AppColors.white
                      : actionButtonText == 'Resolve'
                      ? AppColors.white
                      : AppColors.text,
                  textStyle: Theme.of(context).textTheme.bodyMedium,
                ),
                onPressed: actionButtonTap,
                child: Text(actionButtonText!),
              ),
            ),
          if (secondaryActionButtonText != null &&
              secondaryActionButtonText!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.white,
                  side: BorderSide(
                    color: AppColors.gray.withValues(alpha: 0.2),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: secondaryActionButtonTap,
                child: Text(secondaryActionButtonText!),
              ),
            ),
        ],
      ),
    );
  }
}
