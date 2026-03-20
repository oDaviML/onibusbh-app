import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

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

class MapControlButton extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String? tooltip;
  final VoidCallback onPressed;

  const MapControlButton({
    super.key,
    required this.isDark,
    required this.icon,
    this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.slate900.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        color: isDark ? Colors.white : AppColors.slate900,
        iconSize: 20,
        onPressed: onPressed,
      ),
    );
  }
}

class MapControlsColumn extends StatelessWidget {
  final bool isDark;
  final VoidCallback onCenterRoute;
  final VoidCallback onCenterUser;
  final VoidCallback onCenterStop;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final AnimationController animation;

  const MapControlsColumn({
    super.key,
    required this.isDark,
    required this.onCenterRoute,
    required this.onCenterUser,
    required this.onCenterStop,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MapControlButton(
            isDark: isDark,
            icon: Icons.route_rounded,
            tooltip: 'Centralizar na rota',
            onPressed: onCenterRoute,
          ),
          const SizedBox(height: 12),
          MapControlButton(
            isDark: isDark,
            icon: Icons.my_location_rounded,
            tooltip: 'Minha localização',
            onPressed: onCenterUser,
          ),
          const SizedBox(height: 12),
          MapControlButton(
            isDark: isDark,
            icon: Icons.place_rounded,
            tooltip: 'Centralizar na parada',
            onPressed: onCenterStop,
          ),
          const SizedBox(height: 12),
          Container(
            width: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate900 : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.slate900.withValues(
                    alpha: isDark ? 0.3 : 0.08,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  color: isDark ? Colors.white : AppColors.slate900,
                  iconSize: 20,
                  onPressed: onZoomIn,
                ),
                Container(
                  height: 1,
                  width: 24,
                  color: isDark ? AppColors.slate800 : AppColors.slate200,
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  color: isDark ? Colors.white : AppColors.slate900,
                  iconSize: 20,
                  onPressed: onZoomOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
