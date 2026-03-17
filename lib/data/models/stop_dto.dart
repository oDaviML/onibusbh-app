import 'package:flutter/material.dart';

class StopDto {
  final String id;
  final String name;
  final String locationArea;
  final double lat;
  final double lon;
  final double bearing;
  final Color routeColor;

  StopDto({
    required this.id,
    required this.name,
    required this.locationArea,
    required this.lat,
    required this.lon,
    this.bearing = 0.0,
    this.routeColor = const Color(0xFF0F62FE),
  });
}

final mockCurrentStop = StopDto(
  id: '1',
  name: 'Central Station',
  locationArea: 'Downtown District',
  lat: -19.9191,
  lon: -43.9386,
  bearing: 45.0,
  routeColor: const Color(0xFF0F62FE),
);

final mockStops = [
  mockCurrentStop,
  StopDto(
    id: '2',
    name: 'Praça Sete',
    locationArea: 'Central',
    lat: -19.9167,
    lon: -43.9345,
    bearing: 120.0,
    routeColor: const Color(0xFF198038),
  ),
  StopDto(
    id: '3',
    name: 'Praça da Liberdade',
    locationArea: 'Savassi',
    lat: -19.9317,
    lon: -43.9380,
    bearing: 210.0,
    routeColor: const Color(0xFFDA1E28),
  ),
  StopDto(
    id: '4',
    name: 'Rodoviária',
    locationArea: 'Centro',
    lat: -19.9120,
    lon: -43.9410,
    bearing: 330.0,
    routeColor: const Color(0xFF8A3FFC),
  ),
];
