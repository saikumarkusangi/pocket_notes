import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/providers/github_provider.dart';
import 'package:pocket_notes/features/auth/data/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(githubDatabaseProvider));
});
