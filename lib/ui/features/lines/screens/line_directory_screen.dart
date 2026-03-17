import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/line_summary_dto.dart';
import '../../../widgets/custom_search_bar.dart';
import '../widgets/direction_selection_modal.dart';
import '../widgets/line_card.dart';

class LineDirectoryScreen extends StatelessWidget {
  const LineDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Icon(
                                Icons.directions_bus,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Ônibus BH',
                            style: AppTypography.display.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const CustomSearchBar(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'LINHAS DISPONÍVEIS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                ...mockLines.map(
                  (line) => LineCard(
                    line: line,
                    onTap: () {
                      DirectionSelectionModal.show(context, line);
                    },
                  ),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }


}
