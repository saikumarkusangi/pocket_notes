import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pocket_notes/core/utils/note_links.dart';
import 'package:pocket_notes/core/utils/note_text_formatter.dart';

/// Renders note text and opens web links when they are tapped.
class NoteLinkText extends StatelessWidget {
  const NoteLinkText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
    this.formatted = false,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool formatted;

  @override
  Widget build(BuildContext context) {
    final span = formatted
        ? NoteFormattedText.parse(text, style: style, openOnTap: true)
        : TextSpan(
            style: style,
            children: NoteLinks.buildSpans(text, style, openOnTap: true),
          );
    return Text.rich(
      span,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

/// Opens a link when a tap lands on a URL inside an editable note field.
class NoteLinkTapLayer extends StatefulWidget {
  const NoteLinkTapLayer({
    super.key,
    required this.text,
    required this.child,
    this.style,
  });

  final String Function() text;
  final TextStyle? style;
  final Widget child;

  @override
  State<NoteLinkTapLayer> createState() => _NoteLinkTapLayerState();
}

class _NoteLinkTapLayerState extends State<NoteLinkTapLayer> {
  Offset? _downPosition;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _rememberDown,
      onPointerUp: _openLinkOnTap,
      onPointerCancel: _clearDown,
      child: widget.child,
    );
  }

  void _rememberDown(PointerDownEvent event) {
    _downPosition = event.localPosition;
  }

  void _clearDown(PointerCancelEvent event) {
    _downPosition = null;
  }

  void _openLinkOnTap(PointerUpEvent event) {
    final start = _downPosition;
    _downPosition = null;
    if (start == null || (event.localPosition - start).distance > kTouchSlop) {
      return;
    }
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final url = NoteLinks.urlAtPosition(
      text: widget.text(),
      style: widget.style ?? DefaultTextStyle.of(context).style,
      maxWidth: box.size.width,
      position: event.localPosition,
      textDirection: Directionality.of(context),
    );
    if (url == null) return;
    NoteLinks.open(url);
  }
}
