import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'prediction_response_dto.g.dart';

@JsonSerializable()
class ArrivalPredictionDto {
  final int etaMinutes;
  final bool isStale;
  final String? vehicleId;
  final double? latitude;
  final double? longitude;
  final int? bearing;

  const ArrivalPredictionDto({
    required this.etaMinutes,
    this.isStale = false,
    this.vehicleId,
    this.latitude,
    this.longitude,
    this.bearing,
  });

  factory ArrivalPredictionDto.fromJson(Map<String, dynamic> json) =>
      _$ArrivalPredictionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ArrivalPredictionDtoToJson(this);
}

@JsonSerializable()
class PredictionResponseDto {
  final String routeId;
  final String shortName;
  final String longName;
  final String? color;
  final String? headsign;
  final List<ArrivalPredictionDto> arrivals;

  const PredictionResponseDto({
    required this.routeId,
    required this.shortName,
    required this.longName,
    this.color,
    this.headsign,
    this.arrivals = const [],
  });

  Color get routeColor {
    if (color == null || color!.isEmpty) return const Color(0xFF0F62FE);
    final hex = color!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  int? get nextArrivalMinutes {
    if (arrivals.isEmpty) return null;
    return arrivals.map((a) => a.etaMinutes).reduce((a, b) => a < b ? a : b);
  }

  factory PredictionResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PredictionResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PredictionResponseDtoToJson(this);
}
