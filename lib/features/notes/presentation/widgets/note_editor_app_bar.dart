import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';

class NoteEditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NoteEditorAppBar({
    super.key,
    this.onMenuTap,
  });

  final VoidCallback? onMenuTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.noteEditorBackground,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: AppBar(
        backgroundColor: AppColors.noteEditorBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.white.withValues(alpha: 0.6),
            ),
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: onMenuTap,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.white.withValues(alpha: 0.6),
              ),
              icon: const Icon(Icons.menu, color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }
}
