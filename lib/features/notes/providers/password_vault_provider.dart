import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/providers/biometric_auth_provider.dart';
import 'package:pocket_notes/core/services/biometric_unlock_result.dart';
import 'package:pocket_notes/features/notes/presentation/state/password_vault_state.dart';

final passwordVaultProvider =
    NotifierProvider<PasswordVaultNotifier, PasswordVaultState>(
      PasswordVaultNotifier.new,
    );

class PasswordVaultNotifier extends Notifier<PasswordVaultState> {
  bool _isPrompting = false;

  @override
  PasswordVaultState build() => const PasswordVaultState();

  Future<BiometricUnlockResult> unlock() async {
    if (state.isUnlocked) return BiometricUnlockResult.success;
    if (_isPrompting) return state.status;
    _isPrompting = true;
    state = state.copyWith(isChecking: true);
    try {
      final result = await ref.read(biometricAuthServiceProvider).unlockApp();
      state = state.copyWith(
        isUnlocked: result == BiometricUnlockResult.success,
        isChecking: false,
        status: result,
      );
      return result;
    } catch (_) {
      state = state.copyWith(
        isUnlocked: false,
        isChecking: false,
        status: BiometricUnlockResult.failed,
      );
      return BiometricUnlockResult.failed;
    } finally {
      _isPrompting = false;
    }
  }
}
