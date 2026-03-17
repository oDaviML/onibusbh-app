import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../models/line_summary_dto.dart';
import '../models/shape_dto.dart';
import '../models/stop_dto.dart';
import '../models/vehicle_position_dto.dart';
import '../repositories/line_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final lineRepositoryProvider = Provider<LineRepository>((ref) {
  return LineRepository(ref.watch(apiClientProvider));
});

final linesProvider = FutureProvider.family<List<LineSummaryDto>, String?>((
  ref,
  query,
) async {
  final repository = ref.watch(lineRepositoryProvider);
  return repository.searchLines(query: query);
});

final lineShapeProvider =
    FutureProvider.family<ShapeDto, ({String lineId, int direction})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(lineRepositoryProvider);
      return repository.getLineShape(params.lineId, params.direction);
    });

final lineStopsProvider =
    FutureProvider.family<List<StopDto>, ({String lineId, int direction})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(lineRepositoryProvider);
      return repository.getLineStops(params.lineId, params.direction);
    });

final lineVehiclesProvider = FutureProvider.autoDispose
    .family<List<VehiclePositionDto>, String>((ref, lineId) async {
      final repository = ref.watch(lineRepositoryProvider);
      return repository.getLineVehicles(lineId);
    });
