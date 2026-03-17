import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

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
    textTheme: TextTheme(
      displayLarge: AppTypography.display.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.slate900,
      ),
      titleLarge: AppTypography.quicksand.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.slate900,
      ),
      bodyMedium: AppTypography.nunito.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.slate500,
      ),
      labelSmall: AppTypography.nunito.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.slate400,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight.withValues(alpha: 0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.display.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 24,
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
    textTheme: TextTheme(
      displayLarge: AppTypography.display.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.slate100,
      ),
      titleLarge: AppTypography.quicksand.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.surfaceLight,
      ),
      bodyMedium: AppTypography.nunito.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.slate400,
      ),
      labelSmall: AppTypography.nunito.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.slate500,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.display.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 24,
        color: AppColors.slate100,
      ),
      iconTheme: const IconThemeData(color: AppColors.slate100),
    ),
  );
}
