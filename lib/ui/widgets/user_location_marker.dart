import 'package:flutter/material.dart';

class UserLocationMarker extends StatefulWidget {
  final double size;

  const UserLocationMarker({super.key, this.size = 24});

  @override
  State<UserLocationMarker> createState() => _UserLocationMarkerState();
}

class _UserLocationMarkerState extends State<UserLocationMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size + 24, widget.size + 24),
          painter: _UserLocationPainter(
            pulse: _controller.value,
            dotSize: widget.size,
          ),
        );
      },
    );
  }
}

class _UserLocationPainter extends CustomPainter {
  final double pulse;
  final double dotSize;

  _UserLocationPainter({required this.pulse, required this.dotSize});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final haloRadius = dotSize / 2 + (12 * pulse);
    final haloOpacity = 0.35 * (1 - pulse * 0.6);

    final haloPaint = Paint()
      ..color = const Color(0xFF2196F3).withValues(alpha: haloOpacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, haloRadius, haloPaint);

    final innerHaloRadius = dotSize / 2 + (4 * pulse);
    final innerHaloOpacity = 0.2 * (1 - pulse * 0.5);

    final innerHaloPaint = Paint()
      ..color = const Color(0xFF2196F3).withValues(alpha: innerHaloOpacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, innerHaloRadius, innerHaloPaint);

    final outerDotPaint = Paint()
      ..color = const Color(0xFF2196F3).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, dotSize / 2 + 2, outerDotPaint);

    final dotPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, dotSize / 2, dotPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, dotSize / 2, borderPaint);

    final shadowPaint = Paint()
      ..color = const Color(0xFF2196F3).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(center, dotSize / 2, shadowPaint);
  }

  @override
  bool shouldRepaint(_UserLocationPainter oldDelegate) {
    return oldDelegate.pulse != pulse;
  }
}
