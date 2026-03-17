import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/line_summary_dto.dart';
import '../../../widgets/scaffold_with_nav_bar.dart';
import '../../../widgets/soft_shadow_container.dart';

class DirectionSelectionModal extends StatefulWidget {
  final LineSummaryDto line;

  const DirectionSelectionModal({super.key, required this.line});

  static void show(BuildContext context, LineSummaryDto line) {
    if (!line.isBidirectional) {
      context.go('/lines/details', extra: {
        'line': line,
        'direction': 0,
      });
      return;
    }

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
  State<DirectionSelectionModal> createState() =>
      _DirectionSelectionModalState();
}

class _DirectionSelectionModalState extends State<DirectionSelectionModal> {
  int? _selectedDirection;

  void _navigateToMap(int direction) {
    Navigator.of(context).pop();
    context.go('/lines/details', extra: {
      'line': widget.line,
      'direction': direction,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                      style: AppTypography.quicksand.copyWith(
                        color: widget.line.routeTextColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
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
                      'Selecionar Sentido',
                      style: AppTypography.nunito.copyWith(
                        color: AppColors.slate500,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.line.longName,
                      style: AppTypography.quicksand.copyWith(
                        color: isDark ? Colors.white : AppColors.slate900,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: AppColors.slate400),
                style: IconButton.styleFrom(
                  backgroundColor:
                      isDark ? AppColors.slate800 : AppColors.slate100,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 32),

          _buildDirectionOption(
            context: context,
            title: 'Sentido 0 — Ida',
            subtitle: widget.line.longName,
            directionIndex: 0,
          ),
          const SizedBox(height: 16),

          _buildDirectionOption(
            context: context,
            title: 'Sentido 1 — Volta',
            subtitle: widget.line.longName,
            directionIndex: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required int directionIndex,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = _selectedDirection == directionIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDirection = directionIndex;
        });
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) _navigateToMap(directionIndex);
        });
      },
      child: SoftShadowContainer(
        padding: const EdgeInsets.all(20),
        backgroundColor: isActive
            ? AppColors.primary.withValues(alpha: 0.05)
            : (isDark ? AppColors.slate800 : AppColors.surfaceLight),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.3)
              : (isDark ? AppColors.slate700 : AppColors.slate200),
          width: isActive ? 2 : 1,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : (isDark ? AppColors.slate700 : AppColors.slate100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                directionIndex == 0
                    ? Icons.arrow_forward_rounded
                    : Icons.arrow_back_rounded,
                color: isActive ? AppColors.primary : AppColors.slate500,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.quicksand.copyWith(
                      color: isDark ? Colors.white : AppColors.slate900,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.nunito.copyWith(
                      color: AppColors.slate500,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
    );
  }
}
