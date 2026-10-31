import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/core/utils/date_formats.dart';
import 'package:pocket_notes/core/utils/note_rich_text_controller.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/formatted_note_body_field.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_editor_toolbar.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_link_text.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_title_field.dart';

class JournalNoteEditor extends StatelessWidget {
  const JournalNoteEditor({
    super.key,
    required this.titleController,
    required this.bodyController,
    this.titleHint = 'Journal title',
    this.bodyHint = 'Tap here to continue',
    this.autofocusBody = false,
    this.onSave,
    this.actionButtonColor = AppColors.card,
    this.date,
    this.isLoading = false,
    this.isReadOnly = false,
  });

  final TextEditingController titleController;
  final NoteRichTextController bodyController;
  final String titleHint;
  final String bodyHint;
  final bool autofocusBody;
  final VoidCallback? onSave;
  final Color actionButtonColor;
  final DateTime? date;
  final bool isLoading;
  final bool isReadOnly;
  @override
  Widget build(BuildContext context) {
    final date = this.date ?? DateTime.now();
    final formattedDate = DateFormats.formatDate(date);
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(text: formattedDate),
                          TextSpan(
                            text: '  •  ${DateFormats.formatTime(date)}',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: AppColors.gray,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    IgnorePointer(
                      ignoring: isReadOnly,
                      child: NoteTitleField(
                        controller: titleController,
                        hintText: titleHint,
                        readOnly: isReadOnly,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isReadOnly)
                      _JournalReadOnlyBody(controller: bodyController)
                    else
                      FormattedNoteBodyField(
                        controller: bodyController,
                        hintText: bodyHint,
                        autofocus: autofocusBody,
                      ),
                  ],
                ),
              ),
            ),
            if (!isReadOnly) ...[
              NoteEditorToolbar(
                controller: bodyController,
                onAddTap: onSave,
                actionButtonColor: actionButtonColor,
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
        if(isLoading) Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black12,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _JournalReadOnlyBody extends StatelessWidget {
  const _JournalReadOnlyBody({required this.controller});

  final NoteRichTextController controller;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge!.copyWith(
      color: AppColors.text,
      height: 1.6,
      fontSize: 16,
    );
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final serialized = controller.serializedBody.trim();
        if (serialized.isEmpty) {
          return Text(
            'No content yet',
            style: style.copyWith(color: AppColors.gray),
          );
        }
        return NoteLinkText(
          text: controller.serializedBody,
          formatted: true,
          style: style,
        );
      },
    );
  }
}
