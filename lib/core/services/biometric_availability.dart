import 'package:local_auth/local_auth.dart';

class BiometricAvailability {
  const BiometricAvailability({
    required this.hasFace,
    required this.hasFingerprint,
  });

  final bool hasFace;
  final bool hasFingerprint;

  bool get canUnlock => hasFace || hasFingerprint;

  String get reason {
    if (hasFace && hasFingerprint) {
      return 'Use your face or fingerprint to unlock passwords';
    }
    if (hasFace) return 'Use your face to unlock passwords';
    return 'Use your fingerprint to unlock passwords';
  }

  factory BiometricAvailability.fromEnrolled(List<BiometricType> enrolled) {
    final hasFace = enrolled.contains(BiometricType.face);
    final hasFingerprint = enrolled.contains(BiometricType.fingerprint);
    if (hasFace || hasFingerprint) {
      return BiometricAvailability(
        hasFace: hasFace,
        hasFingerprint: hasFingerprint,
      );
    }
    final hasStrong = enrolled.contains(BiometricType.strong);
    final hasWeak = enrolled.contains(BiometricType.weak);
    return BiometricAvailability(
      hasFace: hasWeak && !hasStrong,
      hasFingerprint: hasStrong,
    );
  }
}
