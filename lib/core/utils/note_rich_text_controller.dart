import 'package:flutter/material.dart';
import 'package:pocket_notes/core/utils/note_char_style.dart';
import 'package:pocket_notes/core/utils/note_text_formatter.dart';

/// Edits plain note text while tracking per-character styles separately.
///
/// Serialized marker syntax is produced on save via [serializedBody].
class NoteRichTextController extends TextEditingController {
  NoteRichTextController({String serialized = ''}) : super(text: '') {
    if (serialized.isNotEmpty) {
      loadSerialized(serialized);
    }
  }

  List<NoteCharStyle> _charStyles = [];

  List<NoteCharStyle> get charStyles => List.unmodifiable(_charStyles);

  String get serializedBody =>
      NoteFormattedText.serialize(text, _charStyles);

  void loadSerialized(String serialized) {
    final document = NoteFormattedText.deserialize(serialized);
    _charStyles = document.styles;
    super.value = TextEditingValue(
      text: document.plainText,
      selection: TextSelection.collapsed(
        offset: document.plainText.length,
      ),
    );
    _ensureStylesLength();
    notifyListeners();
  }

  @override
  set value(TextEditingValue newValue) {
    final oldText = text;
    final newText = newValue.text;
    if (oldText != newText) {
      _applyTextEditToStyles(oldText, newText);
    }
    super.value = newValue;
    _ensureStylesLength();
  }

  void _ensureStylesLength() {
    while (_charStyles.length < text.length) {
      _charStyles.add(const NoteCharStyle());
    }
    if (_charStyles.length > text.length) {
      _charStyles.removeRange(text.length, _charStyles.length);
    }
  }

  void _applyTextEditToStyles(String oldText, String newText) {
    var prefixLen = 0;
    final maxPrefix = oldText.length < newText.length
        ? oldText.length
        : newText.length;
    while (prefixLen < maxPrefix &&
        oldText.codeUnitAt(prefixLen) == newText.codeUnitAt(prefixLen)) {
      prefixLen++;
    }

    var oldSuffix = oldText.length - prefixLen;
    var newSuffix = newText.length - prefixLen;
    while (oldSuffix > 0 &&
        newSuffix > 0 &&
        oldText.codeUnitAt(oldText.length - oldSuffix) ==
            newText.codeUnitAt(newText.length - newSuffix)) {
      oldSuffix--;
      newSuffix--;
    }

    final deleteStart = prefixLen;
    final deleteEnd = oldText.length - oldSuffix;
    final inserted = newText.substring(prefixLen, newText.length - newSuffix);

    final inherit = deleteStart > 0 && _charStyles.isNotEmpty
        ? _charStyles[deleteStart - 1]
        : const NoteCharStyle();

    if (deleteStart < _charStyles.length) {
      final removeEnd = deleteEnd.clamp(0, _charStyles.length);
      if (deleteStart < removeEnd) {
        _charStyles.removeRange(deleteStart, removeEnd);
      }
    }

    _charStyles.insertAll(
      deleteStart,
      List.generate(inserted.length, (_) => inherit),
    );
  }

  bool get hasSelection {
    final current = selection;
    return current.isValid && !current.isCollapsed;
  }

  void toggleBold() => _toggleFlag((style) => style.bold, (style, value) {
    return style.copyWith(bold: value);
  });

  void toggleItalic() => _toggleFlag((style) => style.italic, (style, value) {
    return style.copyWith(italic: value);
  });

  void applyTextColor(Color color) {
    _applyToSelection((style) => style.copyWith(textColor: color));
  }

  void applyHighlight(Color color) {
    _applyToSelection((style) => style.copyWith(highlightColor: color));
  }

  void applyNumberedList() {
    final current = selection;
    if (!current.isValid || current.isCollapsed) return;

    final selected = text.substring(current.start, current.end);
    final lines = selected.split('\n');
    final numbered = lines
        .asMap()
        .entries
        .map((entry) => '${entry.key + 1}. ${entry.value}')
        .join('\n');

    final newText = text.replaceRange(current.start, current.end, numbered);
    value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: current.start,
        extentOffset: current.start + numbered.length,
      ),
    );
  }

  void _toggleFlag(
    bool Function(NoteCharStyle style) read,
    NoteCharStyle Function(NoteCharStyle style, bool value) write,
  ) {
    final range = _selectedRange();
    if (range == null) return;

    final allEnabled = _charStyles
        .sublist(range.start, range.end)
        .every(read);
    final nextValue = !allEnabled;

    for (var i = range.start; i < range.end; i++) {
      _charStyles[i] = write(_charStyles[i], nextValue);
    }
    notifyListeners();
  }

  void _applyToSelection(
    NoteCharStyle Function(NoteCharStyle style) transform,
  ) {
    final range = _selectedRange();
    if (range == null) return;

    for (var i = range.start; i < range.end; i++) {
      _charStyles[i] = transform(_charStyles[i]);
    }
    notifyListeners();
  }

  ({int start, int end})? _selectedRange() {
    final current = selection;
    if (!current.isValid || current.isCollapsed) return null;
    return (start: current.start, end: current.end);
  }
}
