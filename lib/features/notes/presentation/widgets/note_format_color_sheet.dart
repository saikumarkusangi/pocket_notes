import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';

class NoteFormatColorSheet extends StatelessWidget {
  const NoteFormatColorSheet({
    super.key,
    required this.title,
    required this.colors,
    required this.onColorSelected,
  });

  final String title;
  final List<Color> colors;
  final ValueChanged<Color> onColorSelected;

  static const textColors = [
    Color(0xFF1A1A1A),
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFF8E24AA),
    Color(0xFFF4511E),
    Color(0xFF6D4C41),
  ];

  static const highlightColors = [
    Color(0xFFFFF59D),
    Color(0xFFFFCC80),
    Color(0xFFA5D6A7),
    Color(0xFF90CAF9),
    Color(0xFFF48FB1),
    Color(0xFFB39DDB),
    Color(0xFFE0E0E0),
    Color(0x00FFFFFF),
  ];

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<Color> colors,
    required ValueChanged<Color> onColorSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => NoteFormatColorSheet(
        title: title,
        colors: colors,
        onColorSelected: onColorSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors.map((color) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    onColorSelected(color);
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gray.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
