import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MapControlButton extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String? tooltip;
  final VoidCallback onPressed;
  final double size;

  const MapControlButton({
    super.key,
    required this.isDark,
    required this.icon,
    this.tooltip,
    required this.onPressed,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Ink(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate900 : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.slate900.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white : AppColors.slate900,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class MapZoomControls extends StatelessWidget {
  final bool isDark;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final double width;

  const MapZoomControls({
    super.key,
    required this.isDark,
    required this.onZoomIn,
    required this.onZoomOut,
    this.width = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(width / 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate900.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
    );
  }
}

class MapControlsColumn extends StatelessWidget {
  final bool isDark;
  final VoidCallback onCenterRoute;
  final VoidCallback? onCenterUser;
  final VoidCallback? onCenterStop;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final bool showRouteButton;
  final bool showStopButton;

  const MapControlsColumn({
    super.key,
    required this.isDark,
    required this.onCenterRoute,
    this.onCenterUser,
    this.onCenterStop,
    required this.onZoomIn,
    required this.onZoomOut,
    this.showRouteButton = true,
    this.showStopButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(-20 * (1 - progress), 0),
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showRouteButton) ...[
            MapControlButton(
              isDark: isDark,
              icon: Icons.route_rounded,
              tooltip: 'Centralizar na rota',
              onPressed: onCenterRoute,
            ),
            const SizedBox(height: 12),
          ],
          if (onCenterUser != null) ...[
            MapControlButton(
              isDark: isDark,
              icon: Icons.my_location_rounded,
              tooltip: 'Minha localização',
              onPressed: onCenterUser!,
            ),
            const SizedBox(height: 12),
          ],
          if (showStopButton && onCenterStop != null) ...[
            MapControlButton(
              isDark: isDark,
              icon: Icons.place_rounded,
              tooltip: 'Centralizar na parada',
              onPressed: onCenterStop!,
            ),
            const SizedBox(height: 12),
          ],
          MapZoomControls(
            isDark: isDark,
            onZoomIn: onZoomIn,
            onZoomOut: onZoomOut,
          ),
        ],
      ),
    );
  }
}
