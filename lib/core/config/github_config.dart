import 'package:flutter_dotenv/flutter_dotenv.dart';

class GithubConfig {
  const GithubConfig({
    required this.owner,
    required this.repo,
    required this.branch,
    required this.token,
  });

  final String owner;
  final String repo;
  final String branch;
  final String token;

  static const String databaseDirectory = 'DB';

  factory GithubConfig.fromEnvironment() {
    final token = dotenv.env['GITHUB_TOKEN']?.trim() ?? '';
    if (token.isEmpty) {
      throw StateError(
        'GITHUB_TOKEN is missing. Add a GitHub token with Contents '
        'read and write access to .env.',
      );
    }
    return GithubConfig(
      owner: _valueOrDefault('GITHUB_OWNER', 'saikumarkusangi'),
      repo: _valueOrDefault('GITHUB_REPO', 'pocket_notes'),
      branch: _valueOrDefault('GITHUB_BRANCH', 'main'),
      token: token,
    );
  }

  static String _valueOrDefault(String key, String fallback) {
    final value = dotenv.env[key]?.trim() ?? '';
    if (value.isEmpty) return fallback;
    return value;
  }
}
