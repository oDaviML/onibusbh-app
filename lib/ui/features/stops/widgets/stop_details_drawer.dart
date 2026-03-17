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
  final ValueChanged<PredictionResponseDto?> onLineSelected;

  const StopDetailsDrawer({
    super.key,
    required this.stop,
    required this.onLineSelected,
  });

  @override
  ConsumerState<StopDetailsDrawer> createState() => _StopDetailsDrawerState();
}

class _StopDetailsDrawerState extends ConsumerState<StopDetailsDrawer> {
  String? _expandedRouteId;

  void _toggleLine(PredictionResponseDto prediction) {
    setState(() {
      if (_expandedRouteId == prediction.routeId) {
        _expandedRouteId = null;
        widget.onLineSelected(null);
      } else {
        _expandedRouteId = prediction.routeId;
        widget.onLineSelected(prediction);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final predictionsAsync =
        ref.watch(stopPredictionsProvider(widget.stop.id));
    final isFav =
        ref.watch(favoriteStopsProvider.notifier).isFavorite(widget.stop.id);

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DETALHES DA PARADA',
                        style: AppTypography.nunito.copyWith(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.stop.name,
                        style: AppTypography.quicksand.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (widget.stop.description != null &&
                          widget.stop.description!.isNotEmpty)
                        Text(
                          widget.stop.description!,
                          style: AppTypography.nunito.copyWith(
                            fontSize: 14,
                            color: AppColors.slate500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref.read(favoriteStopsProvider.notifier).toggleFavorite(widget.stop);
                  },
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_outline,
                    color: isFav ? Colors.red : AppColors.slate400,
                  ),
                  iconSize: 28,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
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
                          style: AppTypography.nunito.copyWith(
                            fontSize: 13,
                            color: AppColors.slate400,
                            fontWeight: FontWeight.w700,
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
                              style: AppTypography.nunito.copyWith(
                                color: AppColors.slate500,
                                fontSize: 14,
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
                              return LineAccordionTile(
                                prediction: prediction,
                                isExpanded:
                                    _expandedRouteId == prediction.routeId,
                                onToggle: () => _toggleLine(prediction),
                              );
                            },
                          ),
                  ),
                ],
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
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
                        style: AppTypography.quicksand.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        error.toString(),
                        style: AppTypography.nunito.copyWith(
                          fontSize: 12,
                          color: AppColors.slate400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => ref.invalidate(
                            stopPredictionsProvider(widget.stop.id)),
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
