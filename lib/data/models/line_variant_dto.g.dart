// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_variant_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineVariantDto _$LineVariantDtoFromJson(Map<String, dynamic> json) =>
    LineVariantDto(
      variantLabel: json['variantLabel'] as String,
      headsign: json['headsign'] as String?,
      tripCount: (json['tripCount'] as num?)?.toInt(),
      shapeId: json['shapeId'] as String?,
      vehicleCount: (json['vehicleCount'] as num?)?.toInt(),
      tripId: json['tripId'] as String?,
    );

Map<String, dynamic> _$LineVariantDtoToJson(LineVariantDto instance) =>
    <String, dynamic>{
      'variantLabel': instance.variantLabel,
      'headsign': instance.headsign,
      'tripCount': instance.tripCount,
      'shapeId': instance.shapeId,
      'vehicleCount': instance.vehicleCount,
      'tripId': instance.tripId,
    };
