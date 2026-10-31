import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pocket_notes/core/utils/note_char_style.dart';
import 'package:pocket_notes/core/utils/note_links.dart';

/// Parses, serializes, and renders journal note formatting markers.
class NoteFormattedText {
  NoteFormattedText._();

  static final _patterns = <_FormatPattern>[
    _FormatPattern(
      RegExp(r'<c:([0-9A-Fa-f]{6})>(.*?)</c>', dotAll: true),
      (match, base, recognizeLink) {
        final color = Color(int.parse('FF${match.group(1)!}', radix: 16));
        final innerStyle = base?.copyWith(color: color);
        return TextSpan(
          style: innerStyle,
          children: _parseNodes(
            match.group(2)!,
            innerStyle,
            recognizeLink: recognizeLink,
          ),
        );
      },
      (style, match) => style.copyWith(
        textColor: Color(int.parse('FF${match.group(1)!}', radix: 16)),
      ),
      groupIndex: 2,
    ),
    _FormatPattern(
      RegExp(r'<h:([0-9A-Fa-f]{6})>(.*?)</h>', dotAll: true),
      (match, base, recognizeLink) {
        final color = Color(int.parse('FF${match.group(1)!}', radix: 16));
        final innerStyle = base?.copyWith(
          backgroundColor: color.withValues(alpha: 0.45),
        );
        return TextSpan(
          style: innerStyle,
          children: _parseNodes(
            match.group(2)!,
            innerStyle,
            recognizeLink: recognizeLink,
          ),
        );
      },
      (style, match) => style.copyWith(
        highlightColor: Color(int.parse('FF${match.group(1)!}', radix: 16)),
      ),
      groupIndex: 2,
    ),
    _FormatPattern(
      RegExp(r'\*\*(.*?)\*\*', dotAll: true),
      (match, base, recognizeLink) {
        final innerStyle = base?.copyWith(fontWeight: FontWeight.w700);
        return TextSpan(
          style: innerStyle,
          children: _parseNodes(
            match.group(1)!,
            innerStyle,
            recognizeLink: recognizeLink,
          ),
        );
      },
      (style, _) => style.copyWith(bold: true),
      groupIndex: 1,
    ),
    _FormatPattern(
      RegExp(r'_(.*?)_', dotAll: true),
      (match, base, recognizeLink) {
        final innerStyle = base?.copyWith(fontStyle: FontStyle.italic);
        return TextSpan(
          style: innerStyle,
          children: _parseNodes(
            match.group(1)!,
            innerStyle,
            recognizeLink: recognizeLink,
          ),
        );
      },
      (style, _) => style.copyWith(italic: true),
      groupIndex: 1,
    ),
  ];

  static bool _openLinksOnTap = false;

  static TextSpan parse(
    String text, {
    TextStyle? style,
    GestureRecognizer? Function(String url)? recognizeLink,
    bool openOnTap = false,
  }) {
    final previousOpenOnTap = _openLinksOnTap;
    _openLinksOnTap = openOnTap;
    try {
      return TextSpan(
        style: style,
        children: _parseNodes(text, style, recognizeLink: recognizeLink),
      );
    } finally {
      _openLinksOnTap = previousOpenOnTap;
    }
  }

  static TextSpan buildFromStyles(
    String plain,
    List<NoteCharStyle> styles, {
    TextStyle? style,
  }) {
    if (plain.isEmpty) {
      return TextSpan(style: style, text: '');
    }

    final children = <InlineSpan>[];
    var runStart = 0;

    for (var i = 1; i <= plain.length; i++) {
      final isRunEnd =
          i == plain.length ||
          !_styleAt(styles, i).sameAs(_styleAt(styles, runStart));
      if (!isRunEnd) continue;

      final chunk = plain.substring(runStart, i);
      final charStyle = _styleAt(styles, runStart);
      children.addAll(
        NoteLinks.buildSpans(chunk, _toTextStyle(style, charStyle)),
      );
      runStart = i;
    }

    return TextSpan(style: style, children: children);
  }

  static String serialize(String plain, List<NoteCharStyle> styles) {
    if (plain.isEmpty) return '';

    final buffer = StringBuffer();
    var runStart = 0;

    for (var i = 1; i <= plain.length; i++) {
      final isRunEnd =
          i == plain.length ||
          !_styleAt(styles, i).sameAs(_styleAt(styles, runStart));
      if (!isRunEnd) continue;

      var chunk = plain.substring(runStart, i);
      chunk = _wrapChunk(chunk, _styleAt(styles, runStart));
      buffer.write(chunk);
      runStart = i;
    }

    return buffer.toString();
  }

  static ({String plainText, List<NoteCharStyle> styles}) deserialize(
    String serialized,
  ) {
    final plain = StringBuffer();
    final styles = <NoteCharStyle>[];
    _deserializePart(serialized, const NoteCharStyle(), plain, styles);
    return (plainText: plain.toString(), styles: styles);
  }

  /// Returns plain text with formatting markers removed.
  static String stripMarkers(String text) {
    return deserialize(text).plainText;
  }

