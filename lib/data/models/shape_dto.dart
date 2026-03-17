import 'package:latlong2/latlong.dart';

class ShapeDto {
  final String shapeId;
  final List<LatLng> path;
  final double totalDistance;

  const ShapeDto({
    required this.shapeId,
    required this.path,
    this.totalDistance = 0.0,
  });

  factory ShapeDto.fromJson(Map<String, dynamic> json) {
    final coordinates = _extractCoordinates(json['path']);
    return ShapeDto(
      shapeId: json['shapeId'] as String? ?? '',
      path: coordinates,
      totalDistance: (json['totalDistance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static List<LatLng> _extractCoordinates(dynamic pathData) {
    if (pathData == null) return [];

    if (pathData is Map<String, dynamic>) {
      final coords = pathData['coordinates'];
      if (coords is List) {
        return coords.where((c) => c is List && c.length >= 2).map<LatLng>((c) {
          final list = c as List;
          final lon = (list[0] as num).toDouble();
          final lat = (list[1] as num).toDouble();
          return LatLng(lat, lon);
        }).toList();
      }
    }

    if (pathData is List) {
      return pathData.where((c) => c is List && c.length >= 2).map<LatLng>((c) {
        final list = c as List;
        final lon = (list[0] as num).toDouble();
        final lat = (list[1] as num).toDouble();
        return LatLng(lat, lon);
      }).toList();
    }

    return [];
  }
}
