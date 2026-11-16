import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class LivePulseCountdownBadge extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRefreshing;
  final Color accentColor;
  final bool isDark;
  final int? vehicleCount;
  final VoidCallback? onTap;

  const LivePulseCountdownBadge({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.isRefreshing = false,
    required this.accentColor,
    required this.isDark,
    this.vehicleCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final safeTotal = totalSeconds <= 0 ? 1 : totalSeconds;
    final progress = (remainingSeconds / safeTotal).clamp(0.0, 1.0);
    final labelText = vehicleCount != null
        ? '$vehicleCount · ${remainingSeconds}s'
        : '${remainingSeconds}s';

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? accentColor.withValues(alpha: 0.16)
            : accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: isRefreshing ? null : progress,
                  strokeWidth: 2.0,
                  color: accentColor,
                  backgroundColor: accentColor.withValues(alpha: 0.18),
                ),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          if (vehicleCount != null) ...[
            const SizedBox(width: 5),
            Icon(
              Icons.directions_bus_rounded,
              size: 13,
              color: accentColor,
            ),
          ],
          const SizedBox(width: 4),
          Text(
            labelText,
            style: AppTypography.nunito.copyWith(
              color: isDark ? Colors.white : AppColors.slate800,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return Tooltip(
      message: 'Atualizar agora',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: content,
        ),
      ),
    );
  }
}
