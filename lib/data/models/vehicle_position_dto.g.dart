// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_position_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehiclePositionDto _$VehiclePositionDtoFromJson(Map<String, dynamic> json) =>
    VehiclePositionDto(
      vehicleId: json['vehicleId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      bearing: (json['bearing'] as num?)?.toInt() ?? 0,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$VehiclePositionDtoToJson(VehiclePositionDto instance) =>
    <String, dynamic>{
      'vehicleId': instance.vehicleId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'bearing': instance.bearing,
      'timestamp': instance.timestamp?.toIso8601String(),
    };
