class StopDto {
  final String id;
  final String name;
  final String locationArea;
  final double lat;
  final double lon;

  StopDto({
    required this.id,
    required this.name,
    required this.locationArea,
    required this.lat,
    required this.lon,
  });
}

// Mock Data
final mockCurrentStop = StopDto(
  id: '1',
  name: 'Central Station',
  locationArea: 'Downtown District',
  lat: -19.9191,
  lon: -43.9386,
);

final mockStops = [
  mockCurrentStop,
  StopDto(
    id: '2',
    name: 'Praça Sete',
    locationArea: 'Central',
    lat: -19.9167,
    lon: -43.9345,
  ),
  StopDto(
    id: '3',
    name: 'Praça da Liberdade',
    locationArea: 'Savassi',
    lat: -19.9317,
    lon: -43.9380,
  ),
  StopDto(
    id: '4',
    name: 'Rodoviária',
    locationArea: 'Centro',
    lat: -19.9120,
    lon: -43.9410,
  ),
];
