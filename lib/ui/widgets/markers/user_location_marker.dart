import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class UserLocationMarker extends StatefulWidget {
  final double size;
  final bool isDark;

  const UserLocationMarker({
    super.key,
    this.size = 24,
    this.isDark = false,
  });

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
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size + 24, widget.size + 24),
            painter: _UserLocationPainter(
              pulse: _controller.value,
              dotSize: widget.size,
              isDark: widget.isDark,
            ),
          );
        },
      ),
    );
  }
}

class _UserLocationPainter extends CustomPainter {
  final double pulse;
  final double dotSize;
  final bool isDark;

  static const _primaryColor = AppColors.primary;

  _UserLocationPainter({
    required this.pulse,
    required this.dotSize,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final borderColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    final haloRadius = dotSize / 2 + (14 * pulse);
    final haloOpacity = isDark
        ? 0.2 * (1 - pulse * 0.7)
        : 0.3 * (1 - pulse * 0.7);

    final haloPaint = Paint()
      ..color = _primaryColor.withValues(alpha: haloOpacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, haloRadius, haloPaint);

    final innerHaloRadius = dotSize / 2 + (5 * pulse);
    final innerHaloOpacity = isDark
        ? 0.12 * (1 - pulse * 0.5)
        : 0.18 * (1 - pulse * 0.5);

    final innerHaloPaint = Paint()
      ..color = _primaryColor.withValues(alpha: innerHaloOpacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, innerHaloRadius, innerHaloPaint);

    final outerDotPaint = Paint()
      ..color = _primaryColor.withValues(alpha: isDark ? 0.15 : 0.25)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, dotSize / 2 + 2, outerDotPaint);

    final dotPaint = Paint()
      ..color = _primaryColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, dotSize / 2, dotPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, dotSize / 2, borderPaint);
  }

  @override
  bool shouldRepaint(_UserLocationPainter oldDelegate) {
    return oldDelegate.pulse != pulse || oldDelegate.isDark != isDark;
  }
}
