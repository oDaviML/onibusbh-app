import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/prediction_response_dto.dart';
import '../../../widgets/soft_shadow_container.dart';

class PredictionCard extends StatelessWidget {
  final PredictionResponseDto prediction;

  const PredictionCard({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nextEta = prediction.nextArrivalMinutes;

    return SoftShadowContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      border: Border.all(
        color: isDark ? AppColors.slate700 : AppColors.surfaceLight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: prediction.routeColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: prediction.routeColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              prediction.shortName,
              style: AppTypography.quicksand.copyWith(
                color: Colors.white,
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
                Text(
                  prediction.headsign ?? prediction.longName,
                  style: AppTypography.quicksand.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (prediction.arrivals.isNotEmpty)
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
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
                      const SizedBox(width: 6),
                      Text(
                        '${prediction.arrivals.length} veículo(s) rastreado(s)',
                        style: AppTypography.nunito.copyWith(
                          fontSize: 12,
                          color: AppColors.slate500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          if (nextEta != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$nextEta',
                  style: AppTypography.quicksand.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: nextEta <= 5
                        ? AppColors.primary
                        : (isDark ? Colors.white : AppColors.slate900),
                    height: 1.0,
                  ),
                ),
                Text(
                  'min',
                  style: AppTypography.nunito.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate400,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
