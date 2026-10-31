import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pocket_notes/core/services/biometric_auth_service.dart';
import 'package:pocket_notes/core/services/biometric_authenticator.dart';
import 'package:pocket_notes/core/services/biometric_availability.dart';
import 'package:pocket_notes/core/services/biometric_unlock_result.dart';

void main() {
  group('BiometricAvailability.fromEnrolled', () {
    test('keeps face and fingerprint when the platform reports them', () {
      final actualAvailability = BiometricAvailability.fromEnrolled(const [
        BiometricType.face,
        BiometricType.fingerprint,
      ]);
      expect(actualAvailability.hasFace, isTrue);
      expect(actualAvailability.hasFingerprint, isTrue);
      expect(
        actualAvailability.reason,
        'Use your face or fingerprint to unlock Pocket Notes',
      );
    });

    test('treats Android strong biometrics as a fingerprint', () {
      final actualAvailability = BiometricAvailability.fromEnrolled(const [
        BiometricType.weak,
        BiometricType.strong,
      ]);
      expect(actualAvailability.hasFace, isFalse);
      expect(actualAvailability.hasFingerprint, isTrue);
      expect(
        actualAvailability.reason,
        'Use your fingerprint to unlock Pocket Notes',
      );
    });

    test('treats Android weak-only biometrics as face', () {
      final actualAvailability = BiometricAvailability.fromEnrolled(const [
        BiometricType.weak,
      ]);
      expect(actualAvailability.hasFace, isTrue);
      expect(actualAvailability.hasFingerprint, isFalse);
      expect(actualAvailability.reason, 'Use your face to unlock Pocket Notes');
    });
  });

  group('BiometricAuthService.unlockApp', () {
    test('asks for a biometric when face is enrolled', () async {
      final authenticator = _FakeBiometricAuthenticator(
        enrolled: const [BiometricType.face],
        authenticateResult: true,
      );
      final service = BiometricAuthService(authenticator: authenticator);
      final actualResult = await service.unlockApp();
      expect(actualResult, BiometricUnlockResult.success);
      expect(authenticator.authenticateCalls, 1);
      expect(authenticator.lastBiometricOnly, isTrue);
      expect(authenticator.lastReason, 'Use your face to unlock Pocket Notes');
    });

    test('asks for a biometric when a fingerprint is enrolled', () async {
      final authenticator = _FakeBiometricAuthenticator(
        enrolled: const [BiometricType.fingerprint],
      );
      final service = BiometricAuthService(authenticator: authenticator);
      final actualResult = await service.unlockApp();
      expect(actualResult, BiometricUnlockResult.cancelled);
      expect(
        authenticator.lastReason,
        'Use your fingerprint to unlock Pocket Notes',
      );
    });

    test('does not prompt when the device cannot check biometrics', () async {
      final authenticator = _FakeBiometricAuthenticator(
        canCheck: false,
        enrolled: const [BiometricType.face],
      );
      final service = BiometricAuthService(authenticator: authenticator);
      final actualResult = await service.unlockApp();
      expect(actualResult, BiometricUnlockResult.unavailable);
      expect(authenticator.authenticateCalls, 0);
    });

    test('does not prompt when face and fingerprint are missing', () async {
      final authenticator = _FakeBiometricAuthenticator();
      final service = BiometricAuthService(authenticator: authenticator);
      final actualResult = await service.unlockApp();
      expect(actualResult, BiometricUnlockResult.unavailable);
      expect(authenticator.authenticateCalls, 0);
    });

    test('reports a cancelled scan', () async {
      final authenticator = _FakeBiometricAuthenticator(
        enrolled: const [BiometricType.face],
        error: const LocalAuthException(code: LocalAuthExceptionCode.userCanceled),
      );
      final service = BiometricAuthService(authenticator: authenticator);
      final actualResult = await service.unlockApp();
      expect(actualResult, BiometricUnlockResult.cancelled);
    });
  });
}

class _FakeBiometricAuthenticator implements BiometricAuthenticator {
  _FakeBiometricAuthenticator({
    this.canCheck = true,
    this.enrolled = const [],
    this.authenticateResult = false,
    this.error,
  });

  final bool canCheck;
  final List<BiometricType> enrolled;
  final bool authenticateResult;
  final LocalAuthException? error;
  String? lastReason;
  bool? lastBiometricOnly;
  int authenticateCalls = 0;

  @override
  Future<bool> canCheckBiometrics() async => canCheck;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => enrolled;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required bool biometricOnly,
  }) async {
    authenticateCalls += 1;
    lastReason = localizedReason;
    lastBiometricOnly = biometricOnly;
    final failure = error;
    if (failure != null) throw failure;
    return authenticateResult;
  }
}
