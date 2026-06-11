// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_direction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineDirectionDto _$LineDirectionDtoFromJson(Map<String, dynamic> json) =>
    LineDirectionDto(
      directionId: (json['directionId'] as num).toInt(),
      headsign: json['headsign'] as String,
    );

Map<String, dynamic> _$LineDirectionDtoToJson(LineDirectionDto instance) =>
    <String, dynamic>{
      'directionId': instance.directionId,
      'headsign': instance.headsign,
    };
