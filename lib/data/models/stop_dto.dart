import 'package:json_annotation/json_annotation.dart';

part 'stop_dto.g.dart';

@JsonSerializable()
class StopDto {
  final String id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;

  const StopDto({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
  });

  factory StopDto.fromJson(Map<String, dynamic> json) =>
      _$StopDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StopDtoToJson(this);
}
