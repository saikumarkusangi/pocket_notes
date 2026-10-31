import 'dart:convert';
import 'dart:math';

class PasswordEntry {
  const PasswordEntry({
    this.category = defaultCategory,
    this.username = '',
    this.email = '',
    this.backupEmail = '',
    this.password = '',
    this.imageUrl = '',
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
  static const List<({String name, String imageUrl})> imageOptions = [
    (
      name: 'Instagram',
      imageUrl: 'https://www.google.com/s2/favicons?domain=instagram.com&sz=128',
    ),
    (
      name: 'GitHub',
      imageUrl: 'https://www.google.com/s2/favicons?domain=github.com&sz=128',
    ),
    (
      name: 'Google',
      imageUrl: 'https://www.google.com/s2/favicons?domain=google.com&sz=128',
    ),
    (
      name: 'Behance',
      imageUrl: 'https://www.google.com/s2/favicons?domain=behance.net&sz=128',
    ),
  ];

  final String category;
  final String username;
  final String email;
  final String backupEmail;
  final String password;
  final String imageUrl;

  Uri? get displayImageUri {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) return null;
    final parsed = Uri.tryParse(trimmed);
    if (parsed == null || parsed.host.isEmpty) return null;
    if (parsed.scheme != 'http' && parsed.scheme != 'https') return null;
    return parsed;
  }

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
        imageUrl: _readText(decoded['imageUrl']),
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
      'imageUrl': imageUrl,
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
