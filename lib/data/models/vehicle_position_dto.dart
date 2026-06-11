import 'package:json_annotation/json_annotation.dart';

part 'vehicle_position_dto.g.dart';

@JsonSerializable()
class VehiclePositionDto {
  final String vehicleId;
  final double latitude;
  final double longitude;
  final int bearing;
  final int directionId;
  final DateTime? timestamp;
  final String? variantLabel;
  final String? tripId;

  const VehiclePositionDto({
    required this.vehicleId,
    required this.latitude,
    required this.longitude,
    this.bearing = 0,
    this.directionId = 0,
    this.timestamp,
    this.variantLabel,
    this.tripId,
  });

  factory VehiclePositionDto.fromJson(Map<String, dynamic> json) =>
      _$VehiclePositionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VehiclePositionDtoToJson(this);
}
