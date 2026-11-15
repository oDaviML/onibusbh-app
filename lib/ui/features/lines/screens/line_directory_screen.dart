import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/line_summary_dto.dart';
import '../../../../data/providers/line_providers.dart';
import '../../../widgets/custom_search_bar.dart';
import '../../../widgets/system_badge.dart';
import '../../../widgets/theme_toggle_button.dart';
import '../widgets/line_card.dart';

class LineDirectoryScreen extends ConsumerStatefulWidget {
  const LineDirectoryScreen({super.key});

  @override
  ConsumerState<LineDirectoryScreen> createState() =>
      _LineDirectoryScreenState();
}

class _LineDirectoryScreenState extends ConsumerState<LineDirectoryScreen> {
  String? _searchQuery;
  String _selectedSystem = 'ALL';

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.isEmpty ? null : query;
    });
  }

  List<LineSummaryDto> _applySystemFilter(List<LineSummaryDto> lines) {
    if (_selectedSystem == 'BHTRANS') {
      return lines.where((l) => !l.isMetropolitan).toList();
    }
    if (_selectedSystem == 'OTIMO') {
      return lines.where((l) => l.isMetropolitan).toList();
    }
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
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
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(color: AppColors.primary),
                          ),
                          const Spacer(),
                          const ThemeToggleButton(),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            sliver: linesAsync.when(
              data: (lines) {
                final filteredLines = _applySystemFilter(lines);
                return SliverList(
                  delegate: SliverChildListDelegate([
                    _buildFilterRow(isDark),
                    const SizedBox(height: 12),
                    Text(
                      '${filteredLines.length} LINHAS DISPONÍVEIS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (filteredLines.isEmpty)
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
                      ...filteredLines.map(
                        (line) => LineCard(line: line),
                      ),
                    const SizedBox(height: 80),
                  ]),
                );
              },
              loading: () => SliverList(
                delegate: SliverChildListDelegate([
                  _buildFilterRow(isDark),
                  const SizedBox(height: 12),
                  Text(
                    'LINHAS DISPONÍVEIS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
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

  Widget _buildFilterRow(bool isDark) {
    final options = <({String key, String label, Color color})>[
      (key: 'ALL', label: 'Todos', color: AppColors.primary),
      (key: 'BHTRANS', label: 'Municipal · BHTrans', color: AppColors.primary),
      (
        key: 'OTIMO',
        label: 'Metropolitano · Ótimo',
        color: SystemBadge.metropolitanColor,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((opt) {
          final selected = _selectedSystem == opt.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(opt.label),
              selected: selected,
              onSelected: (_) => setState(() => _selectedSystem = opt.key),
              selectedColor: opt.color.withValues(alpha: 0.14),
              backgroundColor: isDark ? AppColors.slate800 : Colors.white,
              labelStyle: AppTypography.labelMedium.copyWith(
                fontSize: 12,
                color: selected
                    ? opt.color
                    : (isDark ? AppColors.slate300 : AppColors.slate600),
              ),
              side: BorderSide(
                color: selected
                    ? opt.color
                    : (isDark ? AppColors.slate700 : AppColors.slate200),
              ),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
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
