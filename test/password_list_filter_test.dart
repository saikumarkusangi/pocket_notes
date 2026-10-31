import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_notes/features/notes/presentation/widgets/password_list_filter.dart';

void main() {
  group('PasswordListFilter', () {
    test('puts used categories after All and keeps extras at the end', () {
      final actualLabels = PasswordListFilter.labelsFor(const [
        'Work',
        'Gaming',
        'Social',
        'Social',
      ]);
      expect(actualLabels, ['All', 'Social', 'Work', 'Gaming']);
    });

    test('matches every category when All is selected', () {
      final actualMatch = PasswordListFilter.matches(
        category: 'Finance',
        selected: PasswordListFilter.all,
      );
      expect(actualMatch, isTrue);
    });

    test('matches only the selected category', () {
      final actualMatch = PasswordListFilter.matches(
        category: 'Work',
        selected: 'Social',
      );
      expect(actualMatch, isFalse);
    });
  });
}
