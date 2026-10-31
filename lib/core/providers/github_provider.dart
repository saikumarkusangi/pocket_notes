import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/config/github_config.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/core/network/github_contents_client.dart';
import 'package:pocket_notes/core/network/github_database.dart';

final githubDatabaseProvider = Provider<GithubDatabase>((ref) {
  final config = GithubConfig.fromEnvironment();
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.github.com',
      connectTimeout: AppConstants.apiConnectTimeoutDuration,
      receiveTimeout: AppConstants.apiReceiveTimeoutDuration,
      headers: {
        'Accept': 'application/vnd.github+json',
        'Authorization': 'Bearer ${config.token}',
        'X-GitHub-Api-Version': '2022-11-28',
        'User-Agent': 'pocket-notes',
      },
    ),
  );
  return GithubDatabase(GithubContentsClient(dio: dio, config: config));
});
