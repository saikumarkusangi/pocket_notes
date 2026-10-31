import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_notes/features/notes/data/models/password_entry.dart';

void main() {
  group('PasswordEntry', () {
    test('starts as a social entry when the body is empty', () {
      final actualEntry = PasswordEntry.fromBody('');
      expect(actualEntry.category, PasswordEntry.defaultCategory);
      expect(actualEntry.username, isEmpty);
      expect(actualEntry.password, isEmpty);
    });

    test('keeps special characters through a save and load', () {
      const inputEntry = PasswordEntry(
        category: 'Social',
        username: 'Kimberly_125',
        email: 'kimberly.smith12@gmail.com',
        backupEmail: 'john.smith1295@gmail.com',
        password: r'p@ss "w0rd" \n',
      );
      final actualEntry = PasswordEntry.fromBody(inputEntry.toBody());
      expect(actualEntry.category, inputEntry.category);
      expect(actualEntry.username, inputEntry.username);
      expect(actualEntry.email, inputEntry.email);
      expect(actualEntry.backupEmail, inputEntry.backupEmail);
      expect(actualEntry.password, inputEntry.password);
    });

    test('keeps a category that is not in the default list', () {
      final actualEntry = PasswordEntry.fromBody('{"category":"Gaming"}');
      expect(actualEntry.category, 'Gaming');
    });

    test('ignores a body that is not an entry', () {
      final actualEntry = PasswordEntry.fromBody('not json');
      expect(actualEntry.category, PasswordEntry.defaultCategory);
      expect(actualEntry.password, isEmpty);
    });

    test('builds a repeatable password of the expected length', () {
      final firstPassword = PasswordEntry.generatePassword(random: Random(4));
      final secondPassword = PasswordEntry.generatePassword(random: Random(4));
      expect(firstPassword, secondPassword);
      expect(firstPassword.length, PasswordEntry.passwordLength);
    });
  });
}
