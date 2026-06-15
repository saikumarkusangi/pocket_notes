import 'package:flutter/material.dart';
import 'package:pocket_notes/core/utils/note_rich_text_controller.dart';
import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/presentation/state/create_note_editor_state.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/checklist_note_editor.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/journal_note_editor.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/quick_note_editor.dart';

class CreateNoteEditorBody extends StatefulWidget {
  const CreateNoteEditorBody({
    super.key,
    required this.state,
    required this.onTitleChanged,
    required this.onBodyChanged,
    required this.onSave,
  });

  final CreateNoteEditorState state;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onBodyChanged;
  final VoidCallback? onSave;

  @override
  State<CreateNoteEditorBody> createState() => _CreateNoteEditorBodyState();
}

class _CreateNoteEditorBodyState extends State<CreateNoteEditorBody> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.state.title);
    _bodyController = _createBodyController(widget.state.category, widget.state.body);
    _titleController.addListener(_onTitleChanged);
    _bodyController.addListener(_onBodyChanged);
  }

  TextEditingController _createBodyController(
    NoteCategory category,
    String body,
  ) {
    if (category == NoteCategory.journal) {
      return NoteRichTextController(serialized: body);
    }
    return TextEditingController(text: body);
  }

  String get _bodyValue {
    final controller = _bodyController;
    if (controller is NoteRichTextController) {
      return controller.serializedBody;
    }
    return controller.text;
  }

  void _onTitleChanged() => widget.onTitleChanged(_titleController.text);
  void _onBodyChanged() => widget.onBodyChanged(_bodyValue);

  @override
  void dispose() {
    _titleController
      ..removeListener(_onTitleChanged)
      ..dispose();
    _bodyController
      ..removeListener(_onBodyChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.state.category;
    final actionColor = category.actionButtonColor;

    return switch (category) {
      NoteCategory.journal => JournalNoteEditor(
        titleController: _titleController,
        bodyController: _bodyController as NoteRichTextController,
        titleHint: category.createTitleHint,
        bodyHint: category.createBodyHint,
        autofocusBody: true,
        onSave: widget.onSave,
        actionButtonColor: actionColor,
        isLoading: widget.state.isSaving,
      ),
      NoteCategory.quickNotes => QuickNoteEditor(
        titleController: _titleController,
        bodyController: _bodyController,
        titleHint: category.createTitleHint,
        bodyHint: category.createBodyHint,
        autofocusBody: true,
        actionButtonColor: actionColor,
      ),
      NoteCategory.shoppingList || NoteCategory.todoList => ChecklistNoteEditor(
        category: category,
        titleController: _titleController,
        bodyController: _bodyController,
        autofocusBody: true,
        onSave: widget.onSave,
      ),
    };
  }
}
