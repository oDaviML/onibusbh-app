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
  final String system;
  final double? price;

  const LineSummaryDto({
    required this.routeId,
    required this.shortName,
    required this.longName,
    this.color,
    this.textColor,
    this.directions = const [],
    this.avgTravelTime = 0,
    this.system = 'BHTRANS',
    this.price,
  });

  bool get isMetropolitan => system.toUpperCase() == 'OTIMO';

  String get systemLabel => isMetropolitan ? 'Ótimo · Metropolitano' : 'BHTrans · Municipal';

  String get shortSystemLabel => isMetropolitan ? 'Ótimo' : 'BHTrans';

  String? get formattedPrice {
    if (price == null || price! <= 0) return null;
    return 'R\$ ${price!.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Color get routeColor {
    if (color == null || color!.isEmpty) {
      return isMetropolitan ? const Color(0xFFD97706) : const Color(0xFF0F62FE);
    }
    final hex = color!.replaceFirst('#', '').trim();
    final parsed = int.tryParse('FF$hex', radix: 16);
    return parsed != null
        ? Color(parsed)
        : (isMetropolitan ? const Color(0xFFD97706) : const Color(0xFF0F62FE));
  }

  Color get routeTextColor {
    if (textColor == null || textColor!.isEmpty) return Colors.white;
    final hex = textColor!.replaceFirst('#', '').trim();
    final parsed = int.tryParse('FF$hex', radix: 16);
    return parsed != null ? Color(parsed) : Colors.white;
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
