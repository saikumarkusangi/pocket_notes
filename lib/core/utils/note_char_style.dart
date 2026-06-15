import 'package:flutter/material.dart';

/// Per-character formatting applied to journal note body text.
class NoteCharStyle {
  const NoteCharStyle({
    this.bold = false,
    this.italic = false,
    this.textColor,
    this.highlightColor,
  });

  final bool bold;
  final bool italic;
  final Color? textColor;
  final Color? highlightColor;

  bool get hasFormatting =>
      bold || italic || textColor != null || highlightColor != null;

  NoteCharStyle copyWith({
    bool? bold,
    bool? italic,
    Color? textColor,
    Color? highlightColor,
    bool clearTextColor = false,
    bool clearHighlightColor = false,
  }) {
    return NoteCharStyle(
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      textColor: clearTextColor ? null : (textColor ?? this.textColor),
      highlightColor:
          clearHighlightColor ? null : (highlightColor ?? this.highlightColor),
    );
  }

  bool sameAs(NoteCharStyle other) {
    return bold == other.bold &&
        italic == other.italic &&
        textColor == other.textColor &&
        highlightColor == other.highlightColor;
  }
}