  static List<InlineSpan> _parseNodes(
    String text,
    TextStyle? style, {
    GestureRecognizer? Function(String url)? recognizeLink,
  }) {
    if (text.isEmpty) return [const TextSpan(text: '')];
    final match = _findEarliestMatch(text);
    if (match == null) {
      return NoteLinks.buildSpans(
        text,
        style,
        recognizeLink: recognizeLink,
        openOnTap: _openLinksOnTap,
      );
    }
    final before = text.substring(0, match.start);
    final after = text.substring(match.end);
    return [
      if (before.isNotEmpty)
        ...NoteLinks.buildSpans(
          before,
          style,
          recognizeLink: recognizeLink,
          openOnTap: _openLinksOnTap,
        ),
      match.builder(match.match, style, recognizeLink),
      ..._parseNodes(after, style, recognizeLink: recognizeLink),
    ];
  }

  static void _deserializePart(
    String input,
    NoteCharStyle style,
    StringBuffer plain,
    List<NoteCharStyle> styles,
  ) {
    var remaining = input;
    while (remaining.isNotEmpty) {
      final match = _findEarliestMatch(remaining);
      if (match == null) {
        _appendChars(remaining, style, plain, styles);
        return;
      }

      final before = remaining.substring(0, match.start);
      if (before.isNotEmpty) {
        _appendChars(before, style, plain, styles);
      }

      final childStyle = match.applyStyle(style, match.match);
      final inner = match.match.group(match.groupIndex)!;
      _deserializePart(inner, childStyle, plain, styles);
      remaining = remaining.substring(match.end);
    }
  }

  static void _appendChars(
    String chars,
    NoteCharStyle style,
    StringBuffer plain,
    List<NoteCharStyle> styles,
  ) {
    for (var i = 0; i < chars.length; i++) {
      plain.write(chars[i]);
      styles.add(style);
    }
  }

  static String _wrapChunk(String chunk, NoteCharStyle style) {
    if (style.highlightColor != null) {
      chunk = '<h:${_colorToHex(style.highlightColor!)}>$chunk</h>';
    }
    if (style.textColor != null) {
      chunk = '<c:${_colorToHex(style.textColor!)}>$chunk</c>';
    }
    if (style.bold) {
      chunk = '**$chunk**';
    }
    if (style.italic) {
      chunk = '_${chunk}_';
    }
    return chunk;
  }

  static TextStyle? _toTextStyle(TextStyle? base, NoteCharStyle style) {
    return base?.copyWith(
      fontWeight: style.bold ? FontWeight.w700 : base.fontWeight,
      fontStyle: style.italic ? FontStyle.italic : base.fontStyle,
      color: style.textColor ?? base.color,
      backgroundColor: style.highlightColor != null
          ? style.highlightColor!.withValues(alpha: 0.45)
          : base.backgroundColor,
    );
  }

  static NoteCharStyle _styleAt(List<NoteCharStyle> styles, int index) {
    if (index < 0 || index >= styles.length) {
      return const NoteCharStyle();
    }
    return styles[index];
  }

  static String _colorToHex(Color color) {
    final value = color.toARGB32() & 0xFFFFFF;
    return value.toRadixString(16).padLeft(6, '0').toUpperCase();
  }

  static RegExpMatch? _firstMatchOutsideLink(String text, RegExp regex) {
    for (final match in regex.allMatches(text)) {
      if (!NoteLinks.isInsideLink(text, match.start, match.end)) return match;
    }
    return null;
  }

  static _FormatMatch? _findEarliestMatch(String text) {
    _FormatMatch? earliest;

    for (final pattern in _patterns) {
      final match = _firstMatchOutsideLink(text, pattern.regex);
      if (match == null) continue;
      final candidate = _FormatMatch(
        start: match.start,
        end: match.end,
        match: match,
        builder: pattern.builder,
        applyStyle: pattern.applyStyle,
        groupIndex: pattern.groupIndex,
      );
      if (earliest == null || candidate.start < earliest.start) {
        earliest = candidate;
      }
    }

    return earliest;
  }
}

class _FormatPattern {
  const _FormatPattern(
    this.regex,
    this.builder,
    this.applyStyle, {
    required this.groupIndex,
  });

  final RegExp regex;
  final TextSpan Function(
    RegExpMatch match,
    TextStyle? base,
    GestureRecognizer? Function(String url)? recognizeLink,
  )
  builder;
  final NoteCharStyle Function(NoteCharStyle style, RegExpMatch match)
  applyStyle;
  final int groupIndex;
}

class _FormatMatch {
  const _FormatMatch({
    required this.start,
    required this.end,
    required this.match,
    required this.builder,
    required this.applyStyle,
    required this.groupIndex,
  });

  final int start;
  final int end;
  final RegExpMatch match;
  final TextSpan Function(
    RegExpMatch match,
    TextStyle? base,
    GestureRecognizer? Function(String url)? recognizeLink,
  )
  builder;
  final NoteCharStyle Function(NoteCharStyle style, RegExpMatch match)
  applyStyle;
  final int groupIndex;
}
