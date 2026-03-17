class LineSummaryDto {
  final String id;
  final String shortName; // e.g. "42", "10A"
  final String longName;  // e.g. "Downtown Express"
  final String destination; // e.g. "To Central Station"
  final int stopsRemaining; // e.g. 12
  final int estimatedMinutes; // e.g. 6

  LineSummaryDto({
    required this.id,
    required this.shortName,
    required this.longName,
    required this.destination,
    required this.stopsRemaining,
    required this.estimatedMinutes,
  });
}

// Mock Data
final mockLines = [
  LineSummaryDto(id: '1', shortName: '42', longName: 'Downtown Express', destination: 'To Central Station', stopsRemaining: 12, estimatedMinutes: 6),
  LineSummaryDto(id: '2', shortName: '10A', longName: 'Riverside Loop', destination: 'To North Plaza', stopsRemaining: 8, estimatedMinutes: 12),
  LineSummaryDto(id: '3', shortName: 'M3', longName: 'Metro Blue Line', destination: 'To Airport T1', stopsRemaining: 4, estimatedMinutes: 2),
  LineSummaryDto(id: '4', shortName: '88', longName: 'University Ave', destination: 'To Science Park', stopsRemaining: 15, estimatedMinutes: 18),
];
