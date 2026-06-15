import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/core/utils/note_rich_text_controller.dart';
import 'package:pocket_notes/core/utils/note_text_formatter.dart';

/// Note body field that renders stacked inline formatting while editing.
class FormattedNoteBodyField extends StatelessWidget {
  const FormattedNoteBodyField({
    super.key,
    required this.controller,
    this.hintText = 'Write your note here...',
    this.autofocus = false,
  });

  final NoteRichTextController controller;
  final String hintText;
  final bool autofocus;

  TextStyle _bodyStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
      color: AppColors.text,
      height: 1.6,
      fontSize: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _bodyStyle(context);
    final hintStyle = style.copyWith(color: AppColors.gray);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final text = controller.text;

        return Stack(
          alignment: Alignment.topLeft,
          children: [
            if (text.isNotEmpty)
              IgnorePointer(
                child: Text.rich(
                  NoteFormattedText.buildFromStyles(
                    text,
                    controller.charStyles,
                    style: style,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            TextField(
              controller: controller,
              autofocus: autofocus,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              cursorColor: AppColors.text,
              style: style.copyWith(
                color: Colors.transparent,
                decorationColor: Colors.transparent,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: hintStyle,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ],
        );
      },
    );
  }
}
