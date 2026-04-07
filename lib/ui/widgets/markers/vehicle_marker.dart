import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class VehicleMarker extends StatelessWidget {
  final Color color;
  final double bearing;
  final bool isDark;
  final double size;

  const VehicleMarker({
    super.key,
    required this.color,
    required this.bearing,
    required this.isDark,
    this.size = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorOffset = size * 0.55;
    final indicatorSize = size * 0.45;

    final angleRad = (bearing - 90) * math.pi / 180;
    final dx = indicatorOffset * math.cos(angleRad);
    final dy = indicatorOffset * math.sin(angleRad);

    return SizedBox(
      width: size + indicatorSize + 4,
      height: size + indicatorSize + 4,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withValues(alpha: 0.85)],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.4)
                      : color.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.directions_bus_rounded,
              color: Colors.white,
              size: size * 0.5,
            ),
          ),
          Positioned(
            left: (size + indicatorSize + 4) / 2 + dx - indicatorSize / 2,
            top: (size + indicatorSize + 4) / 2 + dy - indicatorSize / 2,
            child: Transform.rotate(
              angle: bearing * math.pi / 180,
              child: Container(
                width: indicatorSize,
                height: indicatorSize,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate800 : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: color,
                  size: indicatorSize * 0.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
