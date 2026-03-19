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
import '../../../widgets/scaffold_with_nav_bar.dart';
import '../../../widgets/user_location_marker.dart';
import '../widgets/stop_details_drawer.dart';
import 'stop_tracking_screen.dart';

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
  late final AnimationController _controlsAnimController;
  Offset? _backdropStartPos;
  bool _backdropMoved = false;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
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
    _controlsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controlsAnimController.forward();
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
        _centerOnUser();
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

  void _pushCurrentBBox() {
    if (!_isMapReady) return;
    final camera = _mapController.camera;
    if (camera.zoom < 13.0) return;

    final bounds = camera.visibleBounds;
    final bbox = (
      minLat: bounds.south,
      minLon: bounds.west,
      maxLat: bounds.north,
      maxLon: bounds.east,
    );
    ref.read(mapBboxProvider.notifier).updateBBox(bbox);
  }

  void _onMapReady() {
    _isMapReady = true;
    _initLocationService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pushCurrentBBox();
    });
  }

  void _onMapMoved() {
    _pushCurrentBBox();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController.dispose();
    _drawerAnimController.dispose();
    _controlsAnimController.dispose();
    ScaffoldWithNavBar.forceHide.value = false;
    super.dispose();
  }

  void _animateMapTo(LatLng target, double zoom, {VoidCallback? onComplete}) {
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
        onComplete?.call();
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _zoomIn() {
    final camera = _mapController.camera;
    _animateMapTo(camera.center, camera.zoom + 1, onComplete: _pushCurrentBBox);
  }

  void _zoomOut() {
    final camera = _mapController.camera;
    _animateMapTo(camera.center, camera.zoom - 1, onComplete: _pushCurrentBBox);
  }

  void _centerOnUser() {
    if (_userLocation != null) {
      _animateMapTo(_userLocation!, 16.0, onComplete: _pushCurrentBBox);
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

  void _onOpenTracking(PredictionResponseDto prediction) {
    final stop = _selectedStop;
    if (stop == null) return;

    ScaffoldWithNavBar.forceHide.value = false;
    _drawerAnimController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _selectedStop = null;
        });
      }
    });

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            StopTrackingScreen(stop: stop, prediction: prediction),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  bool get _isDrawerOpen => _selectedStop != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final stopsAsync = ref.watch(stopsProvider);
    final stops = stopsAsync.value ?? [];

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
                onMapReady: _onMapReady,
                onPositionChanged: (position, hasGesture) {
                  _onMapMoved();
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.onibusbh',
                ),
                MarkerLayer(
                  markers: [
                    if (_userLocation != null)
                      Marker(
                        point: _userLocation!,
                        width: 48,
                        height: 48,
                        child: const UserLocationMarker(size: 16),
                      ),
                    ...stops.map((stop) {
                      return Marker(
                        point: LatLng(stop.latitude, stop.longitude),
                        width: 36,
                        height: 36,
                        child: GestureDetector(
                          onTap: () => _onStopTapped(stop),
                          child: _StopMarker(isDark: isDark),
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
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (event) {
                  _backdropStartPos = event.position;
                  _backdropMoved = false;
                },
                onPointerMove: (event) {
                  if (_backdropStartPos != null) {
                    final dx = event.position.dx - _backdropStartPos!.dx;
                    final dy = event.position.dy - _backdropStartPos!.dy;
                    if (dx * dx + dy * dy > 100) {
                      _backdropMoved = true;
                    }
                  }
                },
                onPointerUp: (event) {
                  if (!_backdropMoved) {
                    _closeDrawer();
                  }
                  _backdropStartPos = null;
                },
                child: const SizedBox.expand(),
              ),
            ),

          Positioned(
            right: 16,
            bottom: _isDrawerOpen
                ? (MediaQuery.of(context).size.height * 0.55 + 16)
                : (bottomInset + 20),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controlsAnimController,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
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
                          color: isDark
                              ? AppColors.slate800
                              : AppColors.slate200,
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
                    onOpenTracking: _onOpenTracking,
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
        Icons.location_on_rounded,
        color: AppColors.primary,
        size: 18,
      ),
    );
  }
}
