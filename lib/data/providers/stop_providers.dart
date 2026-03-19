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

/// Holds the current map bbox with debounce logic.
/// Other providers can watch this to react to bbox changes.
class _BBoxController extends Notifier<BBox?> {
  Timer? _debounceTimer;
  BBox? _pendingBBox;

  @override
  BBox? build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return null;
  }

  void updateBBox(BBox? newBBox) {
    if (newBBox == null) return;
    if (_sameBBox(state, newBBox) && _sameBBox(_pendingBBox, newBBox)) return;

    _pendingBBox = newBBox;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      state = newBBox;
    });
  }

  bool _sameBBox(BBox? a, BBox? b) {
    if (a == null || b == null) return false;
    return a.minLat == b.minLat &&
        a.minLon == b.minLon &&
        a.maxLat == b.maxLat &&
        a.maxLon == b.maxLon;
  }
}

final mapBboxProvider = NotifierProvider<_BBoxController, BBox?>(
  _BBoxController.new,
);

/// Reactive stops list that automatically refetches when mapBbox changes.
final stopsProvider = FutureProvider.autoDispose<List<StopDto>>((ref) async {
  final bbox = ref.watch(mapBboxProvider);
  if (bbox == null) return [];

  final repository = ref.watch(stopRepositoryProvider);
  return repository.getStopsByBBox(
    minLat: bbox.minLat,
    minLon: bbox.minLon,
    maxLat: bbox.maxLat,
    maxLon: bbox.maxLon,
  );
});
