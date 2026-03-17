import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/line_summary_dto.dart';
import '../../../widgets/soft_shadow_container.dart';

class LineCard extends StatelessWidget {
  final LineSummaryDto line;
  final VoidCallback onTap;

  const LineCard({
    super.key,
    required this.line,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: SoftShadowContainer(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(16.0),
        border: Border.all(
          color: isDark ? AppColors.slate700 : AppColors.surfaceLight,
        ),
        child: Row(
          children: [
            // Icon / Number
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                line.shortName,
                style: AppTypography.quicksand.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.longName,
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${line.destination} • ${line.stopsRemaining} paradas restantes',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),

            // Time & Arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: line.estimatedMinutes <= 15
                        ? AppColors.primary.withOpacity(0.1)
                        : (isDark ? AppColors.slate700 : AppColors.slate100),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: line.estimatedMinutes <= 15
                            ? AppColors.primary
                            : AppColors.slate500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${line.estimatedMinutes} min',
                        style: AppTypography.quicksand.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: line.estimatedMinutes <= 15
                              ? AppColors.primary
                              : AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.slate300,
                  size: 24,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
