import 'package:flutter/material.dart';

class LineSummaryDto {
  final String id;
  final String shortName;
  final String longName;
  final String destination;
  final int stopsRemaining;
  final int estimatedMinutes;
  final Color routeColor;

  LineSummaryDto({
    required this.id,
    required this.shortName,
    required this.longName,
    required this.destination,
    required this.stopsRemaining,
    required this.estimatedMinutes,
    this.routeColor = const Color(0xFF0F62FE),
  });
}

final mockLines = [
  LineSummaryDto(
    id: '1',
    shortName: '42',
    longName: 'Downtown Express',
    destination: 'To Central Station',
    stopsRemaining: 12,
    estimatedMinutes: 6,
    routeColor: const Color(0xFF0F62FE),
  ),
  LineSummaryDto(
    id: '2',
    shortName: '10A',
    longName: 'Riverside Loop',
    destination: 'To North Plaza',
    stopsRemaining: 8,
    estimatedMinutes: 12,
    routeColor: const Color(0xFF198038),
  ),
  LineSummaryDto(
    id: '3',
    shortName: 'M3',
    longName: 'Metro Blue Line',
    destination: 'To Airport T1',
    stopsRemaining: 4,
    estimatedMinutes: 2,
    routeColor: const Color(0xFFDA1E28),
  ),
  LineSummaryDto(
    id: '4',
    shortName: '88',
    longName: 'University Ave',
    destination: 'To Science Park',
    stopsRemaining: 15,
    estimatedMinutes: 18,
    routeColor: const Color(0xFF8A3FFC),
  ),
];
