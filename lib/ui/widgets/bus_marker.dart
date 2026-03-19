import 'dart:math' as math;
import 'package:flutter/material.dart';

class BusMarker extends StatelessWidget {
  final Color color;
  final double bearing;
  final String shortName;

  const BusMarker({
    super.key,
    required this.color,
    required this.bearing,
    required this.shortName,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: bearing * math.pi / 180,
          child: Align(
            alignment: Alignment.topCenter,
            child: FractionalTranslation(
              translation: const Offset(0.0, -0.1),
              child: Icon(Icons.eject, color: color, size: 20),
            ),
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
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
