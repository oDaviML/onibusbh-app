import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/prediction_response_dto.dart';

class LineAccordionTile extends StatelessWidget {
  final PredictionResponseDto prediction;
  final bool isExpanded;
  final VoidCallback onToggle;

  const LineAccordionTile({
    super.key,
    required this.prediction,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nextEta = prediction.nextArrivalMinutes;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isExpanded
            ? prediction.routeColor.withValues(alpha: isDark ? 0.08 : 0.04)
            : (isDark ? AppColors.slate800 : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? prediction.routeColor.withValues(alpha: 0.3)
              : (isDark ? AppColors.slate700 : AppColors.slate200),
          width: isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate900.withValues(alpha: isDark ? 0.1 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                                      color:
                                          Colors.green.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              nextEta != null
                                  ? '~$nextEta min'
                                  : 'Sem previsão',
                              style: AppTypography.nunito.copyWith(
                                fontSize: 13,
                                color: (nextEta ?? 99) <= 5
                                    ? AppColors.primary
                                    : AppColors.slate500,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOutCubic,
                    turns: isExpanded ? 0.5 : 0.0,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isDark ? AppColors.slate400 : AppColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(context, isDark),
            crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeInOutCubic,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, bool isDark) {
    final arrivals = prediction.arrivals.take(3).toList();

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 1,
            color: isDark
                ? AppColors.slate700.withValues(alpha: 0.5)
                : AppColors.slate200,
          ),
          const SizedBox(height: 12),
          Text(
            'PRÓXIMAS CHEGADAS',
            style: AppTypography.nunito.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.slate400,
            ),
          ),
          const SizedBox(height: 10),
          if (arrivals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Sem previsão de chegada no momento',
                style: AppTypography.nunito.copyWith(
                  fontSize: 13,
                  color: AppColors.slate500,
                ),
              ),
            )
          else
            ...arrivals.asMap().entries.map((entry) {
              final index = entry.key;
              final arrival = entry.value;
              return Container(
                margin:
                    EdgeInsets.only(bottom: index < arrivals.length - 1 ? 8 : 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.slate800.withValues(alpha: 0.5)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.slate700 : AppColors.slate100,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: prediction.routeColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.directions_bus_rounded,
                        color: prediction.routeColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            arrival.vehicleId ?? 'Veículo ${index + 1}',
                            style: AppTypography.nunito.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDark ? Colors.white70 : AppColors.slate700,
                            ),
                          ),
                          if (arrival.isStale) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Estimado',
                                style: AppTypography.nunito.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: arrival.etaMinutes <= 5
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : (isDark
                                ? AppColors.slate700
                                : AppColors.slate100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${arrival.etaMinutes} min',
                        style: AppTypography.quicksand.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: arrival.etaMinutes <= 5
                              ? AppColors.primary
                              : (isDark
                                  ? Colors.white70
                                  : AppColors.slate700),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
