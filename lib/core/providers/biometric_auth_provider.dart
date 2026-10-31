import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/services/biometric_auth_service.dart';
import 'package:pocket_notes/core/services/biometric_authenticator.dart';
import 'package:pocket_notes/core/services/local_biometric_authenticator.dart';

final biometricAuthenticatorProvider = Provider<BiometricAuthenticator>(
  (ref) => LocalBiometricAuthenticator(),
);

final biometricAuthServiceProvider = Provider<BiometricAuthService>(
  (ref) => BiometricAuthService(
    authenticator: ref.watch(biometricAuthenticatorProvider),
  ),
);
