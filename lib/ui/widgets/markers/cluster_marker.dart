import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ClusterMarker extends StatelessWidget {
  final int count;
  final bool isDark;
  final double size;

  const ClusterMarker({
    super.key,
    required this.count,
    required this.isDark,
    this.size = 44.0,
  });

  Color get _backgroundColor {
    if (count >= 50) return AppColors.primary;
    if (count >= 20) return AppColors.primary.withValues(alpha: 0.85);
    if (count >= 10) return AppColors.primary.withValues(alpha: 0.7);
    return isDark ? AppColors.slate700 : AppColors.slate100;
  }

  Color get _textColor {
    if (count >= 10) return Colors.white;
    return isDark ? Colors.white : AppColors.slate900;
  }

  Color get _borderColor {
    if (count >= 10) return Colors.white;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = count > 99 ? 13.0 : 16.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _backgroundColor,
            _backgroundColor.withValues(alpha: 0.75),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: _borderColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.25),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : '$count',
          style: AppTypography.quicksand.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: _textColor,
          ),
        ),
      ),
    );
  }
}
