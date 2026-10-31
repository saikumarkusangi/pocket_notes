import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_notes/core/utils/note_links.dart';
import 'package:pocket_notes/core/utils/note_text_formatter.dart';

void main() {
  group('NoteLinks.split', () {
    test('keeps plain text when there is no link', () {
      const inputText = 'Buy milk';
      final actualSegments = NoteLinks.split(inputText);
      expect(actualSegments, hasLength(1));
      expect(actualSegments.single.text, inputText);
      expect(actualSegments.single.url, isNull);
    });

    test('splits an https link from surrounding text', () {
      const inputText = 'See https://example.com/a today.';
      final actualSegments = NoteLinks.split(inputText);
      expect(actualSegments.map((segment) => segment.text).toList(), [
        'See ',
        'https://example.com/a',
        ' today.',
      ]);
      expect(actualSegments[1].url, 'https://example.com/a');
    });

    test('prefixes www links with https and drops trailing punctuation', () {
      const inputText = 'Open www.example.com.';
      final actualSegments = NoteLinks.split(inputText);
      expect(actualSegments[1].text, 'www.example.com');
      expect(actualSegments[1].url, 'https://www.example.com');
      expect(actualSegments.last.text, '.');
    });
  });

  group('NoteLinks.urlAtIndex', () {
    test('returns the url when the index is inside the link', () {
      const inputText = 'See https://example.com now';
      final inputIndex = inputText.indexOf('https') + 2;
      final actualUrl = NoteLinks.urlAtIndex(inputText, inputIndex);
      expect(actualUrl, 'https://example.com');
    });

    test('returns null when the index is outside the link', () {
      const inputText = 'See https://example.com now';
      final actualUrl = NoteLinks.urlAtIndex(inputText, 0);
      expect(actualUrl, isNull);
    });
  });

  test('keeps underscores inside a url instead of treating them as italic', () {
    const inputText = 'https://example.com/a_b_c';
    final actualSpan = NoteFormattedText.parse(inputText);
    expect(actualSpan.toPlainText(), inputText);
  });
}
