import 'package:local_auth/local_auth.dart';
import 'package:pocket_notes/core/services/biometric_authenticator.dart';

class LocalBiometricAuthenticator implements BiometricAuthenticator {
  LocalBiometricAuthenticator({LocalAuthentication? localAuthentication})
    : _localAuthentication = localAuthentication ?? LocalAuthentication();

  final LocalAuthentication _localAuthentication;

  @override
  Future<bool> canCheckBiometrics() {
    return _localAuthentication.canCheckBiometrics;
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() {
    return _localAuthentication.getAvailableBiometrics();
  }

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required bool biometricOnly,
  }) {
    return _localAuthentication.authenticate(
      localizedReason: localizedReason,
      biometricOnly: biometricOnly,
      sensitiveTransaction: true,
      persistAcrossBackgrounding: true,
    );
  }
}
