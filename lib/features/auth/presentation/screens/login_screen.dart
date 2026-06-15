import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/core/constants/app_images.dart';
import 'package:pocket_notes/features/auth/presentation/widgets/google_login_button.dart';
import 'package:pocket_notes/features/auth/providers/google_auth_provider.dart';


class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(googleAuthProvider, (previous, next) {
      if (next.status == GoogleAuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
        ref.read(googleAuthProvider.notifier).reset();
      }

      if (next.status == GoogleAuthStatus.success) {
        ref.read(googleAuthProvider.notifier).reset();
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),
                Image.asset(AppImages.logo, height: 144, width: 144),
                const SizedBox(height: 24),
                Text(
                  AppConstants.appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.card,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppConstants.appTagline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.text,
                    height: 1.4,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppConstants.appDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.gray,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                const GoogleLoginButton(),
                const SizedBox(height: 44),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
