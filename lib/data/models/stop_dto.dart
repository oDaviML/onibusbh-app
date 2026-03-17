class StopDto {
  final String id;
  final String name;
  final String locationArea;
  final double lat;
  final double lon;
  final List<String> lineIds;

  StopDto({
    required this.id,
    required this.name,
    required this.locationArea,
    required this.lat,
    required this.lon,
    this.lineIds = const [],
  });
}

final mockCurrentStop = StopDto(
  id: '1',
  name: 'Estação Central',
  locationArea: 'Centro',
  lat: -19.9191,
  lon: -43.9386,
  lineIds: ['1', '2', '3'],
);

final mockStops = [
  mockCurrentStop,
  StopDto(
    id: '2',
    name: 'Praça Sete',
    locationArea: 'Central',
    lat: -19.9167,
    lon: -43.9345,
    lineIds: ['1', '3'],
  ),
  StopDto(
    id: '3',
    name: 'Praça da Liberdade',
    locationArea: 'Savassi',
    lat: -19.9317,
    lon: -43.9380,
    lineIds: ['2', '4'],
  ),
  StopDto(
    id: '4',
    name: 'Rodoviária',
    locationArea: 'Centro',
    lat: -19.9120,
    lon: -43.9410,
    lineIds: ['1', '2', '3', '4'],
  ),
  StopDto(
    id: '5',
    name: 'Savassi',
    locationArea: 'Savassi',
    lat: -19.9350,
    lon: -43.9320,
    lineIds: ['3', '4'],
  ),
  StopDto(
    id: '6',
    name: 'Hospital das Clínicas',
    locationArea: 'Santa Efigênia',
    lat: -19.9220,
    lon: -43.9260,
    lineIds: ['1', '4'],
  ),
];
