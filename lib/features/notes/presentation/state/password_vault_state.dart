import 'package:pocket_notes/core/services/biometric_unlock_result.dart';

class PasswordVaultState {
  const PasswordVaultState({
    this.isUnlocked = false,
    this.isChecking = false,
    this.status = BiometricUnlockResult.idle,
    this.resumeTick = 0,
  });

  final bool isUnlocked;
  final bool isChecking;
  final BiometricUnlockResult status;
  final int resumeTick;

  String get message {
    return switch (status) {
      BiometricUnlockResult.idle => 'Confirm it\'s you to open Pocket Notes',
      BiometricUnlockResult.success => '',
      BiometricUnlockResult.cancelled => 'Authentication was cancelled',
      BiometricUnlockResult.unavailable =>
        'Set up face or fingerprint unlock to open Pocket Notes',
      BiometricUnlockResult.failed =>
        'Could not verify your face or fingerprint',
    };
  }

  PasswordVaultState copyWith({
    bool? isUnlocked,
    bool? isChecking,
    BiometricUnlockResult? status,
    int? resumeTick,
  }) {
    return PasswordVaultState(
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isChecking: isChecking ?? this.isChecking,
      status: status ?? this.status,
      resumeTick: resumeTick ?? this.resumeTick,
    );
  }
}
