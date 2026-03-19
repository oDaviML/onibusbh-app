import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/stop_dto.dart';
import '../../../../data/models/prediction_response_dto.dart';
import '../../../../data/providers/stop_providers.dart';
import '../../../../data/providers/line_providers.dart';
import '../../../widgets/scaffold_with_nav_bar.dart';
import '../../../widgets/bus_marker.dart';
import '../widgets/stop_details_drawer.dart';

class GlobalStopsMapScreen extends ConsumerStatefulWidget {
  const GlobalStopsMapScreen({super.key});

  @override
  ConsumerState<GlobalStopsMapScreen> createState() =>
      _GlobalStopsMapScreenState();
}

class _GlobalStopsMapScreenState extends ConsumerState<GlobalStopsMapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  StreamSubscription<Position>? _positionStream;
  StopDto? _selectedStop;
  late final AnimationController _drawerAnimController;
  late final Animation<Offset> _drawerSlideAnimation;
  List<StopDto> _stops = [];
  Timer? _debounceTimer;
  PredictionResponseDto? _selectedLinePrediction;
  Timer? _vehicleRefreshTimer;

  @override
  void initState() {
    super.initState();
    _initLocationService();
    _drawerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _drawerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _drawerAnimController,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStopsForCurrentView();
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
        try {
          _centerOnUser();
        } catch (_) {}
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

  void _fetchStopsForCurrentView() {
    final camera = _mapController.camera;

    if (camera.zoom < 16.0) {
      if (mounted && _stops.isNotEmpty) {
        setState(() {
          _stops = [];
        });
      }
      return;
    }

    final bounds = camera.visibleBounds;
    final bbox = (
      minLat: bounds.south,
      minLon: bounds.west,
      maxLat: bounds.north,
      maxLon: bounds.east,
    );

    ref
        .read(stopsByBBoxProvider(bbox).future)
        .then((stops) {
          if (mounted) {
            setState(() {
              _stops = stops;
            });
          }
        })
        .catchError((_) {});
  }

  void _onMapMoved() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchStopsForCurrentView();
    });
  }

  @override
  void dispose() {
    _vehicleRefreshTimer?.cancel();
    _debounceTimer?.cancel();
    _positionStream?.cancel();
    _mapController.dispose();
    _drawerAnimController.dispose();
    ScaffoldWithNavBar.forceHide.value = false;
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

  void _centerOnUser() {
    if (_userLocation != null) {
      _animateMapTo(_userLocation!, 16.0);
    }
  }

  void _onStopTapped(StopDto stop) {
    setState(() {
      _selectedStop = stop;
    });
    ScaffoldWithNavBar.forceHide.value = true;
    _drawerAnimController.forward();
  }

  void _closeDrawer() {
    ScaffoldWithNavBar.forceHide.value = false;
    _drawerAnimController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _selectedStop = null;
        });
      }
    });
  }

  void _onLineSelected(PredictionResponseDto? prediction) {
    setState(() {
      _selectedLinePrediction = prediction;
    });

    _vehicleRefreshTimer?.cancel();
    if (prediction != null) {
      _vehicleRefreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
        ref.invalidate(lineVehiclesProvider(prediction.routeId));
      });
    }
  }

  bool get _isDrawerOpen => _selectedStop != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final selectedLineId = _selectedLinePrediction?.routeId;
    final vehiclesAsync = selectedLineId != null 
        ? ref.watch(lineVehiclesProvider(selectedLineId)) 
        : null;
    final vehicles = vehiclesAsync?.value ?? [];

    final shapeAsync = selectedLineId != null
        ? ref.watch(lineShapeProvider((lineId: selectedLineId, direction: 0)))
        : null;
    final shapePoints = shapeAsync?.value?.path ?? [];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(-19.9191, -43.9386),
                initialZoom: 14.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    _onMapMoved();
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.onibusbh',
                ),

                if (shapePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: shapePoints,
                        color: _selectedLinePrediction!.routeColor,
                        strokeWidth: 4.0,
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
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    ..._stops.map((stop) {
                      return Marker(
                        point: LatLng(stop.latitude, stop.longitude),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => _onStopTapped(stop),
                          child: _StopMarker(isDark: isDark),
                        ),
                      );
                    }),
                    
                    if (_selectedLinePrediction != null)
                      ...vehicles.map((v) {
                        return Marker(
                          point: LatLng(v.latitude, v.longitude),
                          width: 44,
                          height: 44,
                          child: BusMarker(
                            color: _selectedLinePrediction!.routeColor,
                            bearing: v.bearing.toDouble(),
                            shortName: _selectedLinePrediction!.shortName,
                          ),
                        );
                      }),
                  ],
                ),
              ],
            ),
          ),

          if (_isDrawerOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeDrawer,
                child: const SizedBox.expand(),
              ),
            ),

          Positioned(
            right: 16,
            bottom: _isDrawerOpen
                ? (MediaQuery.of(context).size.height * 0.55 + 16)
                : (bottomInset + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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

          if (_selectedStop != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _drawerSlideAnimation,
                child: GestureDetector(
                  onTap: () {},
                  child: StopDetailsDrawer(
                    key: ValueKey(_selectedStop!.id),
                    stop: _selectedStop!,
                    onLineSelected: _onLineSelected,
                  ),
                ),
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
            color: AppColors.slate900.withValues(alpha: isDark ? 0.3 : 0.08),
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
        color: isDark ? AppColors.slate800 : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2.5),
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
