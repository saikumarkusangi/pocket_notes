import 'package:flutter/material.dart';
import 'package:pocket_notes/core/constants/app_colors.dart';

class AppTheme {
  // Light Theme
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.light(
      primary: AppColors.text,
      secondary: AppColors.secondary,
      surface: AppColors.background,
      onPrimary: AppColors.text,
      onSecondary: AppColors.secondary,
      onPrimaryContainer: AppColors.background,
      onSurface: AppColors.card,
      background: AppColors.background,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(
      primary: AppColors.text,
      secondary: AppColors.secondary,
      surface: AppColors.background,
      onPrimary: AppColors.text,
      onSecondary: AppColors.secondary,
      onPrimaryContainer: AppColors.background,
      onSurface: AppColors.card,
      background: AppColors.background,
    ),
  );
}
