import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif_view/gif_view.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';
import 'package:pocket_notes/core/constants/app_images.dart';
import 'package:pocket_notes/features/splash/providers/splash_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashNotifier = ref.read(splashProvider.notifier);

    ref.listen(splashProvider, (previous, next) {
      final route = next.redirectRoute;
      if (route != null && route != previous?.redirectRoute) {
        context.go(route);
      }
    });

    final size = MediaQuery.sizeOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: GifView.asset(
          AppImages.splashLogo,
          loop: false,
          autoPlay: true,
          width: size.width,
          height: size.height,
          fit: BoxFit.cover,
          onLoaded: splashNotifier.onGifLoaded,
          onFinish: splashNotifier.onGifFinished,
        ),
      ),
    );
  }
}
