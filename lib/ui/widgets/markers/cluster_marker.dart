import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../system_badge.dart';

class ClusterMarker extends StatelessWidget {
  final int count;
  final bool isDark;
  final double size;
  final bool allMetropolitan;

  const ClusterMarker({
    super.key,
    required this.count,
    required this.isDark,
    this.size = 54.0,
    this.allMetropolitan = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = allMetropolitan
        ? SystemBadge.metropolitanColor
        : AppColors.primary;

    return Container(
      height: 30,
      constraints: BoxConstraints(minWidth: size > 46 ? 46 : size),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.38 : 0.20),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_bus_filled_rounded,
              size: 13,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              count > 99 ? '99+' : '$count',
              style: AppTypography.quicksand.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
