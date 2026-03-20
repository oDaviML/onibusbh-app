// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArrivalPredictionDto _$ArrivalPredictionDtoFromJson(
  Map<String, dynamic> json,
) => ArrivalPredictionDto(
  etaMinutes: (json['etaMinutes'] as num).toInt(),
  isStale: json['isStale'] as bool? ?? false,
  vehicleId: json['vehicleId'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  bearing: (json['bearing'] as num?)?.toInt(),
);

Map<String, dynamic> _$ArrivalPredictionDtoToJson(
  ArrivalPredictionDto instance,
) => <String, dynamic>{
  'etaMinutes': instance.etaMinutes,
  'isStale': instance.isStale,
  'vehicleId': instance.vehicleId,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'bearing': instance.bearing,
};

PredictionResponseDto _$PredictionResponseDtoFromJson(
  Map<String, dynamic> json,
) => PredictionResponseDto(
  routeId: json['routeId'] as String,
  shortName: json['shortName'] as String,
  longName: json['longName'] as String,
  color: json['color'] as String?,
  headsign: json['headsign'] as String?,
  direction: (json['direction'] as num?)?.toInt() ?? 0,
  arrivals:
      (json['arrivals'] as List<dynamic>?)
          ?.map((e) => ArrivalPredictionDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PredictionResponseDtoToJson(
  PredictionResponseDto instance,
) => <String, dynamic>{
  'routeId': instance.routeId,
  'shortName': instance.shortName,
  'longName': instance.longName,
  'color': instance.color,
  'headsign': instance.headsign,
  'direction': instance.direction,
  'arrivals': instance.arrivals,
};
