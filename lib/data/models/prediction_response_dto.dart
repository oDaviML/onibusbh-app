class PredictionDto {
  final String lineShortName;
  final String destination;
  final int estimatedMinutes;
  final bool isLiveTracking;

  PredictionDto({
    required this.lineShortName,
    required this.destination,
    required this.estimatedMinutes,
    this.isLiveTracking = false,
  });
}

class PredictionResponseDto {
  final List<PredictionDto> predictions;

  PredictionResponseDto({required this.predictions});
}

final mockStopPredictions = PredictionResponseDto(
  predictions: [
    PredictionDto(
      lineShortName: '42',
      destination: 'To Central Station',
      estimatedMinutes: 2,
      isLiveTracking: true,
    ),
    PredictionDto(
      lineShortName: '10A',
      destination: 'To Riverside Loop',
      estimatedMinutes: 8,
      isLiveTracking: true,
    ),
    PredictionDto(
      lineShortName: 'M3',
      destination: 'To Airport T1',
      estimatedMinutes: 15,
    ),
    PredictionDto(
      lineShortName: '88',
      destination: 'To Science Park',
      estimatedMinutes: 24,
    ),
  ],
);
