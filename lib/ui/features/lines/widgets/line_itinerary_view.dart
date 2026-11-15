import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/line_summary_dto.dart';
import '../../../../data/models/stop_dto.dart';
import '../../../../data/models/vehicle_position_dto.dart';

enum ItineraryViewMode { stops, streets }

class LineItineraryView extends StatefulWidget {
  final LineSummaryDto line;
  final List<StopDto> stops;
  final List<VehiclePositionDto> vehicles;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final ValueChanged<StopDto> onFocusStopOnMap;
  final ValueChanged<StopDto> onOpenStopPredictions;

  const LineItineraryView({
    super.key,
    required this.line,
    required this.stops,
    required this.vehicles,
    required this.isLoading,
    this.error,
    required this.onRetry,
    required this.onFocusStopOnMap,
    required this.onOpenStopPredictions,
  });

  @override
  State<LineItineraryView> createState() => _LineItineraryViewState();
}

class _LineItineraryViewState extends State<LineItineraryView> {
  ItineraryViewMode _mode = ItineraryViewMode.stops;
  String _filterQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _expandedStreetIndices = {};
  static const Distance _distance = Distance();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<int, List<VehiclePositionDto>> _matchVehiclesToStops() {
    final result = <int, List<VehiclePositionDto>>{};
    if (widget.stops.isEmpty || widget.vehicles.isEmpty) return result;

    for (final vehicle in widget.vehicles) {
      int matchedIdx = -1;
      if (vehicle.currentStopSequence != null) {
        matchedIdx = widget.stops.indexWhere(
          (s) => s.stopSequence == vehicle.currentStopSequence,
        );
      }

      if (matchedIdx < 0) {
        double bestMeters = double.infinity;
        final vLatLng = LatLng(vehicle.latitude, vehicle.longitude);
        for (int i = 0; i < widget.stops.length; i++) {
          final stop = widget.stops[i];
          final meters = _distance.as(
            LengthUnit.Meter,
            vLatLng,
            LatLng(stop.latitude, stop.longitude),
          );
          if (meters < bestMeters) {
            bestMeters = meters;
            matchedIdx = i;
          }
        }
      }

      if (matchedIdx >= 0) {
        result.putIfAbsent(matchedIdx, () => []).add(vehicle);
      }
    }
    return result;
  }

