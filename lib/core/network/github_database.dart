import 'dart:convert';

import 'package:pocket_notes/core/config/github_config.dart';
import 'package:pocket_notes/core/network/github_contents_client.dart';

class GithubDatabase {
  GithubDatabase(this._client);

  final GithubContentsClient _client;

  Future<T> run<T>(Future<T> Function(GithubSession session) action) {
    return _client.synchronized(() => action(GithubSession(_client)));
  }
}

class GithubSession {
  GithubSession(this._client);

  final GithubContentsClient _client;
  static final JsonEncoder _jsonEncoder = JsonEncoder.withIndent('  ');

  Future<List<Map<String, dynamic>>> readJsonList(String path) async {
    final text = await readText(path);
    if (text.trim().isEmpty) return [];
    final decoded = jsonDecode(text);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> writeJsonList({
    required String path,
    required List<Map<String, dynamic>> records,
    required String message,
  }) {
    final text = '${_jsonEncoder.convert(records)}\n';
    return writeText(path: path, content: text, message: message);
  }

  Future<String> readText(String path) async {
    final file = await _client.readFile(path);
    return file?.text ?? '';
  }

  Future<void> writeText({
    required String path,
    required String content,
    required String message,
  }) {
    return _client.writeFile(path: path, content: content, message: message);
  }

  Future<void> deleteFile({required String path, required String message}) {
    return _client.deleteFile(path: path, message: message);
  }
}

String nextRecordId(List<Map<String, dynamic>> records) {
  var maxId = 0;
  for (final record in records) {
    final parsed = int.tryParse('${record['id']}') ?? 0;
    if (parsed > maxId) maxId = parsed;
  }
  return '${maxId + 1}';
}

String githubDatabasePath(String relativePath) {
  return '${GithubConfig.databaseDirectory}/$relativePath';
}
