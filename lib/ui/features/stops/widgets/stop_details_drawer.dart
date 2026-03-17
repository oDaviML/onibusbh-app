import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/stop_dto.dart';
import '../../../../data/models/prediction_response_dto.dart';
import 'line_accordion_tile.dart';

class StopDetailsDrawer extends StatefulWidget {
  final StopDto stop;
  final ValueChanged<PredictionDto?> onLineSelected;

  const StopDetailsDrawer({
    super.key,
    required this.stop,
    required this.onLineSelected,
  });

  @override
  State<StopDetailsDrawer> createState() => _StopDetailsDrawerState();
}

class _StopDetailsDrawerState extends State<StopDetailsDrawer> {
  String? _expandedLineId;

  void _toggleLine(PredictionDto prediction) {
    setState(() {
      if (_expandedLineId == prediction.lineId) {
        _expandedLineId = null;
        widget.onLineSelected(null);
      } else {
        _expandedLineId = prediction.lineId;
        widget.onLineSelected(prediction);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final predictions = mockStopPredictions.predictions
        .where((p) => widget.stop.lineIds.contains(p.lineId))
        .toList();

    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.slate300,
              borderRadius: BorderRadius.circular(10),
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
                Text(
                  widget.stop.locationArea,
                  style: AppTypography.nunito.copyWith(
                    fontSize: 14,
                    color: AppColors.slate500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

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

          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shrinkWrap: true,
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                final prediction = predictions[index];
                return LineAccordionTile(
                  prediction: prediction,
                  isExpanded: _expandedLineId == prediction.lineId,
                  onToggle: () => _toggleLine(prediction),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
