import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: AppTypography.headlineLarge.copyWith(color: primary),
      displayMedium: AppTypography.headlineMedium.copyWith(color: primary),
      titleLarge: AppTypography.titleLarge.copyWith(color: primary),
      titleMedium: AppTypography.titleMedium.copyWith(color: primary),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: primary),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: secondary),
      labelMedium: AppTypography.labelMedium.copyWith(color: secondary),
      labelSmall: AppTypography.labelSmall.copyWith(color: secondary),
    );
  }

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.slate900,
    ),
    textTheme: _buildTextTheme(AppColors.slate900, AppColors.slate500),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight.withValues(alpha: 0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.headlineMedium.copyWith(
        color: AppColors.slate900,
      ),
      iconTheme: const IconThemeData(color: AppColors.slate900),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.slate100,
    ),
    textTheme: _buildTextTheme(AppColors.slate100, AppColors.slate400),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.headlineMedium.copyWith(
        color: AppColors.slate100,
      ),
      iconTheme: const IconThemeData(color: AppColors.slate100),
    ),
  );
}
