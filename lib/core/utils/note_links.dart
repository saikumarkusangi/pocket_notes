import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A slice of note text, with [url] set when the slice is a web link.
class NoteLinkSegment {
  const NoteLinkSegment({
    required this.text,
    required this.start,
    required this.end,
    this.url,
  });

  final String text;
  final int start;
  final int end;
  final String? url;
}

/// Finds web addresses in note text and opens them.
class NoteLinks {
  NoteLinks._();

  static const Color linkColor = Color(0xFF1565C0);
  static const double hitOutset = 4;

  static final RegExp _urlPattern = RegExp(
    r'(?:(?:https?:\/\/)|(?:www\.))[^\s<>]+',
    caseSensitive: false,
  );
  static final RegExp _trailingPunctuation = RegExp(r'[.,;:!?)\]]+$');

  static List<NoteLinkSegment> split(String text) {
    if (text.isEmpty) return const [];
    final segments = <NoteLinkSegment>[];
    var cursor = 0;
    for (final match in _urlPattern.allMatches(text)) {
      final visible = match.group(0)!.replaceFirst(_trailingPunctuation, '');
      if (visible.isEmpty) continue;
      final start = match.start;
      final end = start + visible.length;
      if (start > cursor) {
        segments.add(
          NoteLinkSegment(
            text: text.substring(cursor, start),
            start: cursor,
            end: start,
          ),
        );
      }
      segments.add(
        NoteLinkSegment(
          text: visible,
          start: start,
          end: end,
          url: normalize(visible),
        ),
      );
      cursor = end;
    }
    if (cursor < text.length) {
      segments.add(
        NoteLinkSegment(
          text: text.substring(cursor),
          start: cursor,
          end: text.length,
        ),
      );
    }
    return segments;
  }

  static bool isInsideLink(String text, int start, int end) {
    for (final segment in split(text)) {
      if (segment.url != null && start >= segment.start && end <= segment.end) {
        return true;
      }
    }
    return false;
  }

  static String? urlAtIndex(String text, int index) {
    for (final segment in split(text)) {
      final url = segment.url;
      if (url != null && index >= segment.start && index < segment.end) {
        return url;
      }
    }
    return null;
  }

  static String? urlAtPosition({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required Offset position,
    required TextDirection textDirection,
  }) {
    if (text.isEmpty || maxWidth <= 0) return null;
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
    )..layout(maxWidth: maxWidth);
    final url = _urlCovering(painter, text, position);
    painter.dispose();
    return url;
  }

  static List<InlineSpan> buildSpans(
    String text,
    TextStyle? style, {
    GestureRecognizer? Function(String url)? recognizeLink,
    bool openOnTap = false,
  }) {
    if (text.isEmpty) return [TextSpan(text: '', style: style)];
    return [
      for (final segment in split(text))
        _spanFor(
          segment,
          style,
          recognizeLink: recognizeLink,
          openOnTap: openOnTap,
        ),
    ];
  }

  static InlineSpan _spanFor(
    NoteLinkSegment segment,
    TextStyle? style, {
    required GestureRecognizer? Function(String url)? recognizeLink,
    required bool openOnTap,
  }) {
    final url = segment.url;
    if (url == null) return TextSpan(text: segment.text, style: style);
    final linkedStyle = linkStyle(style);
    if (openOnTap) {
      return WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => open(url),
          child: Text(segment.text, style: linkedStyle),
        ),
      );
    }
    return TextSpan(
      text: segment.text,
      style: linkedStyle,
      recognizer: recognizeLink?.call(url),
      mouseCursor: recognizeLink == null ? null : SystemMouseCursors.click,
    );
  }

  static TextStyle linkStyle(TextStyle? base) {
    final source = base ?? const TextStyle();
    final decoration = source.decoration == null
        ? TextDecoration.underline
        : TextDecoration.combine([
            source.decoration!,
            TextDecoration.underline,
          ]);
    return source.copyWith(
      color: linkColor,
      decoration: decoration,
      decorationColor: linkColor,
    );
  }

  static String normalize(String rawUrl) {
    final trimmed = rawUrl.replaceFirst(_trailingPunctuation, '');
    if (trimmed.toLowerCase().startsWith('www.')) return 'https://$trimmed';
    return trimmed;
  }

  static Future<void> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !_isWebScheme(uri)) return;
    try {
      final didOpenExternal = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (didOpenExternal) return;
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (error) {
      debugPrint('Could not open link: $error');
    }
  }

  static bool _isWebScheme(Uri uri) {
    return uri.isScheme('http') || uri.isScheme('https');
  }

  static String? _urlCovering(
    TextPainter painter,
    String text,
    Offset position,
  ) {
    for (final segment in split(text)) {
      final url = segment.url;
      if (url == null) continue;
      if (_containsPosition(painter, segment.start, segment.end, position)) {
        return url;
      }
    }
    return null;
  }

  static bool _containsPosition(
    TextPainter painter,
    int start,
    int end,
    Offset position,
  ) {
    final boxes = painter.getBoxesForSelection(
      TextSelection(baseOffset: start, extentOffset: end),
    );
    for (final box in boxes) {
      if (box.toRect().inflate(hitOutset).contains(position)) return true;
    }
    return false;
  }
}
