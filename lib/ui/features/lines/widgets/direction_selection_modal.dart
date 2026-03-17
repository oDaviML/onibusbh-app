import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/line_summary_dto.dart';
import '../../../widgets/soft_shadow_container.dart';

class DirectionSelectionModal extends StatelessWidget {
  final LineSummaryDto line;

  const DirectionSelectionModal({
    super.key,
    required this.line,
  });

  static void show(BuildContext context, LineSummaryDto line) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DirectionSelectionModal(line: line),
    );
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
          )
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
          // Drag handle
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
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  line.shortName,
                  style: AppTypography.quicksand.copyWith(
                    color: Colors.white,
                    fontSize: 20,
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
                      'Selecionar Direção',
                      style: AppTypography.nunito.copyWith(
                        color: AppColors.slate500,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      line.longName,
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
                  backgroundColor: isDark ? AppColors.slate800 : AppColors.slate100,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Direction 1 Options
          _buildDirectionOption(
            context: context,
            title: line.destination,
            subtitle: 'Via Avenida Afonso Pena • 24 paradas',
            isActive: true,
          ),
          const SizedBox(height: 16),
          
          // Direction 2 Options
          _buildDirectionOption(
            context: context,
            title: 'Retorno via Centro',
            subtitle: 'Via Avenida Amazonas • 22 paradas',
            isActive: false,
          ),
          const SizedBox(height: 24),

          // Action Button
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/lines/details', extra: line);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.4),
            ),
            child: Text(
              'Ver Rota no Mapa',
              style: AppTypography.quicksand.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isActive,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {},
      child: SoftShadowContainer(
        padding: const EdgeInsets.all(20),
        backgroundColor: isActive 
            ? AppColors.primary.withOpacity(0.05) 
            : (isDark ? AppColors.slate800 : AppColors.surfaceLight),
        border: Border.all(
          color: isActive 
              ? AppColors.primary.withOpacity(0.3) 
              : (isDark ? AppColors.slate700 : AppColors.slate200),
          width: isActive ? 2 : 1,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.slate300,
                  width: isActive ? 6 : 2,
                ),
              ),
            ),
            const SizedBox(width: 16),
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
