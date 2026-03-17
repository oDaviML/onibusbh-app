import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/providers/line_providers.dart';
import '../../../widgets/custom_search_bar.dart';
import '../widgets/direction_selection_modal.dart';
import '../widgets/line_card.dart';

class LineDirectoryScreen extends ConsumerStatefulWidget {
  const LineDirectoryScreen({super.key});

  @override
  ConsumerState<LineDirectoryScreen> createState() =>
      _LineDirectoryScreenState();
}

class _LineDirectoryScreenState extends ConsumerState<LineDirectoryScreen> {
  String? _searchQuery;

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.isEmpty ? null : query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final linesAsync = ref.watch(linesProvider(_searchQuery));

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
                                  color:
                                      AppColors.primary.withValues(alpha: 0.15),
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
                      CustomSearchBar(onChanged: _onSearchChanged),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: linesAsync.when(
              data: (lines) => SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'LINHAS DISPONÍVEIS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (lines.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: AppColors.slate400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Nenhuma linha encontrada',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppColors.slate500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...lines.map(
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
              loading: () => SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'LINHAS DISPONÍVEIS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(4, (_) => _buildShimmerCard(context)),
                ]),
              ),
              error: (error, _) => SliverList(
                delegate: SliverChildListDelegate([
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: AppColors.slate400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Erro ao carregar linhas',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.slate500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.slate400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () =>
                                ref.invalidate(linesProvider(_searchQuery)),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate700 : AppColors.slate100,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate700 : AppColors.slate100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
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
}
