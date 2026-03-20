import 'dart:math' as math;
import 'package:flutter/material.dart';

class BusMarker extends StatelessWidget {
  final Color color;
  final double bearing;
  final String shortName;
  final bool isDark;

  const BusMarker({
    super.key,
    required this.color,
    required this.bearing,
    required this.shortName,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    const busSize = 32.0;
    const orbitRadius = 17.0;
    const indicatorSize = 14.0;

    final angleRad = (bearing - 90) * math.pi / 180;
    final dx = orbitRadius * math.cos(angleRad);
    final dy = orbitRadius * math.sin(angleRad);

    final indicatorBg = isDark
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.white;

    return SizedBox(
      width: busSize + indicatorSize + 4,
      height: busSize + indicatorSize + 4,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: busSize,
            height: busSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.5)
                      : color.withValues(alpha: 0.4),
                  blurRadius: isDark ? 10 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_bus,
              color: Colors.white,
              size: 16,
            ),
          ),
          Positioned(
            left: (busSize + indicatorSize + 4) / 2 + dx - indicatorSize / 2,
            top: (busSize + indicatorSize + 4) / 2 + dy - indicatorSize / 2,
            child: Transform.rotate(
              angle: bearing * math.pi / 180,
              child: Container(
                width: indicatorSize,
                height: indicatorSize,
                decoration: BoxDecoration(
                  color: indicatorBg,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_upward_rounded, color: color, size: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
