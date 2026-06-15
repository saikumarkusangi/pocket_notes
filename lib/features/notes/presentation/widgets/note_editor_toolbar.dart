import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/core/utils/note_rich_text_controller.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_format_color_sheet.dart';

class NoteEditorToolbar extends StatelessWidget {
  const NoteEditorToolbar({
    super.key,
    required this.controller,
    this.onListTap,
    this.onAddTap,
    this.actionButtonColor = AppColors.card,
  });

  final NoteRichTextController controller;
  final VoidCallback? onListTap;
  final VoidCallback? onAddTap;
  final Color actionButtonColor;

  void _requireSelection(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Select some text in your note first.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _applyOrHint(
    BuildContext context,
    VoidCallback action,
  ) {
    if (!controller.hasSelection) {
      _requireSelection(context);
      return;
    }
    action();
  }

  void _showTextColorPicker(BuildContext context) {
    if (!controller.hasSelection) {
      _requireSelection(context);
      return;
    }

    NoteFormatColorSheet.show(
      context: context,
      title: 'Text color',
      colors: NoteFormatColorSheet.textColors,
      onColorSelected: controller.applyTextColor,
    );
  }

  void _showHighlightPicker(BuildContext context) {
    if (!controller.hasSelection) {
      _requireSelection(context);
      return;
    }

    NoteFormatColorSheet.show(
      context: context,
      title: 'Highlighter',
      colors: NoteFormatColorSheet.highlightColors,
      onColorSelected: controller.applyHighlight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.noteToolbarBackground,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ToolbarIcon(
                    icon: Icons.format_bold,
                    tooltip: 'Bold',
                    onTap: () => _applyOrHint(context, controller.toggleBold),
                  ),
                  _ToolbarIcon(
                    icon: Icons.format_italic,
                    tooltip: 'Italic',
                    onTap: () =>
                        _applyOrHint(context, controller.toggleItalic),
                  ),
                  _ToolbarIcon(
                    icon: Icons.format_color_text,
                    tooltip: 'Text color',
                    onTap: () => _showTextColorPicker(context),
                  ),
                  _ToolbarIcon(
                    icon: Icons.border_color,
                    tooltip: 'Highlighter',
                    onTap: () => _showHighlightPicker(context),
                  ),
                  _ToolbarIcon(
                    icon: Icons.format_list_numbered,
                    tooltip: 'Numbered list',
                    onTap: () => _applyOrHint(
                      context,
                      () {
                        if (onListTap != null) {
                          onListTap!();
                        } else {
                          controller.applyNumberedList();
                        }
                      },
                    ),
                  ),
                ],
              ),
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
    required this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(icon, color: AppColors.text, size: 22),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}
