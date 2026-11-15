import 'package:flutter/material.dart';
import 'prediction_response_dto.dart';

class PredictionGroup {
  final String routeId;
  final String shortName;
  final String longName;
  final String? color;
  final String system;
  final Map<int, PredictionResponseDto> directions;

  const PredictionGroup({
    required this.routeId,
    required this.shortName,
    required this.longName,
    this.color,
    this.system = 'BHTRANS',
    required this.directions,
  });

  bool get isGrouped => directions.length > 1;

  bool get isMetropolitan =>
      system.toUpperCase() == 'OTIMO' || routeId.startsWith('otimo_');

  String get shortSystemLabel => isMetropolitan ? 'Ótimo' : 'BHTrans';

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

  List<ArrivalPredictionDto> get allArrivals {
    final list = <ArrivalPredictionDto>[];
    for (final prediction in directions.values) {
      list.addAll(prediction.arrivals);
    }
    list.sort((a, b) => a.etaMinutes.compareTo(b.etaMinutes));
    return list;
  }

  int? get nextArrivalMinutes {
    final arrivals = allArrivals;
    if (arrivals.isEmpty) return null;
    return arrivals.first.etaMinutes;
  }

  static List<PredictionGroup> groupPredictions(
    List<PredictionResponseDto> predictions,
  ) {
    final map = <String, PredictionGroup>{};
    for (final prediction in predictions) {
      if (map.containsKey(prediction.routeId)) {
        final existing = map[prediction.routeId]!;
        final merged = Map<int, PredictionResponseDto>.from(
          existing.directions,
        );
        merged[prediction.direction] = prediction;
        map[prediction.routeId] = PredictionGroup(
          routeId: existing.routeId,
          shortName: existing.shortName,
          longName: existing.longName,
          color: existing.color,
          system: existing.system,
          directions: merged,
        );
      } else {
        map[prediction.routeId] = PredictionGroup(
          routeId: prediction.routeId,
          shortName: prediction.shortName,
          longName: prediction.longName,
          color: prediction.color,
          system: prediction.system,
          directions: {prediction.direction: prediction},
        );
      }
    }
    return map.values.toList();
  }
}
