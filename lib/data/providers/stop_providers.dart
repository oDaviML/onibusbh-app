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
