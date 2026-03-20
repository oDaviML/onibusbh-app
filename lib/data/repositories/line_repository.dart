import '../models/base_response.dart';
import '../models/line_summary_dto.dart';
import '../models/shape_dto.dart';
import '../models/stop_dto.dart';
import '../models/vehicle_position_dto.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class LineRepository {
  final ApiClient _client;

  LineRepository(this._client);

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

  Future<ShapeDto> getLineShape(String lineId, int direction) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.lineShape(lineId),
      queryParameters: {'direction': direction},
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

  Future<List<StopDto>> getLineStops(String lineId, int direction) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.lineStops(lineId),
      queryParameters: {'direction': direction},
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
    int? direction,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.lineVehicles(lineId),
      queryParameters: direction != null ? {'direction': direction} : null,
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
