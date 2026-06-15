import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/features/auth/providers/auth_provider.dart';

class SplashState {
  const SplashState({this.redirectRoute});

  final String? redirectRoute;
}

final splashProvider = NotifierProvider<SplashNotifier, SplashState>(
  SplashNotifier.new,
);

class SplashNotifier extends Notifier<SplashState> {
  static const Duration postAnimationDelay = Duration(milliseconds: 200);

  bool _isSchedulingRedirect = false;

  @override
  SplashState build() => const SplashState();

  void onGifLoaded(int totalFrames) {
    if (totalFrames <= 1) {
      scheduleRedirect();
    }
  }

  void onGifFinished() {
    scheduleRedirect();
  }

  Future<void> scheduleRedirect() async {
    if (_isSchedulingRedirect) return;
    _isSchedulingRedirect = true;

    await Future<void>.delayed(postAnimationDelay);

    final isAuthenticated = ref.read(authProvider).isAuthenticated;
    state = SplashState(
      redirectRoute: isAuthenticated
          ? AppConstants.homeRoute
          : AppConstants.loginRoute,
    );
  }
}
