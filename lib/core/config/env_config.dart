import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get googleWebClientId {
    final value = dotenv.env['GOOGLE_WEB_CLIENT_ID']?.trim();
    if (value == null || value.isEmpty) {
      throw StateError(
        'GOOGLE_WEB_CLIENT_ID is missing. Copy .env.example to .env and set it.',
      );
    }
    return value;
  }
}
