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
      directionId: (json['directionId'] as num?)?.toInt() ?? 0,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      variantLabel: json['variantLabel'] as String?,
      tripId: json['tripId'] as String?,
    );

Map<String, dynamic> _$VehiclePositionDtoToJson(VehiclePositionDto instance) =>
    <String, dynamic>{
      'vehicleId': instance.vehicleId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'bearing': instance.bearing,
      'directionId': instance.directionId,
      'timestamp': instance.timestamp?.toIso8601String(),
      'variantLabel': instance.variantLabel,
      'tripId': instance.tripId,
    };
