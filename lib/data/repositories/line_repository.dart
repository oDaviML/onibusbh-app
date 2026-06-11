import '../models/base_response.dart';
import '../models/direction_variants_dto.dart';
import '../models/line_summary_dto.dart';
import '../models/shape_dto.dart';
import '../models/stop_dto.dart';
import '../models/vehicle_position_dto.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class LineRepository {
  final ApiClient _client;

  LineRepository(this._client);

  Future<List<DirectionVariantsDto>> getLineVariants(String lineId) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.lineVariants(lineId),
    );

    final baseResponse = BaseResponse<List<DirectionVariantsDto>>.fromJson(
      response.data!,
      (json) => (json as List)
          .map((e) => DirectionVariantsDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    if (baseResponse.isError) {
      throw Exception(baseResponse.message ?? 'Erro ao buscar variantes');
    }

    return baseResponse.data ?? [];
  }

  Future<List<LineSummaryDto>> searchLines({String? query}) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.lines,
      queryParameters: query != null && query.isNotEmpty
          ? {'query': query}
          : null,
    );

    final baseResponse = BaseResponse<List<LineSummaryDto>>.fromJson(
      response.data!,
      (json) => (json as List)
          .map((e) => LineSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    if (baseResponse.isError) {
      throw Exception(baseResponse.message ?? 'Erro ao buscar linhas');
    }

    return baseResponse.data ?? [];
  }

  Future<ShapeDto> getLineShape(
    String lineId, {
    String? tripId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (tripId != null) queryParams['trip'] = tripId;

    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.lineShape(lineId),
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final baseResponse = BaseResponse<ShapeDto>.fromJson(
      response.data!,
      (json) => ShapeDto.fromJson(json as Map<String, dynamic>),
    );

    if (baseResponse.isError) {
      throw Exception(baseResponse.message ?? 'Erro ao buscar trajeto');
    }

    return baseResponse.data!;
  }

  Future<List<StopDto>> getLineStops(
    String lineId, {
    String? tripId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (tripId != null) queryParams['trip'] = tripId;

    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.lineStops(lineId),
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final baseResponse = BaseResponse<List<StopDto>>.fromJson(
      response.data!,
      (json) => (json as List)
          .map((e) => StopDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    if (baseResponse.isError) {
      throw Exception(baseResponse.message ?? 'Erro ao buscar paradas');
    }

    return baseResponse.data ?? [];
  }

  Future<List<VehiclePositionDto>> getLineVehicles(
    String lineId, {
    String? tripId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (tripId != null) queryParams['trip'] = tripId;

    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.lineVehicles(lineId),
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final baseResponse = BaseResponse<List<VehiclePositionDto>>.fromJson(
      response.data!,
      (json) => (json as List)
          .map((e) => VehiclePositionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    if (baseResponse.isError) {
      throw Exception(baseResponse.message ?? 'Erro ao buscar veículos');
    }

    return baseResponse.data ?? [];
  }
}
