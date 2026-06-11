import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'line_direction_dto.dart';

part 'line_summary_dto.g.dart';

@JsonSerializable()
class LineSummaryDto {
  final String routeId;
  final String shortName;
  final String longName;
  final String? color;
  final String? textColor;
  final List<LineDirectionDto> directions;
  final int avgTravelTime;

  const LineSummaryDto({
    required this.routeId,
    required this.shortName,
    required this.longName,
    this.color,
    this.textColor,
    this.directions = const [],
    this.avgTravelTime = 0,
  });

  Color get routeColor {
    if (color == null || color!.isEmpty) return const Color(0xFF0F62FE);
    final hex = color!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Color get routeTextColor {
    if (textColor == null || textColor!.isEmpty) return Colors.white;
    final hex = textColor!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  /// Returns a human-readable label for the line directions.
  /// - Two directions: "Estação Diamante ↔ Estação Vilarinho"
  /// - One direction: "Estação Barreiro"
  String get directionLabel {
    if (directions.isEmpty) return longName;
    if (directions.length == 1) return directions.first.headsign;
    return directions.map((d) => d.headsign).join(' ↔ ');
  }

  factory LineSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$LineSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LineSummaryDtoToJson(this);
}
