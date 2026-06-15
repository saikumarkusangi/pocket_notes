import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';

class NotesListAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NotesListAppBar({super.key, required this.title, this.onSortTap});

  final String title;
  final VoidCallback? onSortTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.notesListBackground,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: AppBar(
        backgroundColor: AppColors.notesListBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     onPressed: onSortTap,
        //     icon: const Icon(Icons.swap_vert, color: AppColors.text),
        //   ),
        // ],
      ),
    );
  }
}
