import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/line_summary_dto.dart';
import '../../../../data/models/line_variant_dto.dart';
import '../../../../data/models/direction_variants_dto.dart';
import '../../../../data/providers/line_providers.dart';
import '../../../widgets/scaffold_with_nav_bar.dart';
import '../../../widgets/soft_shadow_container.dart';

class DirectionSelectionModal extends ConsumerStatefulWidget {
  final LineSummaryDto line;

  const DirectionSelectionModal({super.key, required this.line});

  static void show(BuildContext context, LineSummaryDto line) {
    ScaffoldWithNavBar.forceHide.value = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DirectionSelectionModal(line: line),
    ).whenComplete(() {
      ScaffoldWithNavBar.forceHide.value = false;
    });
  }

  @override
  ConsumerState<DirectionSelectionModal> createState() =>
      _DirectionSelectionModalState();
}

class _DirectionSelectionModalState
    extends ConsumerState<DirectionSelectionModal> {
  int _selectedDirectionId = 0;

  void _navigateToMap(LineVariantDto variant) {
    Navigator.of(context).pop();
    context.go('/lines/details', extra: {
      'line': widget.line,
      'tripId': variant.tripId ?? '',
      'direction': _selectedDirectionId,
      'variantLabel': variant.variantLabel,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final variantsAsync = ref.watch(
      lineVariantsProvider(widget.line.routeId),
    );

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.slate300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.line.routeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.line.routeColor.withValues(alpha: 0.3),
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
                      style: AppTypography.titleLarge.copyWith(
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
                    Text(
                      'Selecionar Trajeto',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.slate500,
                      ),
                    ),
                    Text(
                      widget.line.longName,
                      style: AppTypography.headlineMedium.copyWith(
                        color: isDark ? Colors.white : AppColors.slate900,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: AppColors.slate400),
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.slate800
                      : AppColors.slate100,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Variants list with direction tabs
          variantsAsync.when(
            data: (directions) {
              if (directions.isEmpty) {
                return _buildEmptyState(isDark, 'Nenhuma variante disponível');
              }

              // If there are multiple directions, show tabs
              final hasMultipleDirections = directions.length > 1;
              final selectedDirection = directions.firstWhere(
                (d) => d.directionId == _selectedDirectionId,
                orElse: () => directions.first,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasMultipleDirections) ...[
                    _buildDirectionTabs(isDark, directions),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    'Trajetos',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark ? Colors.white : AppColors.slate900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...selectedDirection.variants.map(
                    (v) => _buildVariantCard(v, isDark),
                  ),
                ],
              );
            },
            loading: () => _buildLoadingState(isDark),
            error: (error, _) => _buildErrorState(isDark, error),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionTabs(
    bool isDark,
    List<DirectionVariantsDto> directions,
  ) {
    return SoftShadowContainer(
      padding: const EdgeInsets.all(4),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: directions.map((direction) {
          final isActive = _selectedDirectionId == direction.directionId;
          return Expanded(
            child: _DirectionChip(
              label: direction.headsign,
              isActive: isActive,
              onTap: () => setState(() => _selectedDirectionId = direction.directionId),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVariantCard(LineVariantDto variant, bool isDark) {
    final hasVehicles = (variant.vehicleCount ?? 0) > 0;
    final vehicleText = hasVehicles
        ? '${variant.vehicleCount} ${variant.vehicleCount == 1 ? 'ônibus' : 'ônibus'}'
        : 'Sem ônibus agora';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _navigateToMap(variant),
        child: Opacity(
          opacity: hasVehicles ? 1.0 : 0.55,
          child: SoftShadowContainer(
            padding: const EdgeInsets.all(16),
            backgroundColor: isDark
                ? AppColors.slate800
                : AppColors.surfaceLight,
            border: Border.all(
              color: isDark ? AppColors.slate700 : AppColors.slate200,
              width: 1,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: hasVehicles
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : (isDark
                            ? AppColors.slate700
                            : AppColors.slate100),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _variantIcon(variant.variantLabel),
                    color: hasVehicles
                        ? AppColors.primary
                        : AppColors.slate500,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        variant.displayName,
                        style: AppTypography.titleMedium.copyWith(
                          color: isDark
                              ? Colors.white
                              : AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vehicleText,
                        style: AppTypography.caption.copyWith(
                          color: hasVehicles
                              ? AppColors.primary
                              : AppColors.slate500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.slate400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trajetos',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? Colors.white : AppColors.slate900,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(3, (_) => _buildShimmerCard(isDark)),
      ],
    );
  }

  Widget _buildShimmerCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.slate700 : AppColors.slate200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate700 : AppColors.slate100,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate700 : AppColors.slate100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate700 : AppColors.slate100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.directions_off_rounded,
              size: 40,
              color: AppColors.slate400,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark, Object error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.slate400,
            ),
            const SizedBox(height: 12),
            Text(
              'Erro ao buscar trajetos',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.slate500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTypography.caption.copyWith(
                color: AppColors.slate400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => ref.invalidate(
                lineVariantsProvider(widget.line.routeId),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _variantIcon(String variantLabel) {
    if (variantLabel == 'PRINCIPAL') return Icons.directions_rounded;
    final lower = variantLabel.toLowerCase();
    if (lower.contains('paradora')) return Icons.directions_walk_rounded;
    if (lower.contains('zoologico')) return Icons.pets_rounded;
    return Icons.directions_bus_rounded;
  }
}

class _DirectionChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DirectionChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? AppColors.slate700 : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.titleMedium.copyWith(
              color: isActive
                  ? (isDark ? Colors.white : AppColors.primary)
                  : (isDark ? AppColors.slate400 : AppColors.slate500),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
