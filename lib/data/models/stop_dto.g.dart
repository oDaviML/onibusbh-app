// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StopDto _$StopDtoFromJson(Map<String, dynamic> json) => StopDto(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  stopSequence: (json['stopSequence'] as num?)?.toInt(),
  streetName: json['streetName'] as String?,
  travelTimeSeconds: (json['travelTimeSeconds'] as num?)?.toInt(),
  system: json['system'] as String? ?? 'BHTRANS',
);

Map<String, dynamic> _$StopDtoToJson(StopDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'stopSequence': instance.stopSequence,
  'streetName': instance.streetName,
  'travelTimeSeconds': instance.travelTimeSeconds,
  'system': instance.system,
};
