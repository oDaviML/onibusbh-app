import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/prediction_group.dart';
import '../../../../data/models/prediction_response_dto.dart';

class PredictionAccordionTile extends StatefulWidget {
  final PredictionGroup group;
  final ValueChanged<PredictionResponseDto> onTap;

  const PredictionAccordionTile({
    super.key,
    required this.group,
    required this.onTap,
  });

  @override
  State<PredictionAccordionTile> createState() =>
      _PredictionAccordionTileState();
}

class _PredictionAccordionTileState extends State<PredictionAccordionTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _rotation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final group = widget.group;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: group.routeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: group.routeColor.withValues(alpha: 0.3),
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
                          group.shortName,
                          style: AppTypography.busNumber.copyWith(
                            color: Colors.white,
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
                          group.longName,
                          style: AppTypography.titleMedium.copyWith(
                            color: isDark ? Colors.white : AppColors.slate900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (group.allArrivals.isNotEmpty) ...[
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ...group.allArrivals.take(3).map((arrival) {
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
                                    style: AppTypography.caption.copyWith(
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
                                'Sem previs\u00e3o',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.slate500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  RotationTransition(
                    turns: _rotation,
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: AppColors.slate400,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(isDark),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(bool isDark) {
    final group = widget.group;
    final sortedKeys = group.directions.keys.toList()..sort();

    return Column(
      children: [
        Divider(
          height: 1,
          color: isDark ? AppColors.slate700 : AppColors.slate200,
        ),
        ...sortedKeys.map((dir) {
          final prediction = group.directions[dir]!;
          final label = dir == 0 ? 'Ida' : 'Volta';
          final icon = dir == 0
              ? Icons.arrow_forward_rounded
              : Icons.arrow_back_rounded;

          return GestureDetector(
            onTap: () => widget.onTap(prediction),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: group.routeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 16, color: group.routeColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              label,
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.slate500,
                              ),
                            ),
                            if (prediction.headsign != null) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.slate700
                                      : AppColors.slate100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  prediction.headsign!,
                                  style: AppTypography.caption.copyWith(
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.slate900,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (prediction.arrivals.isNotEmpty) ...[
                              ...prediction.arrivals.take(2).map((arrival) {
                                final isClose = arrival.etaMinutes <= 5;
                                final isMedium = arrival.etaMinutes <= 10;
                                return Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
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
                                    borderRadius: BorderRadius.circular(10),
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
                                    style: AppTypography.caption.copyWith(
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
                                'Sem previs\u00e3o',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.slate500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.slate400,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
      ],
    );
  }
}
