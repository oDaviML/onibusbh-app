import 'package:json_annotation/json_annotation.dart';

part 'vehicle_position_dto.g.dart';

@JsonSerializable()
class VehiclePositionDto {
  final String vehicleId;
  final double latitude;
  final double longitude;
  final int bearing;
  final int direction;
  final DateTime? timestamp;

  const VehiclePositionDto({
    required this.vehicleId,
    required this.latitude,
    required this.longitude,
    this.bearing = 0,
    this.direction = 0,
    this.timestamp,
  });

  factory VehiclePositionDto.fromJson(Map<String, dynamic> json) =>
      _$VehiclePositionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VehiclePositionDtoToJson(this);
}
