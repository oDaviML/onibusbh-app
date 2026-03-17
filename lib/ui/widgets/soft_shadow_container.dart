import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SoftShadowContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;

  const SoftShadowContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: padding ?? const EdgeInsets.all(16.0),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border:
            border ??
            (isDark
                ? Border.all(color: AppColors.slate700)
                : Border.all(color: AppColors.surfaceLight)),
        boxShadow: [
          BoxShadow(
            color: AppColors.softShadowColor,
            offset: const Offset(0, 10),
            blurRadius: 25,
            spreadRadius: -5,
          ),
          BoxShadow(
            color: AppColors.softShadowSecondaryColor,
            offset: const Offset(0, 8),
            blurRadius: 10,
            spreadRadius: -6,
          ),
        ],
      ),
      child: child,
    );
  }
}
