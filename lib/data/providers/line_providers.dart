import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../models/direction_variants_dto.dart';
import '../models/line_variant_dto.dart';
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

final lineVariantsProvider = FutureProvider.autoDispose
    .family<List<DirectionVariantsDto>, String>((
      ref,
      lineId,
    ) async {
      final repository = ref.watch(lineRepositoryProvider);
      return repository.getLineVariants(lineId);
    });

final lineShapeProvider = FutureProvider.family<
    ShapeDto,
    ({String lineId, String tripId})>((ref, params) async {
  final repository = ref.watch(lineRepositoryProvider);
  return repository.getLineShape(
    params.lineId,
    tripId: params.tripId,
  );
});

final lineStopsProvider = FutureProvider.family<
    List<StopDto>,
    ({String lineId, String tripId})>((ref, params) async {
  final repository = ref.watch(lineRepositoryProvider);
  return repository.getLineStops(
    params.lineId,
    tripId: params.tripId,
  );
});

final lineVehiclesProvider = FutureProvider.autoDispose
    .family<List<VehiclePositionDto>,
        ({String lineId, String? tripId})>((ref, params) async {
  final repository = ref.watch(lineRepositoryProvider);
  return repository.getLineVehicles(
    params.lineId,
    tripId: params.tripId,
  );
});

/// Resolves the first variant for a given line+direction, returning its tripId
/// and other metadata. Useful for screens that only have directionId but
/// need tripId to fetch shape/stops.
final lineVariantForDirectionProvider = FutureProvider.autoDispose
    .family<LineVariantDto?, ({String lineId, int directionId})>((
      ref,
      params,
    ) async {
      final directions = await ref.watch(
        lineVariantsProvider(params.lineId).future,
      );
      final direction = directions.firstWhere(
        (d) => d.directionId == params.directionId,
        orElse: () => const DirectionVariantsDto(
          directionId: -1,
          headsign: '',
          variants: [],
        ),
      );
      if (direction.variants.isEmpty) return null;
      return direction.variants.first;
    });
