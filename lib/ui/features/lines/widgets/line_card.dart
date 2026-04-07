import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/line_summary_dto.dart';
import '../../../../data/providers/favorites_providers.dart';
import '../../../widgets/soft_shadow_container.dart';

class LineCard extends ConsumerStatefulWidget {
  final LineSummaryDto line;
  final VoidCallback onTap;

  const LineCard({super.key, required this.line, required this.onTap});

  @override
  ConsumerState<LineCard> createState() => _LineCardState();
}

class _LineCardState extends ConsumerState<LineCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heartController;
  late final Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartScale =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
        ]).animate(
          CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final favoriteLines = ref.watch(favoriteLinesProvider);
    final isFav = favoriteLines.any((e) => e.routeId == widget.line.routeId);

    return GestureDetector(
      onTap: widget.onTap,
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
                color: widget.line.routeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.line.routeColor.withValues(alpha: 0.3),
                    spreadRadius: 0,
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
                    widget.line.shortName,
                    style: AppTypography.busNumber.copyWith(
                      color: widget.line.routeTextColor,
                    ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.line.longName,
                          style: theme.textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ScaleTransition(
                        scale: _heartScale,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: IconButton(
                            key: ValueKey(isFav),
                            onPressed: () {
                              ref
                                  .read(favoriteLinesProvider.notifier)
                                  .toggleFavorite(widget.line);
                              _heartController.forward(from: 0);
                            },
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_outline,
                              color: isFav ? Colors.red : AppColors.slate400,
                            ),
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (widget.line.isBidirectional) ...[
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 14,
                          color: AppColors.slate500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Bidirecional',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.slate500,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (widget.line.avgTravelTime > 0)
                        Text(
                          '~${widget.line.avgTravelTime} min',
                          style: theme.textTheme.labelMedium?.copyWith(
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
