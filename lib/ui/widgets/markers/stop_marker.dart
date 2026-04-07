import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StopMarker extends StatelessWidget {
  final bool isDark;
  final bool isSelected;
  final Color? color;
  final double size;

  const StopMarker({
    super.key,
    required this.isDark,
    this.isSelected = false,
    this.color,
    this.size = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    final markerColor = color ?? AppColors.primary;
    final actualSize = isSelected ? size + 8 : size;
    final borderWidth = isSelected ? 3.0 : 2.0;
    final iconSize = isSelected ? 20.0 : 16.0;
    final blurRadius = isSelected ? 12.0 : 8.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      width: actualSize,
      height: actualSize,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  markerColor,
                  markerColor.withValues(alpha: 0.85),
                ],
              )
            : null,
        color: isSelected ? null : (isDark ? AppColors.slate800 : Colors.white),
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.white : markerColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? markerColor.withValues(alpha: 0.5)
                : markerColor.withValues(alpha: isDark ? 0.35 : 0.2),
            blurRadius: blurRadius,
            spreadRadius: isSelected ? 1.0 : 0.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.location_on_rounded,
        color: isSelected ? Colors.white : markerColor,
        size: iconSize,
      ),
    );
  }
}
