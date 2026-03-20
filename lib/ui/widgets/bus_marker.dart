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
    final borderColor = isDark ? Colors.white : Colors.white;
    final iconBgColor = isDark ? Colors.black54 : Colors.white;

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: bearing * math.pi / 180,
          child: Align(
            alignment: Alignment.topCenter,
            child: FractionalTranslation(
              translation: const Offset(0.0, -0.15),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.navigation, color: color, size: 18),
              ),
            ),
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : color.withValues(alpha: 0.4),
                blurRadius: isDark ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.directions_bus,
            color: Colors.white,
            size: 18,
          ),
        ),
      ],
    );
  }
}
