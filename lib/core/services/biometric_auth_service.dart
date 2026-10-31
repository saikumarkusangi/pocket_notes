import 'package:local_auth/local_auth.dart';
import 'package:pocket_notes/core/services/biometric_authenticator.dart';
import 'package:pocket_notes/core/services/biometric_availability.dart';
import 'package:pocket_notes/core/services/biometric_unlock_result.dart';

class BiometricAuthService {
  const BiometricAuthService({required BiometricAuthenticator authenticator})
    : _authenticator = authenticator;

  final BiometricAuthenticator _authenticator;

  Future<BiometricAvailability> readAvailability() async {
    try {
      final canCheck = await _authenticator.canCheckBiometrics();
      if (!canCheck) {
        return const BiometricAvailability(hasFace: false, hasFingerprint: false);
      }
      final enrolled = await _authenticator.getAvailableBiometrics();
      return BiometricAvailability.fromEnrolled(enrolled);
    } on LocalAuthException {
      return const BiometricAvailability(hasFace: false, hasFingerprint: false);
    }
  }

  Future<BiometricUnlockResult> unlockApp() async {
    final availability = await readAvailability();
    if (!availability.canUnlock) return BiometricUnlockResult.unavailable;
    try {
      final didAuthenticate = await _authenticator.authenticate(
        localizedReason: availability.reason,
        biometricOnly: true,
      );
      if (didAuthenticate) return BiometricUnlockResult.success;
      return BiometricUnlockResult.cancelled;
    } on LocalAuthException catch (error) {
      return _resultFor(error.code);
    }
  }

  BiometricUnlockResult _resultFor(LocalAuthExceptionCode code) {
    return switch (code) {
      LocalAuthExceptionCode.userCanceled ||
      LocalAuthExceptionCode.systemCanceled ||
      LocalAuthExceptionCode.timeout => BiometricUnlockResult.cancelled,
      LocalAuthExceptionCode.noBiometricsEnrolled ||
      LocalAuthExceptionCode.noBiometricHardware ||
      LocalAuthExceptionCode.noCredentialsSet =>
        BiometricUnlockResult.unavailable,
      _ => BiometricUnlockResult.failed,
    };
  }
}
