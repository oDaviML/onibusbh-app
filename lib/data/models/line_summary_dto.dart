import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'line_summary_dto.g.dart';

@JsonSerializable()
class LineSummaryDto {
  final String routeId;
  final String shortName;
  final String longName;
  final String? color;
  final String? textColor;
  final bool isBidirectional;
  final int stopCount;
  final int avgTravelTime;

  const LineSummaryDto({
    required this.routeId,
    required this.shortName,
    required this.longName,
    this.color,
    this.textColor,
    this.isBidirectional = false,
    this.stopCount = 0,
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

  factory LineSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$LineSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LineSummaryDtoToJson(this);
}
