import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/stop_dto.dart';
import '../../../../data/models/prediction_response_dto.dart';
import '../widgets/stop_details_drawer.dart';

class GlobalStopsMapScreen extends StatefulWidget {
  const GlobalStopsMapScreen({super.key});

  @override
  State<GlobalStopsMapScreen> createState() => _GlobalStopsMapScreenState();
}

class _GlobalStopsMapScreenState extends State<GlobalStopsMapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  StreamSubscription<Position>? _positionStream;
  PredictionDto? _selectedLinePrediction;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _initLocationService();
  }

  Future<void> _initLocationService() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) return;

      Position pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLocation = LatLng(pos.latitude, pos.longitude);
        });
      }

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        if (mounted) {
          setState(() {
            _userLocation = LatLng(position.latitude, position.longitude);
          });
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _animateMapTo(LatLng target, double zoom) {
    final camera = _mapController.camera;
    final latTween =
        Tween<double>(begin: camera.center.latitude, end: target.latitude);
    final lngTween =
        Tween<double>(begin: camera.center.longitude, end: target.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: zoom);

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    final animation =
        CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _zoomIn() {
    final camera = _mapController.camera;
    _animateMapTo(camera.center, camera.zoom + 1);
  }

  void _zoomOut() {
    final camera = _mapController.camera;
    _animateMapTo(camera.center, camera.zoom - 1);
  }

  void _centerOnUser() {
    if (_userLocation != null) {
      _animateMapTo(_userLocation!, 15.0);
    }
  }

  void _centerOnSelectedRoute() {
    if (_selectedLinePrediction == null ||
        _selectedLinePrediction!.routePoints.isEmpty) {
      return;
    }

    final points = _selectedLinePrediction!.routePoints;
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    _animateMapTo(LatLng(centerLat, centerLng), 14.0);
  }

  void _onStopTapped(StopDto stop) {
    setState(() {
      _isDrawerOpen = true;
      _selectedLinePrediction = null;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        builder: (_, controller) => StopDetailsDrawer(
          stop: stop,
          onLineSelected: (prediction) {
            setState(() {
              _selectedLinePrediction = prediction;
            });
          },
        ),
      ),
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          _isDrawerOpen = false;
          _selectedLinePrediction = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasSelectedLine = _selectedLinePrediction != null;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(-19.9191, -43.9386),
                initialZoom: 14.0,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.onibusbh',
                ),

                if (hasSelectedLine)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _selectedLinePrediction!.routePoints,
                        color: _selectedLinePrediction!.routeColor,
                        strokeWidth: 5.0,
                        borderColor: _selectedLinePrediction!.routeColor
                            .withValues(alpha: 0.3),
                        borderStrokeWidth: 2.0,
                      ),
                    ],
                  ),

                MarkerLayer(
                  markers: [
                    if (_userLocation != null)
                      Marker(
                        point: _userLocation!,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withValues(alpha: 0.3),
                          ),
                          child: Center(
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ),

                    ...mockStops.map((stop) {
                      return Marker(
                        point: LatLng(stop.lat, stop.lon),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => _onStopTapped(stop),
                          child: _StopMarker(isDark: isDark),
                        ),
                      );
                    }),

                    if (hasSelectedLine)
                      ..._selectedLinePrediction!.vehicles.take(3).map((v) {
                        return Marker(
                          point: LatLng(v.lat, v.lon),
                          width: 56,
                          height: 56,
                          child: _BusMarker(
                            color: _selectedLinePrediction!.routeColor,
                            bearing: v.bearing,
                          ),
                        );
                      }),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            right: 16,
            bottom: _isDrawerOpen ? 160 : (MediaQuery.of(context).padding.bottom + 100),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: hasSelectedLine ? 1.0 : 0.0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    offset: hasSelectedLine
                        ? Offset.zero
                        : const Offset(0, 0.5),
                    child: IgnorePointer(
                      ignoring: !hasSelectedLine,
                      child: _MapControlButton(
                        isDark: isDark,
                        icon: Icons.route_rounded,
                        tooltip: 'Centralizar na rota',
                        onPressed: _centerOnSelectedRoute,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: hasSelectedLine ? 12 : 0),
                _MapControlButton(
                  isDark: isDark,
                  icon: Icons.my_location_rounded,
                  tooltip: 'Minha localização',
                  onPressed: _centerOnUser,
                ),
                const SizedBox(height: 12),
                Container(
                  width: 48,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate900 : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.slate900.withValues(
                          alpha: isDark ? 0.3 : 0.08,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        color: isDark ? Colors.white : AppColors.slate900,
                        iconSize: 20,
                        onPressed: _zoomIn,
                      ),
                      Container(
                        height: 1,
                        width: 24,
                        color: isDark ? AppColors.slate800 : AppColors.slate200,
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        color: isDark ? Colors.white : AppColors.slate900,
                        iconSize: 20,
                        onPressed: _zoomOut,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String? tooltip;
  final VoidCallback onPressed;

  const _MapControlButton({
    required this.isDark,
    required this.icon,
    this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.slate900.withValues(
              alpha: isDark ? 0.3 : 0.08,
            ),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        color: isDark ? Colors.white : AppColors.slate900,
        iconSize: 20,
        onPressed: onPressed,
      ),
    );
  }
}

class _StopMarker extends StatelessWidget {
  final bool isDark;

  const _StopMarker({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.slate800
            : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.directions_bus_filled_rounded,
        color: AppColors.primary,
        size: 16,
      ),
    );
  }
}

class _BusMarker extends StatelessWidget {
  final Color color;
  final double bearing;

  const _BusMarker({
    required this.color,
    required this.bearing,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: bearing * math.pi / 180,
          child: Align(
            alignment: Alignment.topCenter,
            child: FractionalTranslation(
              translation: const Offset(0.0, -0.1),
              child: Icon(Icons.eject, color: color, size: 20),
            ),
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.directions_bus,
            color: Colors.white,
            size: 18,
          ),
        ),
      ],
    );
  }
}
