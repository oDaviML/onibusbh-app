import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/prediction_response_dto.dart';
import '../../../widgets/soft_shadow_container.dart';
import '../../../widgets/system_badge.dart';

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
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  prediction.shortName,
                  style: AppTypography.busNumber.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        prediction.headsign ?? prediction.longName,
                        style: AppTypography.titleLarge,
                      ),
                    ),
                    if (prediction.isMetropolitan) ...[
                      const SizedBox(width: 6),
                      const SystemBadge(isMetropolitan: true, compact: true),
                    ],
                  ],
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
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.slate500,
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
                  nextEta <= 0 ? 'Agora' : '$nextEta',
                  style: AppTypography.etaLarge.copyWith(
                    fontSize: nextEta <= 0 ? 22 : null,
                    color: nextEta <= 5
                        ? AppColors.primary
                        : (isDark ? Colors.white : AppColors.slate900),
                  ),
                ),
                if (nextEta > 0)
                  Text(
                    'min',
                    style: AppTypography.bodyMedium.copyWith(
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
