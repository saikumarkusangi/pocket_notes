import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/features/notes/data/models/note_category.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/note_title_field.dart';

class ChecklistNoteEditor extends StatefulWidget {
  const ChecklistNoteEditor({
    super.key,
    required this.category,
    required this.titleController,
    required this.bodyController,
    this.autofocusBody = false,
    this.onSave,
  });

  final NoteCategory category;
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final bool autofocusBody;
  final VoidCallback? onSave;

  @override
  State<ChecklistNoteEditor> createState() => _ChecklistNoteEditorState();
}

class _ChecklistNoteEditorState extends State<ChecklistNoteEditor> {
  late final List<TextEditingController> _itemControllers;
  late final List<bool> _completed;
  final _newItemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final parsed = _parseItems(widget.bodyController.text);
    _itemControllers = parsed
        .map((item) => TextEditingController(text: item.text))
        .toList();
    _completed = parsed.map((item) => item.isCompleted).toList();

    if (_itemControllers.isEmpty) {
      _itemControllers.add(TextEditingController());
      _completed.add(false);
    }

    for (final controller in _itemControllers) {
      controller.addListener(_syncBody);
    }
  }

  @override
  void dispose() {
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    _newItemController.dispose();
    super.dispose();
  }

  List<_ChecklistItem> _parseItems(String body) {
    return body
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) {
          if (line.startsWith('[x] ') || line.startsWith('[X] ')) {
            return _ChecklistItem(text: line.substring(4), isCompleted: true);
          }
          if (line.startsWith('[ ] ')) {
            return _ChecklistItem(text: line.substring(4), isCompleted: false);
          }
          return _ChecklistItem(text: line, isCompleted: false);
        })
        .toList();
  }

  void _syncBody() {
    final lines = <String>[];
    for (var i = 0; i < _itemControllers.length; i++) {
      final text = _itemControllers[i].text.trim();
      if (text.isEmpty) continue;
      lines.add(_completed[i] ? '[x] $text' : '[ ] $text');
    }
    widget.bodyController.text = lines.join('\n');
  }

  void _toggleItem(int index) {
    setState(() {
      _completed[index] = !_completed[index];
      _syncBody();
    });
  }

  void _addItem() {
    final text = _newItemController.text.trim();
    if (text.isEmpty) return;
    final controller = TextEditingController(text: text)
      ..addListener(_syncBody);
    setState(() {
      _itemControllers.add(controller);
      _completed.add(false);
      _newItemController.clear();
      _syncBody();
    });
  }

  void _removeItem(int index) {
    _itemControllers[index].dispose();
    setState(() {
      _itemControllers.removeAt(index);
      _completed.removeAt(index);
      if (_itemControllers.isEmpty) {
        final controller = TextEditingController()..addListener(_syncBody);
        _itemControllers.add(controller);
        _completed.add(false);
      }
      _syncBody();
    });
  }

  Color get _accentColor {
    return widget.category == NoteCategory.shoppingList
        ? Colors.orange.shade400
        : Colors.green.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final isShopping = widget.category == NoteCategory.shoppingList;
    final itemHint = isShopping ? 'Add an item' : 'Add a task';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NoteTitleField(
                  controller: widget.titleController,
                  hintText: widget.category.createTitleHint,
                ),
                const SizedBox(height: 20),
                ...List.generate(_itemControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => _toggleItem(index),
                          borderRadius: BorderRadius.circular(20),
                          child: Icon(
                            _completed[index]
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: _completed[index]
                                ? _accentColor
                                : AppColors.gray,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _itemControllers[index],
                            autofocus: widget.autofocusBody && index == 0,
                            decoration: InputDecoration(
                              hintText: itemHint,
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  decoration: _completed[index]
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: _completed[index]
                                      ? Colors.grey.shade500
                                      : AppColors.text,
                                  decorationColor: Colors.grey.shade800,
                                ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeItem(index),
                          icon: const Icon(Icons.close, size: 18),
                          color: AppColors.gray,
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: _accentColor,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _newItemController,
                        onSubmitted: (_) => _addItem(),
                        decoration: InputDecoration(
                          hintText: itemHint,
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: AppColors.text),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: _accentColor,
                        textStyle: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      onPressed: _addItem,
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (widget.onSave != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: widget.onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: widget.category.actionButtonColor,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(isShopping ? 'Save list' : 'Save tasks'),
              ),
            ),
          ),
      ],
    );
  }
}

class _ChecklistItem {
  const _ChecklistItem({required this.text, required this.isCompleted});

  final String text;
  final bool isCompleted;
}
