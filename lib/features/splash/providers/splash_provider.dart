import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/features/auth/providers/auth_provider.dart';

class SplashState {
  const SplashState({this.redirectRoute});

  final String? redirectRoute;
}

const Duration _splashDuration = Duration(milliseconds: 400);

final splashProvider = NotifierProvider<SplashNotifier, SplashState>(
  SplashNotifier.new,
);

class SplashNotifier extends Notifier<SplashState> {
  @override
  SplashState build() => const SplashState();

  Future<void> redirect() async {
    await Future<void>.delayed(_splashDuration);
    if (!ref.mounted) return;
    final isAuthenticated = ref.read(authProvider).isAuthenticated;
    state = SplashState(
      redirectRoute: isAuthenticated
          ? AppConstants.homeRoute
          : AppConstants.loginRoute,
    );
  }
}
