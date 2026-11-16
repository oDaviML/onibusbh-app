import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/line_summary_dto.dart';
import '../../../../data/models/line_variant_dto.dart';
import '../../../../data/models/direction_variants_dto.dart';
import '../../../../data/providers/line_providers.dart';
import '../../../../data/providers/favorites_providers.dart';
import '../../../widgets/soft_shadow_container.dart';
import '../../../widgets/system_badge.dart';

class LineCard extends ConsumerStatefulWidget {
  final LineSummaryDto line;

  const LineCard({super.key, required this.line});

  @override
  ConsumerState<LineCard> createState() => _LineCardState();
}

class _LineCardState extends ConsumerState<LineCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _heartController;
  late final Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartScale = TweenSequence<double>([
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

  void _onVariantTap(
    int directionId,
    LineVariantDto variant, {
    int initialTabIndex = 0,
  }) {
    context.go('/lines/details', extra: {
      'line': widget.line,
      'tripId': variant.tripId ?? '',
      'direction': directionId,
      'variantLabel': variant.variantLabel,
      'initialTabIndex': initialTabIndex,
    });
  }

  IconData _variantIcon(String variantLabel) {
    if (variantLabel == 'PRINCIPAL') return Icons.route_rounded;
    final lower = variantLabel.toLowerCase();
    if (lower.contains('paradora')) return Icons.directions_walk_rounded;
    if (lower.contains('expressa')) return Icons.speed_rounded;
    return Icons.alt_route_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final favoriteLines = ref.watch(favoriteLinesProvider);
    final isFav = favoriteLines.any((e) => e.routeId == widget.line.routeId);
    final routeColor = widget.line.routeColor;

    return SoftShadowContainer(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: EdgeInsets.zero,
      border: Border.all(
        color: isDark ? AppColors.slate700 : AppColors.surfaceLight,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: _isExpanded
                  ? Radius.zero
                  : const Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: routeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: routeColor.withValues(alpha: 0.3),
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
                  const SizedBox(width: 14),
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
                                    ScaleTransition(
                                  scale: animation,
                                  child: child,
                                ),
                                child: IconButton(
                                  key: ValueKey(isFav),
                                  onPressed: () {
                                    ref
                                        .read(favoriteLinesProvider.notifier)
                                        .toggleFavorite(widget.line);
                                    _heartController.forward(from: 0);
                                  },
                                  icon: Icon(
                                    isFav
                                        ? Icons.favorite
                                        : Icons.favorite_outline,
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
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SystemBadge(
                              isMetropolitan: widget.line.isMetropolitan,
                              compact: true,
                            ),
                            if (widget.line.formattedPrice != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.slate800
                                      : AppColors.slate100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.line.formattedPrice!,
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 10,
                                    color: isDark
                                        ? AppColors.slate300
                                        : AppColors.slate600,
                                  ),
                                ),
                              ),
                            if (widget.line.directions.isNotEmpty)
                              Text(
                                '${widget.line.directions.length} ${widget.line.directions.length == 1 ? 'sentido' : 'sentidos'}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.slate500,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? AppColors.slate700 : AppColors.slate200,
            ),
            _buildExpandedContent(isDark, routeColor),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedContent(bool isDark, Color routeColor) {
    final variantsAsync = ref.watch(lineVariantsProvider(widget.line.routeId));

    return variantsAsync.when(
      data: (directions) {
        if (directions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Nenhum itinerário disponível para esta linha.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.slate500,
                ),
              ),
            ),
          );
        }
        return _buildVariantsTimeline(directions, isDark, routeColor);
      },
      loading: () => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: AppColors.slate400,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                'Erro ao carregar',
                style: AppTypography.caption.copyWith(
                  color: AppColors.slate500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVariantsTimeline(
    List<DirectionVariantsDto> directions,
    bool isDark,
    Color routeColor,
  ) {
    final items = <_TimelineItem>[];

    for (final direction in directions) {
      if (direction.variants.isEmpty) continue;
      items.add(_TimelineItem(
        type: _TimelineItemType.direction,
        directionId: direction.directionId,
        headsign: direction.headsign.isNotEmpty
            ? direction.headsign
            : (direction.directionId == 0 ? 'Sentido Ida' : 'Sentido Volta'),
      ));
      for (final variant in direction.variants) {
        items.add(_TimelineItem(
          type: _TimelineItemType.variant,
          directionId: direction.directionId,
          variant: variant,
        ));
      }
    }

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Nenhum sentido disponível',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.slate500,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++)
            _buildTimelineRow(
              items[i],
              isFirst: i == 0,
              isLast: i == items.length - 1,
              isDark: isDark,
              routeColor: routeColor,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(
    _TimelineItem item, {
    required bool isFirst,
    required bool isLast,
    required bool isDark,
    required Color routeColor,
  }) {
    final isDirection = item.type == _TimelineItemType.direction;
    final showBottomLine = !isLast;
    final lineColor = routeColor.withValues(alpha: 0.3);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                if (isFirst)
                  SizedBox(height: isDirection ? 6 : 10)
                else
                  Container(
                    width: 2,
                    height: isDirection ? 6 : 10,
                    color: lineColor,
                  ),
                Container(
                  width: isDirection ? 10 : 8,
                  height: isDirection ? 10 : 8,
                  decoration: BoxDecoration(
                    color: isDirection
                        ? routeColor
                        : routeColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: isDirection
                        ? null
                        : Border.all(color: routeColor, width: 1.5),
                  ),
                ),
                if (showBottomLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isDirection ? 6 : 10,
                top: isDirection ? 2 : 0,
              ),
              child: isDirection
                  ? Text(
                      item.headsign!,
                      style: AppTypography.labelMedium.copyWith(
                        color: routeColor,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : _buildVariantRow(
                      item.variant!,
                      item.directionId,
                      isDark,
                      routeColor,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantRow(
    LineVariantDto variant,
    int directionId,
    bool isDark,
    Color routeColor,
  ) {
    final hasVehicles = (variant.vehicleCount ?? 0) > 0;

    return InkWell(
      onTap: () => _onVariantTap(directionId, variant, initialTabIndex: 0),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    _variantIcon(variant.variantLabel),
                    size: 16,
                    color: hasVehicles ? routeColor : AppColors.slate400,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        variant.displayName,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark ? Colors.white : AppColors.slate900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (variant.headsign != null &&
                          variant.variantLabel != 'PRINCIPAL')
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            variant.headsign!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.slate500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: hasVehicles
                        ? Colors.green.withValues(alpha: 0.12)
                        : (isDark ? AppColors.slate800 : AppColors.slate100),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.directions_bus_rounded,
                        size: 12,
                        color: hasVehicles ? Colors.green : AppColors.slate400,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${variant.vehicleCount ?? 0}',
                        style: AppTypography.caption.copyWith(
                          color: hasVehicles
                              ? Colors.green.shade700
                              : AppColors.slate400,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildVariantActionPill(
                    icon: Icons.map_outlined,
                    label: 'Mapa',
                    iconColor: routeColor,
                    textColor: routeColor,
                    backgroundColor: routeColor.withValues(alpha: 0.10),
                    onTap: () => _onVariantTap(
                      directionId,
                      variant,
                      initialTabIndex: 0,
                    ),
                  ),
                  _buildVariantActionPill(
                    icon: Icons.schedule_rounded,
                    label: 'Horários',
                    iconColor: isDark
                        ? AppColors.slate300
                        : AppColors.slate700,
                    textColor: isDark
                        ? AppColors.slate200
                        : AppColors.slate700,
                    backgroundColor: isDark
                        ? AppColors.slate800
                        : AppColors.slate100,
                    onTap: () => _onVariantTap(
                      directionId,
                      variant,
                      initialTabIndex: 1,
                    ),
                  ),
                  _buildVariantActionPill(
                    icon: Icons.route_outlined,
                    label: 'Itinerário',
                    iconColor: routeColor,
                    textColor: routeColor,
                    backgroundColor: routeColor.withValues(alpha: 0.12),
                    onTap: () => _onVariantTap(
                      directionId,
                      variant,
                      initialTabIndex: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantActionPill({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color textColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _TimelineItemType { direction, variant }

class _TimelineItem {
  final _TimelineItemType type;
  final int directionId;
  final String? headsign;
  final LineVariantDto? variant;

  _TimelineItem({
    required this.type,
    required this.directionId,
    this.headsign,
    this.variant,
  });
}
