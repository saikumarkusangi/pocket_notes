import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';

class NotesListAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NotesListAppBar({
    super.key,
    required this.title,
    required this.appBarColor,
    this.listBackgroundColor = AppColors.white,
    this.onSortTap,
  });

  final String title;
  final Color appBarColor;
  final Color listBackgroundColor;
  final VoidCallback? onSortTap;

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
        title: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.text),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.gray.withValues(alpha: 0.1),
            height: 2,
          ),
        ),
      ),
    );
  }
}
