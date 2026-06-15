import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';

class NoteEditorToolbar extends StatelessWidget {
  const NoteEditorToolbar({
    super.key,
    this.onCameraTap,
    this.onDrawTap,
    this.onAttachTap,
    this.onListTap,
    this.onAddTap,
  });

  final VoidCallback? onCameraTap;
  final VoidCallback? onDrawTap;
  final VoidCallback? onAttachTap;
  final VoidCallback? onListTap;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.noteToolbarBackground,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ToolbarIcon(
                    icon: Icons.photo_camera_outlined,
                    onTap: onCameraTap,
                  ),
                  _ToolbarIcon(
                    icon: Icons.edit_outlined,
                    onTap: onDrawTap,
                  ),
                  _ToolbarIcon(
                    icon: Icons.attach_file,
                    onTap: onAttachTap,
                  ),
                  _ToolbarIcon(
                    icon: Icons.format_list_numbered,
                    onTap: onListTap,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 56,
            height: 56,
            child: FilledButton(
              onPressed: onAddTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.card,
                foregroundColor: AppColors.white,
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
                elevation: 0,
              ),
              child: const Icon(Icons.add, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarIcon extends StatelessWidget {
  const _ToolbarIcon({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.text, size: 24),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}
