import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class StopMarker extends StatelessWidget {
  final bool isDark;
  final bool isSelected;
  final bool compact;
  final int? badgeNumber;
  final Color? color;
  final double size;

  const StopMarker({
    super.key,
    required this.isDark,
    this.isSelected = false,
    this.compact = false,
    this.badgeNumber,
    this.color,
    this.size = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    final markerColor = color ?? AppColors.primary;

    if (badgeNumber != null) {
      final numberedSize = size + 4;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        width: numberedSize,
        height: numberedSize,
        decoration: BoxDecoration(
          color: markerColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: markerColor.withValues(alpha: isDark ? 0.5 : 0.35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '$badgeNumber',
          style: AppTypography.quicksand.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.0,
          ),
        ),
      );
    }

    if (isSelected) {
      final outerSize = size + 10;
      final innerSize = size + 2;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        width: outerSize,
        height: outerSize,
        decoration: BoxDecoration(
          color: markerColor.withValues(alpha: 0.22),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: innerSize,
          height: innerSize,
          decoration: BoxDecoration(
            color: markerColor,
            borderRadius: BorderRadius.circular(innerSize * 0.32),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: markerColor.withValues(alpha: isDark ? 0.55 : 0.4),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.directions_bus_filled_rounded,
            color: Colors.white,
            size: innerSize * 0.54,
          ),
        ),
      );
    }

    if (compact) {
      const compactSize = 22.0;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: compactSize,
        height: compactSize,
        decoration: BoxDecoration(
          color: markerColor,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: Colors.white, width: 1.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.18),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.directions_bus_filled_rounded,
          color: Colors.white,
          size: 12,
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: markerColor,
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: Colors.white, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.directions_bus_filled_rounded,
        color: Colors.white,
        size: size * 0.54,
      ),
    );
  }
}
