import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/map_styles.dart';
import '../../../../data/models/line_summary_dto.dart';
import '../../../../data/providers/line_providers.dart';
import '../../../widgets/markers/stop_marker.dart';
import '../../../widgets/markers/vehicle_marker.dart';
import '../../../widgets/markers/user_location_marker.dart';
import '../../../widgets/map/map_controls.dart';

class LineMapDetailsScreen extends ConsumerStatefulWidget {
  final LineSummaryDto line;
  final int direction;

  const LineMapDetailsScreen({
    super.key,
    required this.line,
    required this.direction,
  });

  @override
  ConsumerState<LineMapDetailsScreen> createState() =>
      _LineMapDetailsScreenState();
}

class _LineMapDetailsScreenState extends ConsumerState<LineMapDetailsScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  StreamSubscription<Position>? _positionStream;
  Timer? _vehicleRefreshTimer;
  bool _hasAutoFocused = false;

  @override
  void initState() {
    super.initState();
    _initLocationService();
    _startVehiclePolling();
  }

  void _autoFocusOnRoute(List<LatLng> routePoints) {
    if (_hasAutoFocused || routePoints.isEmpty) return;
    _hasAutoFocused = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerOnRoute(routePoints);
    });
  }

  void _startVehiclePolling() {
    _vehicleRefreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      ref.invalidate(
        lineVehiclesProvider((
          lineId: widget.line.routeId,
          direction: widget.direction,
        )),
      );
    });
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

      _positionStream =
          Geolocator.getPositionStream(
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
    _vehicleRefreshTimer?.cancel();
    _positionStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _animateMapTo(LatLng target, double zoom) {
    final camera = _mapController.camera;
    final latTween = Tween<double>(
      begin: camera.center.latitude,
      end: target.latitude,
    );
    final lngTween = Tween<double>(
      begin: camera.center.longitude,
      end: target.longitude,
    );
    final zoomTween = Tween<double>(begin: camera.zoom, end: zoom);

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );

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

  void _centerOnRoute(List<LatLng> points) {
    if (points.isEmpty) return;

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

    final bounds = LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));

    final cameraFit = CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.all(64),
    );

    final fitted = cameraFit.fit(_mapController.camera);
    _animateMapTo(fitted.center, fitted.zoom);
  }

  void _centerOnUser() {
    if (_userLocation != null) {
      _animateMapTo(_userLocation!, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    final shapeParams = (
      lineId: widget.line.routeId,
      direction: widget.direction,
    );
    final stopsParams = (
      lineId: widget.line.routeId,
      direction: widget.direction,
    );

    final shapeAsync = ref.watch(lineShapeProvider(shapeParams));
    final stopsAsync = ref.watch(lineStopsProvider(stopsParams));
    final vehiclesAsync = ref.watch(
      lineVehiclesProvider((
        lineId: widget.line.routeId,
        direction: widget.direction,
      )),
    );

    final routePoints = shapeAsync.value?.path ?? [];

    shapeAsync.whenData((shape) {
      if (shape.path.isNotEmpty) {
        _autoFocusOnRoute(shape.path);
      }
    });
    final lineStops = stopsAsync.value ?? [];
    final vehicles = vehiclesAsync.value ?? [];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(-19.920, -43.935),
                initialZoom: 13.5,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: MapStyles.getTileUrl(isDark),
                  subdomains: MapStyles.subdomains,
                  userAgentPackageName: 'com.onibusbh.app',
                ),
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        color: widget.line.routeColor,
                        strokeWidth: isDark ? 6.0 : 5.0,
                        borderColor: widget.line.routeColor.withValues(
                          alpha: isDark ? 0.6 : 0.3,
                        ),
                        borderStrokeWidth: isDark ? 3.0 : 2.0,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (_userLocation != null)
                      Marker(
                        point: _userLocation!,
                        width: 48,
                        height: 48,
                        child: RepaintBoundary(
                          child: UserLocationMarker(size: 16, isDark: isDark),
                        ),
                      ),
                    ...lineStops.map((stop) {
                      return Marker(
                        point: LatLng(stop.latitude, stop.longitude),
                        width: 24,
                        height: 24,
                        child: StopMarker(
                          isDark: isDark,
                          color: widget.line.routeColor,
                          size: 20,
                        ),
                      );
                    }),
                    ...vehicles.map((v) {
                      return Marker(
                        point: LatLng(v.latitude, v.longitude),
                        width: 48,
                        height: 48,
                        child: VehicleMarker(
                          color: widget.line.routeColor,
                          bearing: v.bearing.toDouble(),
                          isDark: isDark,
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            top: topPadding + 8,
            left: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MapControlButton(
                  isDark: isDark,
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.slate900.withValues(alpha: 0.9)
                          : Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.slate900.withValues(
                            alpha: isDark ? 0.3 : 0.08,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: widget.line.routeColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.line.routeColor.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: Text(
                                widget.line.shortName,
                                style: AppTypography.busNumber.copyWith(
                                  color: widget.line.routeTextColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.line.longName,
                                style: AppTypography.titleMedium.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.slate900,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Text(
                                    widget.direction == 0 ? 'Ida' : 'Volta',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: AppColors.slate500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.line.routeColor.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${vehicles.length} veículos',
                                      style: AppTypography.caption.copyWith(
                                        color: widget.line.routeColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (shapeAsync.isLoading || stopsAsync.isLoading)
            Positioned(
              top: topPadding + 90,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.slate800.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Carregando rota...',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 24,
            child: MapControlsColumn(
              isDark: isDark,
              onCenterRoute: () => _centerOnRoute(routePoints),
              onCenterUser: _centerOnUser,
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
            ),
          ),
        ],
      ),
    );
  }
}
