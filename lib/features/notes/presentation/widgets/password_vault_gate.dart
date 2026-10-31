import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/features/notes/presentation/state/password_vault_state.dart';
import 'package:pocket_notes/features/notes/providers/password_vault_provider.dart';

class PasswordVaultGate extends ConsumerStatefulWidget {
  const PasswordVaultGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PasswordVaultGate> createState() => _PasswordVaultGateState();
}

class _PasswordVaultGateState extends ConsumerState<PasswordVaultGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prompt());
  }

  @override
  Widget build(BuildContext context) {
    final vault = ref.watch(passwordVaultProvider);
    return Stack(
      children: [
        IgnorePointer(
          ignoring: !vault.isUnlocked,
          child: ExcludeSemantics(
            excluding: !vault.isUnlocked,
            child: widget.child,
          ),
        ),
        if (!vault.isUnlocked)
          Positioned.fill(
            child: _PasswordLockView(vault: vault, onUnlock: _prompt),
          ),
      ],
    );
  }

  Future<void> _prompt() async {
    if (!mounted) return;
    await ref.read(passwordVaultProvider.notifier).unlock();
  }
}

class _PasswordLockView extends StatelessWidget {
  const _PasswordLockView({required this.vault, required this.onUnlock});

  final PasswordVaultState vault;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.face_rounded, size: 40, color: Color(0xFF6D28D9)),
                  SizedBox(width: 18),
                  Icon(Icons.fingerprint, size: 40, color: Color(0xFF6D28D9)),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Unlock Pocket Notes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                vault.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 15),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: vault.isChecking ? null : onUnlock,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE9D5FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(vault.isChecking ? 'Waiting for unlock' : 'Unlock'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
