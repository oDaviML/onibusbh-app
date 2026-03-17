import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class VehiclePositionDto {
  final String id;
  final double lat;
  final double lon;
  final double bearing;
  final int estimatedMinutes;

  VehiclePositionDto({
    required this.id,
    required this.lat,
    required this.lon,
    this.bearing = 0.0,
    required this.estimatedMinutes,
  });
}

class PredictionDto {
  final String lineId;
  final String lineShortName;
  final String destination;
  final int estimatedMinutes;
  final bool isLiveTracking;
  final Color routeColor;
  final List<LatLng> routePoints;
  final List<VehiclePositionDto> vehicles;

  PredictionDto({
    required this.lineId,
    required this.lineShortName,
    required this.destination,
    required this.estimatedMinutes,
    this.isLiveTracking = false,
    this.routeColor = const Color(0xFF0F62FE),
    this.routePoints = const [],
    this.vehicles = const [],
  });
}

class PredictionResponseDto {
  final List<PredictionDto> predictions;

  PredictionResponseDto({required this.predictions});
}

final mockStopPredictions = PredictionResponseDto(
  predictions: [
    PredictionDto(
      lineId: '1',
      lineShortName: '42',
      destination: 'Estação Central',
      estimatedMinutes: 2,
      isLiveTracking: true,
      routeColor: const Color(0xFF0F62FE),
      routePoints: [
        const LatLng(-19.912, -43.941),
        const LatLng(-19.915, -43.939),
        const LatLng(-19.917, -43.935),
        const LatLng(-19.919, -43.939),
        const LatLng(-19.922, -43.938),
      ],
      vehicles: [
        VehiclePositionDto(
          id: 'v1',
          lat: -19.913,
          lon: -43.940,
          bearing: 135.0,
          estimatedMinutes: 2,
        ),
        VehiclePositionDto(
          id: 'v2',
          lat: -19.910,
          lon: -43.942,
          bearing: 150.0,
          estimatedMinutes: 8,
        ),
        VehiclePositionDto(
          id: 'v3',
          lat: -19.907,
          lon: -43.944,
          bearing: 160.0,
          estimatedMinutes: 15,
        ),
      ],
    ),
    PredictionDto(
      lineId: '2',
      lineShortName: '10A',
      destination: 'Praça Norte',
      estimatedMinutes: 8,
      isLiveTracking: true,
      routeColor: const Color(0xFF198038),
      routePoints: [
        const LatLng(-19.920, -43.940),
        const LatLng(-19.923, -43.937),
        const LatLng(-19.925, -43.935),
        const LatLng(-19.928, -43.932),
        const LatLng(-19.932, -43.938),
      ],
      vehicles: [
        VehiclePositionDto(
          id: 'v4',
          lat: -19.921,
          lon: -43.939,
          bearing: 45.0,
          estimatedMinutes: 8,
        ),
        VehiclePositionDto(
          id: 'v5',
          lat: -19.924,
          lon: -43.936,
          bearing: 60.0,
          estimatedMinutes: 14,
        ),
        VehiclePositionDto(
          id: 'v6',
          lat: -19.928,
          lon: -43.933,
          bearing: 80.0,
          estimatedMinutes: 22,
        ),
      ],
    ),
    PredictionDto(
      lineId: '3',
      lineShortName: 'M3',
      destination: 'Aeroporto T1',
      estimatedMinutes: 15,
      routeColor: const Color(0xFFDA1E28),
      routePoints: [
        const LatLng(-19.917, -43.935),
        const LatLng(-19.920, -43.930),
        const LatLng(-19.925, -43.928),
        const LatLng(-19.930, -43.932),
        const LatLng(-19.935, -43.932),
      ],
      vehicles: [
        VehiclePositionDto(
          id: 'v7',
          lat: -19.918,
          lon: -43.934,
          bearing: 200.0,
          estimatedMinutes: 15,
        ),
        VehiclePositionDto(
          id: 'v8',
          lat: -19.914,
          lon: -43.937,
          bearing: 210.0,
          estimatedMinutes: 25,
        ),
        VehiclePositionDto(
          id: 'v9',
          lat: -19.911,
          lon: -43.940,
          bearing: 190.0,
          estimatedMinutes: 35,
        ),
      ],
    ),
    PredictionDto(
      lineId: '4',
      lineShortName: '88',
      destination: 'Parque Científico',
      estimatedMinutes: 24,
      routeColor: const Color(0xFF8A3FFC),
      routePoints: [
        const LatLng(-19.919, -43.939),
        const LatLng(-19.925, -43.942),
        const LatLng(-19.930, -43.940),
        const LatLng(-19.935, -43.938),
        const LatLng(-19.935, -43.932),
      ],
      vehicles: [
        VehiclePositionDto(
          id: 'v10',
          lat: -19.926,
          lon: -43.941,
          bearing: 300.0,
          estimatedMinutes: 24,
        ),
        VehiclePositionDto(
          id: 'v11',
          lat: -19.932,
          lon: -43.940,
          bearing: 310.0,
          estimatedMinutes: 32,
        ),
        VehiclePositionDto(
          id: 'v12',
          lat: -19.938,
          lon: -43.936,
          bearing: 320.0,
          estimatedMinutes: 40,
        ),
      ],
    ),
  ],
);
