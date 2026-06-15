import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/core/providers/storage_provider.dart';
import 'package:pocket_notes/features/auth/data/models/user_model.dart';

class AuthState {
  const AuthState({this.isAuthenticated = false, this.user});

  final bool isAuthenticated;
  final UserModel? user;
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final token = prefs.getString(AppConstants.authTokenStorageKey);
    final userData = prefs.getString(AppConstants.userDataStorageKey);

    return AuthState(
      isAuthenticated: token != null && token.isNotEmpty,
      user: userData != null ? UserModel.fromJson(jsonDecode(userData)) : null,
    );
  }

  Future<void> saveSession({
    required String token,
    required UserModel user,
  }) async {
    final prefs = ref.read(sharedPreferencesProvider);

    await prefs.setString(AppConstants.authTokenStorageKey, token);
    await prefs.setString(
      AppConstants.userDataStorageKey,
      jsonEncode(user.toJson()),
    );

    state = AuthState(isAuthenticated: true, user: user);
  }

  Future<void> clearSession() async {
    final prefs = ref.read(sharedPreferencesProvider);

    await prefs.remove(AppConstants.authTokenStorageKey);
    await prefs.remove(AppConstants.userDataStorageKey);

    state = AuthState(isAuthenticated: false, user: null);
  }
}
