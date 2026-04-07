import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../widgets/map/map_controls.dart';

class ArrivalBubble extends StatelessWidget {
  final int minutes;
  final double size;
  final bool isPrimary;
  final Color color;
  final bool isDark;
  final int delay;
  final AnimationController animation;

  const ArrivalBubble({
    super.key,
    required this.minutes,
    required this.size,
    required this.isPrimary,
    required this.color,
    required this.isDark,
    required this.delay,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = size * 0.32;
    final labelSize = size * 0.15;

    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: Interval(delay / 600, 1.0, curve: Curves.easeOutBack),
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isPrimary
              ? color
              : (isDark ? AppColors.slate800 : Colors.white),
          shape: BoxShape.circle,
          border: isPrimary
              ? null
              : Border.all(color: color.withValues(alpha: 0.2), width: 2),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? color.withValues(alpha: 0.4)
                  : AppColors.slate900.withValues(alpha: 0.1),
              blurRadius: isPrimary ? 20 : 16,
              offset: Offset(0, isPrimary ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$minutes',
              style: AppTypography.quicksand.copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? Colors.white : AppColors.slate900),
                height: 1.0,
              ),
            ),
            Text(
              'MIN',
              style: AppTypography.nunito.copyWith(
                fontSize: labelSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppColors.slate400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArrivalBubblesColumn extends StatelessWidget {
  final List<int> arrivals;
  final Color color;
  final bool isDark;
  final AnimationController animation;
  final VoidCallback onClose;

  const ArrivalBubblesColumn({
    super.key,
    required this.arrivals,
    required this.color,
    required this.isDark,
    required this.animation,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (arrivals.isNotEmpty) ...[
          ArrivalBubble(
            minutes: arrivals[0],
            size: 80,
            isPrimary: true,
            color: color,
            isDark: isDark,
            delay: 0,
            animation: animation,
          ),
          if (arrivals.length > 1) ...[
            const SizedBox(height: 12),
            ArrivalBubble(
              minutes: arrivals[1],
              size: 64,
              isPrimary: false,
              color: color,
              isDark: isDark,
              delay: 100,
              animation: animation,
            ),
          ],
          if (arrivals.length > 2) ...[
            const SizedBox(height: 10),
            ArrivalBubble(
              minutes: arrivals[2],
              size: 56,
              isPrimary: false,
              color: color,
              isDark: isDark,
              delay: 200,
              animation: animation,
            ),
          ],
        ] else ...[
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.slate900.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '--',
                style: AppTypography.quicksand.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate400,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        MapControlButton(
          isDark: isDark,
          icon: Icons.close_rounded,
          tooltip: 'Fechar',
          onPressed: onClose,
        ),
      ],
    );
  }
}
