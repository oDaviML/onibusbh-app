import '../models/base_response.dart';
import '../models/stop_dto.dart';
import '../models/prediction_response_dto.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class StopRepository {
  final ApiClient _client;

  StopRepository(this._client);

  Future<List<StopDto>> getStopsByBBox({
    required double minLat,
    required double minLon,
    required double maxLat,
    required double maxLon,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.stops,
      queryParameters: {
        'minLat': minLat,
        'minLon': minLon,
        'maxLat': maxLat,
        'maxLon': maxLon,
      },
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

  Future<List<PredictionResponseDto>> getStopPredictions(
    String stopId, {
    String? shortName,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.stopPredictions(stopId),
      queryParameters: shortName != null ? {'shortName': shortName} : null,
    );

    final baseResponse = BaseResponse<List<PredictionResponseDto>>.fromJson(
      response.data!,
      (json) => (json as List)
          .map((e) => PredictionResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    if (baseResponse.isError) {
      throw Exception(baseResponse.message ?? 'Erro ao buscar previsões');
    }

    return baseResponse.data ?? [];
  }
}
