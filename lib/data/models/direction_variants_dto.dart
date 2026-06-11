import 'package:json_annotation/json_annotation.dart';

import 'line_variant_dto.dart';

part 'direction_variants_dto.g.dart';

@JsonSerializable()
class DirectionVariantsDto {
  final int directionId;
  final String headsign;
  final List<LineVariantDto> variants;

  const DirectionVariantsDto({
    required this.directionId,
    required this.headsign,
    required this.variants,
  });

  factory DirectionVariantsDto.fromJson(Map<String, dynamic> json) =>
      _$DirectionVariantsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DirectionVariantsDtoToJson(this);
}
