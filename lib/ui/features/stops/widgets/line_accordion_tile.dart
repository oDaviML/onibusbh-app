import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/prediction_response_dto.dart';

class LinePredictionTile extends StatelessWidget {
  final PredictionResponseDto prediction;
  final VoidCallback onTap;

  const LinePredictionTile({
    super.key,
    required this.prediction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate800 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.slate700 : AppColors.slate200,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.slate900.withValues(alpha: isDark ? 0.1 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: prediction.routeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: prediction.routeColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    prediction.shortName,
                    style: AppTypography.quicksand.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prediction.headsign ?? prediction.longName,
                    style: AppTypography.quicksand.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.slate900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (prediction.arrivals.isNotEmpty) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...prediction.arrivals.take(3).map((arrival) {
                          final isClose = arrival.etaMinutes <= 5;
                          final isMedium = arrival.etaMinutes <= 10;
                          return Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isClose
                                  ? AppColors.primary
                                  : (isMedium
                                        ? AppColors.primary.withValues(
                                            alpha: 0.15,
                                          )
                                        : (isDark
                                              ? AppColors.slate700
                                              : AppColors.slate100)),
                              borderRadius: BorderRadius.circular(12),
                              border: isClose
                                  ? null
                                  : Border.all(
                                      color: isMedium
                                          ? AppColors.primary.withValues(
                                              alpha: 0.3,
                                            )
                                          : (isDark
                                                ? AppColors.slate600
                                                : AppColors.slate200),
                                    ),
                            ),
                            child: Text(
                              '${arrival.etaMinutes}min',
                              style: AppTypography.nunito.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isClose
                                    ? Colors.white
                                    : (isMedium
                                          ? AppColors.primary
                                          : AppColors.slate500),
                              ),
                            ),
                          );
                        }),
                      ] else ...[
                        Text(
                          'Sem previsão',
                          style: AppTypography.nunito.copyWith(
                            fontSize: 13,
                            color: AppColors.slate500,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.open_in_full_rounded,
              color: AppColors.slate400,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
