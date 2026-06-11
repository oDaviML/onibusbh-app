import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class VehicleMarker extends StatefulWidget {
  final Color color;
  final double bearing;
  final bool isDark;
  final double size;
  final String? label;

  const VehicleMarker({
    super.key,
    required this.color,
    required this.bearing,
    required this.isDark,
    this.size = 28.0,
    this.label,
  });

  @override
  State<VehicleMarker> createState() => _VehicleMarkerState();
}

class _VehicleMarkerState extends State<VehicleMarker> {
  bool _showLabel = false;

  void _toggleLabel() {
    if (widget.label == null || widget.label!.isEmpty) return;
    setState(() {
      _showLabel = !_showLabel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final indicatorOffset = widget.size * 0.55;
    final indicatorSize = widget.size * 0.45;

    final angleRad = (widget.bearing - 90) * math.pi / 180;
    final dx = indicatorOffset * math.cos(angleRad);
    final dy = indicatorOffset * math.sin(angleRad);

    return GestureDetector(
      onTap: _toggleLabel,
      child: SizedBox(
        width: widget.size + indicatorSize + 4,
        height: widget.size + indicatorSize + 4,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [widget.color, widget.color.withValues(alpha: 0.85)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDark
                        ? Colors.black.withValues(alpha: 0.4)
                        : widget.color.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.directions_bus_rounded,
                color: Colors.white,
                size: widget.size * 0.5,
              ),
            ),
            Positioned(
              left: (widget.size + indicatorSize + 4) / 2 + dx - indicatorSize / 2,
              top: (widget.size + indicatorSize + 4) / 2 + dy - indicatorSize / 2,
              child: Transform.rotate(
                angle: widget.bearing * math.pi / 180,
                child: Container(
                  width: indicatorSize,
                  height: indicatorSize,
                  decoration: BoxDecoration(
                    color: widget.isDark ? AppColors.slate800 : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.color, width: 1.5),
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
                    color: widget.color,
                    size: indicatorSize * 0.6,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -20,
              child: IgnorePointer(
                ignoring: !_showLabel,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  opacity: _showLabel ? 1.0 : 0.0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    scale: _showLabel ? 1.0 : 0.6,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? AppColors.slate800.withValues(alpha: 0.95)
                            : Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: widget.color.withValues(alpha: 0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.label ?? '',
                        style: AppTypography.nunito.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: widget.isDark ? Colors.white : AppColors.slate900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
