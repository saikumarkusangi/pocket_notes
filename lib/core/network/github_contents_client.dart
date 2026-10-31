import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pocket_notes/core/config/github_config.dart';

class GithubFile {
  const GithubFile({required this.path, required this.text, required this.sha});

  final String path;
  final String text;
  final String sha;
}

class GithubContentsClient {
  GithubContentsClient({required Dio dio, required GithubConfig config})
    : _dio = dio,
      _config = config;

  final Dio _dio;
  final GithubConfig _config;
  Future<void> _queue = Future<void>.value();

  Future<T> synchronized<T>(Future<T> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<GithubFile?> readFile(String path) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _contentsPath(path),
        queryParameters: {'ref': _config.branch},
      );
      return _fileFromResponse(path, response.data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> writeFile({
    required String path,
    required String content,
    required String message,
  }) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      final existing = await readFile(path);
      try {
        await _putFile(
          path: path,
          content: content,
          message: message,
          sha: existing?.sha,
        );
        return;
      } on DioException catch (error) {
        final canRetry = error.response?.statusCode == 409 && attempt == 0;
        if (!canRetry) rethrow;
      }
    }
  }

  Future<void> deleteFile({
    required String path,
    required String message,
  }) async {
    final existing = await readFile(path);
    if (existing == null) return;
    await _dio.delete<void>(
      _contentsPath(path),
      data: {
        'message': message,
        'sha': existing.sha,
        'branch': _config.branch,
      },
    );
  }

  Future<void> _putFile({
    required String path,
    required String content,
    required String message,
    required String? sha,
  }) async {
    await _dio.put<Map<String, dynamic>>(
      _contentsPath(path),
      data: {
        'message': message,
        'content': base64Encode(utf8.encode(content)),
        'branch': _config.branch,
        if (sha != null) 'sha': sha,
      },
    );
  }

  GithubFile? _fileFromResponse(String path, Map<String, dynamic>? data) {
    if (data == null) return null;
    final sha = data['sha'] as String?;
    if (sha == null || sha.isEmpty) return null;
    final encoded = (data['content'] as String? ?? '').replaceAll(
      RegExp(r'\s'),
      '',
    );
    final text = encoded.isEmpty ? '' : utf8.decode(base64Decode(encoded));
    return GithubFile(path: path, text: text, sha: sha);
  }

  String _contentsPath(String path) {
    final encoded = path.split('/').map(Uri.encodeComponent).join('/');
    return '/repos/${_config.owner}/${_config.repo}/contents/$encoded';
  }
}