  List<_StreetSegment> _buildStreetSegments(
    Map<int, List<VehiclePositionDto>> vehiclesByStop,
  ) {
    final segments = <_StreetSegment>[];
    for (int i = 0; i < widget.stops.length; i++) {
      final stop = widget.stops[i];
      final street = stop.resolvedStreetName;
      final vehiclesHere = vehiclesByStop[i] ?? const [];

      if (segments.isNotEmpty &&
          segments.last.streetName.toLowerCase() == street.toLowerCase()) {
        segments.last.stops.add(_IndexedStop(index: i, stop: stop));
        segments.last.liveVehicles.addAll(vehiclesHere);
      } else {
        segments.add(
          _StreetSegment(
            streetName: street,
            stops: [_IndexedStop(index: i, stop: stop)],
            liveVehicles: [...vehiclesHere],
          ),
        );
      }
    }
    return segments;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final routeColor = widget.line.routeColor;

    if (widget.isLoading && widget.stops.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: routeColor),
            const SizedBox(height: 12),
            Text(
              'Carregando itinerário...',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.slate500),
            ),
          ],
        ),
      );
    }

    if (widget.error != null && widget.stops.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 40, color: AppColors.slate400),
              const SizedBox(height: 10),
              Text(
                'Não foi possível carregar o itinerário',
                style: AppTypography.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.stops.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma parada cadastrada para este sentido.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.slate500),
        ),
      );
    }

    final vehiclesByStop = _matchVehiclesToStops();
    final query = _filterQuery.trim().toLowerCase();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.slate800 : AppColors.slate100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ModeTabButton(
                              icon: Icons.pin_drop_outlined,
                              label: 'Parada a Parada',
                              selected: _mode == ItineraryViewMode.stops,
                              accentColor: routeColor,
                              onTap: () => setState(() => _mode = ItineraryViewMode.stops),
                            ),
                          ),
                          Expanded(
                            child: _ModeTabButton(
                              icon: Icons.signpost_outlined,
                              label: 'Rua por Rua',
                              selected: _mode == ItineraryViewMode.streets,
                              accentColor: routeColor,
                              onTap: () => setState(() => _mode = ItineraryViewMode.streets),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _filterQuery = value),
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? Colors.white : AppColors.slate900,
                ),
                decoration: InputDecoration(
                  hintText: 'Filtrar rua, avenida ou ponto...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.slate400,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _filterQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _filterQuery = '');
                          },
                          icon: const Icon(Icons.close_rounded, size: 18),
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppColors.slate800 : Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.slate700 : AppColors.slate200,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.slate700 : AppColors.slate200,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _mode == ItineraryViewMode.stops
              ? _buildStopsList(vehiclesByStop, query, isDark, routeColor)
              : _buildStreetsList(vehiclesByStop, query, isDark, routeColor),
        ),
      ],
    );
  }

  Widget _buildStopsList(
    Map<int, List<VehiclePositionDto>> vehiclesByStop,
    String query,
    bool isDark,
    Color routeColor,
  ) {
    final indexedStops = <int>[];
    for (int i = 0; i < widget.stops.length; i++) {
      final stop = widget.stops[i];
      if (query.isEmpty ||
          stop.name.toLowerCase().contains(query) ||
          stop.resolvedStreetName.toLowerCase().contains(query)) {
        indexedStops.add(i);
      }
    }

    if (indexedStops.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma parada encontrada para "$query"',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.slate500),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      itemCount: indexedStops.length,
      itemBuilder: (context, pos) {
        final i = indexedStops[pos];
        final stop = widget.stops[i];
        final isFirst = i == 0;
        final isLast = i == widget.stops.length - 1;
        final liveVehicles = vehiclesByStop[i] ?? const [];
        final seq = stop.stopSequence ?? (i + 1);
        final travelMin = stop.travelTimeSeconds != null
            ? (stop.travelTimeSeconds! / 60).round()
            : null;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 34,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: 2.5,
                        color: pos == 0
                            ? Colors.transparent
                            : routeColor.withValues(alpha: 0.35),
                      ),
                    ),
                    Container(
                      width: isFirst || isLast ? 26 : 22,
                      height: isFirst || isLast ? 26 : 22,
                      decoration: BoxDecoration(
                        color: liveVehicles.isNotEmpty
                            ? Colors.green
                            : (isFirst || isLast
                                  ? routeColor
                                  : (isDark ? AppColors.slate900 : Colors.white)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: liveVehicles.isNotEmpty ? Colors.white : routeColor,
                          width: isFirst || isLast ? 2.5 : 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$seq',
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: (liveVehicles.isNotEmpty || isFirst || isLast)
                              ? Colors.white
                              : (isDark ? Colors.white : AppColors.slate800),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 2.5,
                        color: pos == indexedStops.length - 1
                            ? Colors.transparent
                            : routeColor.withValues(alpha: 0.35),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onFocusStopOnMap(stop),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.slate800 : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: liveVehicles.isNotEmpty
                            ? Colors.green.withValues(alpha: 0.6)
                            : (isDark ? AppColors.slate700 : AppColors.slate200),
                        width: liveVehicles.isNotEmpty ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isFirst || isLast)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 3),
                                      child: Text(
                                        isFirst ? 'PONTO INICIAL' : 'PONTO FINAL',
                                        style: AppTypography.caption.copyWith(
                                          color: routeColor,
                                          fontSize: 10,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    stop.name,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontSize: 14,
                                      color: isDark ? Colors.white : AppColors.slate900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (travelMin != null)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.slate700 : AppColors.slate100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  travelMin == 0 ? 'Início' : '+${travelMin}m',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.slate500,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (stop.description != null && stop.description!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            stop.description!,
                            style: AppTypography.labelMedium.copyWith(
                              fontSize: 12,
                              color: AppColors.slate500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (liveVehicles.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: liveVehicles.map((v) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.directions_bus_rounded,
                                      size: 13,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Veículo ${v.vehicleId} aqui',
                                      style: AppTypography.caption.copyWith(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => widget.onFocusStopOnMap(stop),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.map_outlined, size: 14, color: routeColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Ver no mapa',
                                      style: AppTypography.caption.copyWith(color: routeColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            InkWell(
                              onTap: () => widget.onOpenStopPredictions(stop),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 14,
                                      color: isDark ? AppColors.slate300 : AppColors.slate600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Previsões neste ponto',
                                      style: AppTypography.caption.copyWith(
                                        color: isDark ? AppColors.slate300 : AppColors.slate600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreetsList(
    Map<int, List<VehiclePositionDto>> vehiclesByStop,
    String query,
    bool isDark,
    Color routeColor,
  ) {
    final segments = _buildStreetSegments(vehiclesByStop);
    final filteredIndices = <int>[];
    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      if (query.isEmpty ||
          seg.streetName.toLowerCase().contains(query) ||
          seg.stops.any((s) => s.stop.name.toLowerCase().contains(query))) {
        filteredIndices.add(i);
      }
    }

    if (filteredIndices.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma via encontrada para "$query"',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.slate500),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      itemCount: filteredIndices.length,
      itemBuilder: (context, pos) {
        final segIdx = filteredIndices[pos];
        final seg = segments[segIdx];
        final isExpanded = _expandedStreetIndices.contains(segIdx) || query.isNotEmpty;
        final firstSeq = seg.stops.first.stop.stopSequence ?? (seg.stops.first.index + 1);
        final lastSeq = seg.stops.last.stop.stopSequence ?? (seg.stops.last.index + 1);
        final rangeText = firstSeq == lastSeq
            ? 'Parada $firstSeq'
            : 'Paradas $firstSeq a $lastSeq';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate800 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: seg.liveVehicles.isNotEmpty
                  ? Colors.green.withValues(alpha: 0.6)
                  : (isDark ? AppColors.slate700 : AppColors.slate200),
            ),
          ),
          child: Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    if (_expandedStreetIndices.contains(segIdx)) {
                      _expandedStreetIndices.remove(segIdx);
                    } else {
                      _expandedStreetIndices.add(segIdx);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: seg.liveVehicles.isNotEmpty
                              ? Colors.green.withValues(alpha: 0.14)
                              : routeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${segIdx + 1}',
                          style: AppTypography.labelMedium.copyWith(
                            color: seg.liveVehicles.isNotEmpty ? Colors.green : routeColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              seg.streetName,
                              style: AppTypography.titleMedium.copyWith(
                                fontSize: 15,
                                color: isDark ? Colors.white : AppColors.slate900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  '$rangeText · ${seg.stops.length} ${seg.stops.length == 1 ? 'ponto' : 'pontos'}',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.slate500,
                                  ),
                                ),
                                if (seg.liveVehicles.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${seg.liveVehicles.length} ônibus aqui',
                                      style: AppTypography.caption.copyWith(
                                        color: Colors.green.shade700,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        color: AppColors.slate400,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded) ...[
                Divider(
                  height: 1,
                  color: isDark ? AppColors.slate700 : AppColors.slate200,
                ),
                ...seg.stops.map((item) {
                  final stop = item.stop;
                  final seq = stop.stopSequence ?? (item.index + 1);
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: routeColor.withValues(alpha: 0.12),
                      child: Text(
                        '$seq',
                        style: AppTypography.caption.copyWith(
                          color: routeColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    title: Text(
                      stop.name,
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 13,
                        color: isDark ? Colors.white : AppColors.slate900,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Ver no mapa',
                          onPressed: () => widget.onFocusStopOnMap(stop),
                          icon: Icon(Icons.map_outlined, size: 18, color: routeColor),
                        ),
                        IconButton(
                          tooltip: 'Previsões neste ponto',
                          onPressed: () => widget.onOpenStopPredictions(stop),
                          icon: Icon(
                            Icons.schedule_rounded,
                            size: 18,
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => widget.onFocusStopOnMap(stop),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ModeTabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _ModeTabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? AppColors.slate700 : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? accentColor : AppColors.slate400,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                fontSize: 12,
                color: selected
                    ? (isDark ? Colors.white : AppColors.slate900)
                    : AppColors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndexedStop {
  final int index;
  final StopDto stop;

  _IndexedStop({required this.index, required this.stop});
}

class _StreetSegment {
  final String streetName;
  final List<_IndexedStop> stops;
  final List<VehiclePositionDto> liveVehicles;

  _StreetSegment({
    required this.streetName,
    required this.stops,
    required this.liveVehicles,
  });
}
