import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/features/auth/data/models/user_model.dart';
import 'package:pocket_notes/features/auth/data/services/google_auth_service.dart';
import 'package:pocket_notes/features/auth/providers/auth_provider.dart';
import 'package:pocket_notes/features/auth/providers/user_repository_provider.dart';
import 'package:pocket_notes/core/services/notes_sync_coordinator.dart';
import 'package:pocket_notes/features/notes/providers/notes_offline_provider.dart';

enum GoogleAuthStatus { idle, loading, success, cancelled, error }

class GoogleAuthState {
  const GoogleAuthState({
    this.status = GoogleAuthStatus.idle,
    this.errorMessage,
  });

  final GoogleAuthStatus status;
  final String? errorMessage;

  bool get isLoading => status == GoogleAuthStatus.loading;

  GoogleAuthState copyWith({GoogleAuthStatus? status, String? errorMessage}) {
    return GoogleAuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

final googleAuthServiceProvider = Provider<GoogleAuthService>(
  (ref) => GoogleAuthService(),
);

final googleAuthProvider =
    NotifierProvider<GoogleAuthNotifier, GoogleAuthState>(
      GoogleAuthNotifier.new,
    );

class GoogleAuthNotifier extends Notifier<GoogleAuthState> {
  @override
  GoogleAuthState build() => const GoogleAuthState();

  Future<void> signInWithGoogle() async {
    if (state.isLoading) return;

    state = GoogleAuthState(status: GoogleAuthStatus.loading);

    final service = ref.read(googleAuthServiceProvider);
    final result = await service.signIn();

    if (!result.isSuccess || result.user == null) {
      state = GoogleAuthState(
        status: GoogleAuthStatus.error,
        errorMessage: result.errorMessage ?? 'Google sign-in failed',
      );
      return;
    }

    try {
      final apiUser = await ref
          .read(userRepositoryProvider)
          .syncUserAfterLogin(result.user!);

      await ref.read(authProvider.notifier).saveSession(
            token: result.user!.idToken ?? result.user!.id,
            user: UserModel(
              id: apiUser.id,
              email: result.user!.email,
              name: result.user!.displayName,
              photoUrl: result.user!.photoUrl,
              googleId: result.user!.id,
            ),
          );

      await ref.read(notesOfflineRepositoryProvider).repairOrphanedNotes(
        apiUser.id,
      );

      try {
        await ref.read(notesSyncCoordinatorProvider).run(
          showNotification: true,
          notifyWhenIdle: true,
        );
      } catch (_) {
        // Cached notes remain available if the initial sync fails.
      }
    } on DioException catch (error) {
      state = GoogleAuthState(
        status: GoogleAuthStatus.error,
        errorMessage: error.message ?? 'Failed to sync user profile',
      );
      return;
    } catch (error) {
      state = GoogleAuthState(
        status: GoogleAuthStatus.error,
        errorMessage: error.toString(),
      );
      return;
    }

    state = GoogleAuthState(status: GoogleAuthStatus.success);
  }

  Future<void> logout() async {
    if (state.isLoading) return;

    state = GoogleAuthState(status: GoogleAuthStatus.loading);

    final service = ref.read(googleAuthServiceProvider);
    final result = await service.signOut();

    if (!result.isSuccess) {
      state = GoogleAuthState(
        status: GoogleAuthStatus.error,
        errorMessage: result.errorMessage,
      );
      return;
    }

    // Clear user session
    await ref.read(authProvider.notifier).clearSession();
    state = GoogleAuthState(status: GoogleAuthStatus.success);
  }

  void reset() {
    state = const GoogleAuthState();
  }
}
