import 'package:local_auth/local_auth.dart';

abstract class BiometricAuthenticator {
  Future<bool> canCheckBiometrics();

  Future<List<BiometricType>> getAvailableBiometrics();

  Future<bool> authenticate({
    required String localizedReason,
    required bool biometricOnly,
  });
}
