import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/line_summary_dto.dart';
import '../../../../data/providers/favorites_providers.dart';
import '../../../widgets/soft_shadow_container.dart';

class LineCard extends ConsumerWidget {
  final LineSummaryDto line;
  final VoidCallback onTap;

  const LineCard({super.key, required this.line, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFav = ref.watch(favoriteLinesProvider.notifier).isFavorite(line.routeId);

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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: line.routeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: line.routeColor.withValues(alpha: 0.3),
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
                  color: line.routeTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          line.longName,
                          style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(favoriteLinesProvider.notifier).toggleFavorite(line);
                        },
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_outline,
                          color: isFav ? Colors.red : AppColors.slate400,
                        ),
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.slate700 : AppColors.slate100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: AppColors.slate500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${line.stopCount} paradas',
                              style: AppTypography.quicksand.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.slate500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (line.isBidirectional) ...[
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 14,
                          color: AppColors.slate500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Bidirecional',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: AppColors.slate500,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (line.avgTravelTime > 0)
                        Text(
                          '~${line.avgTravelTime} min',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: AppColors.slate500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
