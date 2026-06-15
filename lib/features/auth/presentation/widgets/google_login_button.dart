import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/features/auth/providers/google_auth_provider.dart';

class GoogleLoginButton extends ConsumerWidget {
  const GoogleLoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(googleAuthProvider).isLoading;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.text,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(double.infinity, 48),
      ),
      onPressed: isLoading
          ? null
          : () => ref.read(googleAuthProvider.notifier).signInWithGoogle(),
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/60px-Google_%22G%22_logo.svg.png?_=20230822192911',
                  height: 32,
                  width: 32,
                ),
                const SizedBox(width: 10),
                Text(
                  'Continue with Google',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
    );
  }
}
