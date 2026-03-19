import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/stop_dto.dart';
import '../../../../data/models/prediction_response_dto.dart';
import '../../../../data/providers/favorites_providers.dart';
import '../../lines/widgets/line_card.dart';
import '../../lines/widgets/direction_selection_modal.dart';
import '../../stops/widgets/stop_details_drawer.dart';
import '../../stops/screens/stop_tracking_screen.dart';
import '../../../widgets/scaffold_with_nav_bar.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  StopDto? _selectedStop;
  late final AnimationController _drawerAnimController;
  late final Animation<Offset> _drawerSlideAnimation;

  @override
  void initState() {
    super.initState();
    _drawerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _drawerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _drawerAnimController,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );
  }

  @override
  void dispose() {
    _drawerAnimController.dispose();
    ScaffoldWithNavBar.forceHide.value = false;
    super.dispose();
  }

  void _onStopTapped(StopDto stop) {
    setState(() {
      _selectedStop = stop;
    });
    ScaffoldWithNavBar.forceHide.value = true;
    _drawerAnimController.forward();
  }

  void _closeDrawer() {
    ScaffoldWithNavBar.forceHide.value = false;
    _drawerAnimController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _selectedStop = null;
        });
      }
    });
  }

  void _onOpenTracking(PredictionResponseDto prediction) {
    final stop = _selectedStop;
    if (stop == null) return;

    ScaffoldWithNavBar.forceHide.value = false;
    _drawerAnimController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _selectedStop = null;
        });
      }
    });

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            StopTrackingScreen(stop: stop, prediction: prediction),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favoriteLines = ref.watch(favoriteLinesProvider);
    final favoriteStops = ref.watch(favoriteStopsProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Favoritos',
                                  style: AppTypography.display.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Suas rotas e paradas frequentes',
                                  style: AppTypography.quicksand.copyWith(
                                    color: isDark
                                        ? AppColors.slate400
                                        : AppColors.slate500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.slate800.withValues(alpha: 0.5)
                                : AppColors.slate200.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _TabButton(
                                  label: 'Linhas Salvas',
                                  isActive: _selectedTabIndex == 0,
                                  onTap: () =>
                                      setState(() => _selectedTabIndex = 0),
                                ),
                              ),
                              Expanded(
                                child: _TabButton(
                                  label: 'Paradas Salvas',
                                  isActive: _selectedTabIndex == 1,
                                  onTap: () =>
                                      setState(() => _selectedTabIndex = 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (_selectedTabIndex == 0) ...[
                        if (favoriteLines.isEmpty)
                          _buildEmptyState('Nenhuma linha salva')
                        else
                          ...favoriteLines.map(
                            (line) => Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: LineCard(
                                line: line,
                                onTap: () {
                                  if (line.isBidirectional) {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) =>
                                          DirectionSelectionModal(line: line),
                                    );
                                  } else {
                                    context.push(
                                      '/lines/details',
                                      extra: {'line': line, 'direction': 1},
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                      ] else ...[
                        const SizedBox(height: 16),
                        if (favoriteStops.isEmpty)
                          _buildEmptyState('Nenhuma parada salva')
                        else
                          ...favoriteStops.map(
                            (stop) => Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: GestureDetector(
                                onTap: () => _onStopTapped(stop),
                                child: _buildStopCard(context, stop),
                              ),
                            ),
                          ),
                      ],
                    ]),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedStop != null)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeDrawer,
                child: const SizedBox.expand(),
              ),
            ),
          if (_selectedStop != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _drawerSlideAnimation,
                child: GestureDetector(
                  onTap: () {},
                  child: StopDetailsDrawer(
                    key: ValueKey(_selectedStop!.id),
                    stop: _selectedStop!,
                    onOpenTracking: _onOpenTracking,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Center(
        child: Text(
          message,
          style: AppTypography.quicksand.copyWith(
            color: AppColors.slate400,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStopCard(BuildContext context, StopDto stop) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.slate800 : AppColors.slate100,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate100,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.directions_bus_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.name,
                  style: AppTypography.display.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (stop.description != null &&
                    stop.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    stop.description!,
                    style: AppTypography.quicksand.copyWith(
                      color: isDark ? AppColors.slate400 : AppColors.slate500,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.favorite, color: Colors.red, size: 20),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.slate400),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
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
        padding: const EdgeInsets.symmetric(vertical: 10),
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
            style: AppTypography.quicksand.copyWith(
              color: isActive
                  ? (isDark ? Colors.white : AppColors.primary)
                  : (isDark ? AppColors.slate400 : AppColors.slate500),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
