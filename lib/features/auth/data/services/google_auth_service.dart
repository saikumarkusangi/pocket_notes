import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pocket_notes/core/config/env_config.dart';
import 'package:pocket_notes/features/auth/data/models/google_auth_result.dart';

class GoogleAuthService {
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    await GoogleSignIn.instance.initialize(
      serverClientId: EnvConfig.googleWebClientId,
    );    _isInitialized = true;
  }

  Future<GoogleAuthResult> signIn() async {
    try {
      await _ensureInitialized();

      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        return GoogleAuthResult.failure(
          'Google sign-in is not supported on this device.',
        );
      }

      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );

      return _successFromAccount(account);
    } on GoogleSignInException catch (error) {
      if (kDebugMode) {
        debugPrint(
          'GoogleSignInException: code=${error.code}, '
          'description=${error.description}',
        );
      }

      return GoogleAuthResult.failure(_mapExceptionMessage(error));
    } catch (error) {
      return GoogleAuthResult.failure(error.toString());
    }
  }

  GoogleAuthResult _successFromAccount(GoogleSignInAccount account) {
    return GoogleAuthResult.success(
      GoogleAuthUser(
        id: account.id,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
        idToken: account.authentication.idToken,
      ),
      GoogleAuthAction.signIn,
    );
  }

  String _mapExceptionMessage(GoogleSignInException error) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
        return error.description ??
            'Google sign-in cancelled. Please try again.';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return error.description ??
            'Google sign-in is misconfigured. Re-download google-services.json '
                'after enabling Google Sign-In in Firebase.';
      case GoogleSignInExceptionCode.interrupted:
        return error.description ??
            'Google sign-in was interrupted. Please try again.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return error.description ??
            'Google sign-in UI is unavailable on this device. Please try again.';
      case GoogleSignInExceptionCode.unknownError:
        return error.description ?? 'Google sign-in failed. Please try again.';
      case GoogleSignInExceptionCode.providerConfigurationError:
        return error.description ??
            'Google sign-in is misconfigured. Please try again.';
      case GoogleSignInExceptionCode.userMismatch:
        return error.description ??
            'Google sign-in is misconfigured. Please try again.';
    }
  }

  Future<GoogleAuthResult> signOut() async {
    await _ensureInitialized();
    await GoogleSignIn.instance.signOut();
    return GoogleAuthResult.logout();
  }
}
