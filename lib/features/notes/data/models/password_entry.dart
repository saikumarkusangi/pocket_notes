import 'dart:convert';
import 'dart:math';

class PasswordEntry {
  const PasswordEntry({
    this.category = defaultCategory,
    this.username = '',
    this.email = '',
    this.backupEmail = '',
    this.password = '',
  });

  static const String defaultCategory = 'Social';
  static const int passwordLength = 16;
  static const List<String> categories = [
    'Social',
    'Work',
    'Finance',
    'Shopping',
    'Entertainment',
    'Other',
  ];
  static const String _passwordAlphabet =
      'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#%&*?';

  final String category;
  final String username;
  final String email;
  final String backupEmail;
  final String password;

  factory PasswordEntry.fromBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return const PasswordEntry();
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map) return const PasswordEntry();
      return PasswordEntry(
        category: _readCategory(decoded['category']),
        username: _readText(decoded['username']),
        email: _readText(decoded['email']),
        backupEmail: _readText(decoded['backupEmail']),
        password: _readText(decoded['password']),
      );
    } on FormatException {
      return const PasswordEntry();
    }
  }

  String toBody() {
    return jsonEncode({
      'category': category,
      'username': username,
      'email': email,
      'backupEmail': backupEmail,
      'password': password,
    });
  }

  static String generatePassword({Random? random}) {
    final source = random ?? Random.secure();
    final buffer = StringBuffer();
    for (var index = 0; index < passwordLength; index++) {
      final character = _passwordAlphabet[source.nextInt(
        _passwordAlphabet.length,
      )];
      buffer.write(character);
    }
    return buffer.toString();
  }

  static String _readCategory(Object? value) {
    final category = _readText(value).trim();
    if (category.isEmpty) return defaultCategory;
    return category;
  }

  static String _readText(Object? value) {
    if (value is String) return value;
    return '';
  }
}
