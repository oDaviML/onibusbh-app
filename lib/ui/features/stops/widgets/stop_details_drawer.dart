import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/stop_dto.dart';
import '../../../../data/models/prediction_response_dto.dart';
import '../../../../data/providers/stop_providers.dart';
import '../../../../data/providers/favorites_providers.dart';
import 'line_accordion_tile.dart';

class StopDetailsDrawer extends ConsumerStatefulWidget {
  final StopDto stop;
  final ValueChanged<PredictionResponseDto>? onOpenTracking;

  const StopDetailsDrawer({super.key, required this.stop, this.onOpenTracking});

  @override
  ConsumerState<StopDetailsDrawer> createState() => _StopDetailsDrawerState();
}

class _StopDetailsDrawerState extends ConsumerState<StopDetailsDrawer>
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
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 50),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final predictionsAsync = ref.watch(stopPredictionsProvider(widget.stop.id));
    final favoriteStops = ref.watch(favoriteStopsProvider);
    final isFav = favoriteStops.any((e) => e.id == widget.stop.id);

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
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
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DETALHES DA PARADA',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.stop.name,
                            style: AppTypography.headlineMedium.copyWith(
                              fontSize: 22,
                            ),
                          ),
                          if (widget.stop.description != null &&
                              widget.stop.description!.isNotEmpty)
                            Text(
                              widget.stop.description!,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.slate500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: ScaleTransition(
                        scale: _heartScale,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: IconButton(
                            key: ValueKey(isFav),
                            onPressed: () {
                              ref
                                  .read(favoriteStopsProvider.notifier)
                                  .toggleFavorite(widget.stop);
                              _heartController.forward(from: 0);
                            },
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_outline,
                              color: isFav ? Colors.red : AppColors.slate400,
                            ),
                            iconSize: 28,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: predictionsAsync.when(
              data: (predictions) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions_bus_rounded,
                          size: 16,
                          color: AppColors.slate400,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${predictions.length} linhas nesta parada',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.slate400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: predictions.isEmpty
                        ? Center(
                            child: Text(
                              'Nenhuma previsão disponível',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.slate500,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.only(
                              left: 24,
                              right: 24,
                              bottom:
                                  MediaQuery.of(context).padding.bottom + 16,
                            ),
                            itemCount: predictions.length,
                            itemBuilder: (context, index) {
                              final prediction = predictions[index];
                              return LinePredictionTile(
                                prediction: prediction,
                                onTap: () =>
                                    widget.onOpenTracking?.call(prediction),
                              );
                            },
                          ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 36,
                        color: AppColors.slate400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Erro ao carregar previsões',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.slate500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        error.toString(),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.slate400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => ref.invalidate(
                          stopPredictionsProvider(widget.stop.id),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
