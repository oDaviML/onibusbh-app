import 'package:json_annotation/json_annotation.dart';

part 'line_direction_dto.g.dart';

@JsonSerializable()
class LineDirectionDto {
  final int directionId;
  final String headsign;

  const LineDirectionDto({
    required this.directionId,
    required this.headsign,
  });

  factory LineDirectionDto.fromJson(Map<String, dynamic> json) =>
      _$LineDirectionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LineDirectionDtoToJson(this);
}
