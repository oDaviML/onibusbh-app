// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direction_variants_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectionVariantsDto _$DirectionVariantsDtoFromJson(
  Map<String, dynamic> json,
) => DirectionVariantsDto(
  directionId: (json['directionId'] as num).toInt(),
  headsign: json['headsign'] as String,
  variants: (json['variants'] as List<dynamic>)
      .map((e) => LineVariantDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DirectionVariantsDtoToJson(
  DirectionVariantsDto instance,
) => <String, dynamic>{
  'directionId': instance.directionId,
  'headsign': instance.headsign,
  'variants': instance.variants,
};
