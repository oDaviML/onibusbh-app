import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stop_dto.dart';
import '../models/prediction_response_dto.dart';
import '../repositories/stop_repository.dart';
import 'line_providers.dart';

final stopRepositoryProvider = Provider<StopRepository>((ref) {
  return StopRepository(ref.watch(apiClientProvider));
});

typedef BBox = ({double minLat, double minLon, double maxLat, double maxLon});

final stopsByBBoxProvider = FutureProvider.autoDispose
    .family<List<StopDto>, BBox>((ref, bbox) async {
      final repository = ref.watch(stopRepositoryProvider);
      return repository.getStopsByBBox(
        minLat: bbox.minLat,
        minLon: bbox.minLon,
        maxLat: bbox.maxLat,
        maxLon: bbox.maxLon,
      );
    });

final stopPredictionsProvider = FutureProvider.autoDispose
    .family<List<PredictionResponseDto>, String>((ref, stopId) async {
      final repository = ref.watch(stopRepositoryProvider);
      return repository.getStopPredictions(stopId);
    });

typedef MapState = ({BBox? bbox, double zoom});

class _MapController extends Notifier<MapState> {
  Timer? _debounceTimer;
  BBox? _pendingBBox;
  double _lastZoom = 0;

  @override
  MapState build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return (bbox: null, zoom: 0.0);
  }

  static const double minZoomForStops = 14.0;

  void update(BBox? newBBox, double zoom) {
    _lastZoom = zoom;

    if (zoom < minZoomForStops) {
      _debounceTimer?.cancel();
      _pendingBBox = null;
      state = (bbox: null, zoom: zoom);
      return;
    }

    if (newBBox == null) return;
    if (_sameBBox(state.bbox, newBBox) && _sameBBox(_pendingBBox, newBBox)) {
      return;
    }

    _pendingBBox = newBBox;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      if (_lastZoom < minZoomForStops) return;
      state = (bbox: newBBox, zoom: _lastZoom);
    });
  }

  void clear() {
    _debounceTimer?.cancel();
    _pendingBBox = null;
    state = (bbox: null, zoom: _lastZoom);
  }

  bool _sameBBox(BBox? a, BBox? b) {
    if (a == null || b == null) return false;
    return a.minLat == b.minLat &&
        a.minLon == b.minLon &&
        a.maxLat == b.maxLat &&
        a.maxLon == b.maxLon;
  }
}

final mapProvider = NotifierProvider<_MapController, MapState>(
  _MapController.new,
);

/// Reactive stops list that auto-refetches when map state changes.
/// Returns [] when zoom < minZoomForStops.
final stopsProvider = FutureProvider.autoDispose<List<StopDto>>((ref) async {
  final mapState = ref.watch(mapProvider);

  if (mapState.zoom < _MapController.minZoomForStops) return [];
  final bbox = mapState.bbox;
  if (bbox == null) return [];

  final repository = ref.watch(stopRepositoryProvider);
  return repository.getStopsByBBox(
    minLat: bbox.minLat,
    minLon: bbox.minLon,
    maxLat: bbox.maxLat,
    maxLon: bbox.maxLon,
  );
});
