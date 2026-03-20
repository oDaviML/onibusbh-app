import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/stop_dto.dart';
import '../../../../data/models/prediction_response_dto.dart';
import '../../../../data/providers/line_providers.dart';
import '../../../../data/providers/stop_providers.dart';
import '../../../widgets/bus_marker.dart';
import '../../../widgets/user_location_marker.dart';

class StopTrackingScreen extends ConsumerStatefulWidget {
  final StopDto stop;
  final PredictionResponseDto prediction;

  const StopTrackingScreen({
    super.key,
    required this.stop,
    required this.prediction,
  });

  @override
  ConsumerState<StopTrackingScreen> createState() => _StopTrackingScreenState();
}

class _StopTrackingScreenState extends ConsumerState<StopTrackingScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  StreamSubscription<Position>? _positionStream;
  Timer? _vehicleRefreshTimer;
  Timer? _predictionRefreshTimer;
  late final AnimationController _bubblesAnimController;
  late final AnimationController _controlsAnimController;

  @override
  void initState() {
    super.initState();
    _initLocationService();
    _startPolling();

    _bubblesAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _controlsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bubblesAnimController.forward();
      _controlsAnimController.forward();
    });
  }

  void _startPolling() {
    _vehicleRefreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      ref.invalidate(lineVehiclesProvider(widget.prediction.routeId));
    });
    _predictionRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.invalidate(stopPredictionsProvider(widget.stop.id));
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
    _predictionRefreshTimer?.cancel();
    _positionStream?.cancel();
    _mapController.dispose();
    _bubblesAnimController.dispose();
    _controlsAnimController.dispose();
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
      padding: const EdgeInsets.all(80),
    );
    final fitted = cameraFit.fit(_mapController.camera);
    _animateMapTo(fitted.center, fitted.zoom);
  }

  void _centerOnUser() {
    if (_userLocation != null) {
      _animateMapTo(_userLocation!, 16.0);
    }
  }

  void _centerOnStop() {
    _animateMapTo(
      LatLng(widget.stop.latitude, widget.stop.longitude),
      _mapController.camera.zoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final routeColor = widget.prediction.routeColor;

    final shapeAsync = ref.watch(
      lineShapeProvider((lineId: widget.prediction.routeId, direction: 0)),
    );
    final vehiclesAsync = ref.watch(
      lineVehiclesProvider(widget.prediction.routeId),
    );
    final predictionsAsync = ref.watch(stopPredictionsProvider(widget.stop.id));

    final routePoints = shapeAsync.value?.path ?? [];
    final vehicles = vehiclesAsync.value ?? [];

    final predictions = predictionsAsync.value;
    final currentPrediction = predictions?.firstWhere(
      (p) => p.routeId == widget.prediction.routeId,
      orElse: () => widget.prediction,
    );
    final arrivals = (currentPrediction ?? widget.prediction).arrivals
        .take(3)
        .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  widget.stop.latitude,
                  widget.stop.longitude,
                ),
                initialZoom: 16.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.onibusbh.app',
                ),
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        color: routeColor,
                        strokeWidth: 5.0,
                        borderColor: routeColor.withValues(alpha: 0.3),
                        borderStrokeWidth: 2.0,
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
                        child: const UserLocationMarker(size: 16),
                      ),
                    Marker(
                      point: LatLng(
                        widget.stop.latitude,
                        widget.stop.longitude,
                      ),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.slate800 : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: routeColor, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: routeColor.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: routeColor,
                          size: 22,
                        ),
                      ),
                    ),
                    ...vehicles.map(
                      (v) => Marker(
                        point: LatLng(v.latitude, v.longitude),
                        width: 44,
                        height: 44,
                        child: BusMarker(
                          color: routeColor,
                          bearing: v.bearing.toDouble(),
                          shortName: widget.prediction.shortName,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Line info header
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 100,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controlsAnimController,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.slate900.withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
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
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: routeColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            widget.prediction.shortName,
                            style: AppTypography.quicksand.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.stop.name,
                            style: AppTypography.quicksand.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.slate900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.prediction.headsign ??
                                widget.prediction.longName,
                            style: AppTypography.nunito.copyWith(
                              fontSize: 12,
                              color: AppColors.slate500,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (vehicles.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: routeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${vehicles.length}',
                          style: AppTypography.nunito.copyWith(
                            color: routeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Left side controls
          Positioned(
            left: 16,
            bottom: bottomInset + 24,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(-1, 0),
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
                    icon: Icons.route_rounded,
                    tooltip: 'Centralizar na rota',
                    onPressed: () => _centerOnRoute(routePoints),
                  ),
                  const SizedBox(height: 12),
                  _MapControlButton(
                    isDark: isDark,
                    icon: Icons.my_location_rounded,
                    tooltip: 'Minha localização',
                    onPressed: _centerOnUser,
                  ),
                  const SizedBox(height: 12),
                  _MapControlButton(
                    isDark: isDark,
                    icon: Icons.place_rounded,
                    tooltip: 'Centralizar na parada',
                    onPressed: _centerOnStop,
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

          // Right side arrival bubbles (Stitch design)
          Positioned(
            right: 0,
            bottom: bottomInset + 24,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _bubblesAnimController,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (arrivals.isNotEmpty) ...[
                      _ArrivalBubble(
                        minutes: arrivals[0].etaMinutes,
                        size: 80,
                        isPrimary: true,
                        color: routeColor,
                        isDark: isDark,
                        delay: 0,
                        animation: _bubblesAnimController,
                      ),
                      if (arrivals.length > 1) ...[
                        const SizedBox(height: 12),
                        _ArrivalBubble(
                          minutes: arrivals[1].etaMinutes,
                          size: 64,
                          isPrimary: false,
                          color: routeColor,
                          isDark: isDark,
                          delay: 100,
                          animation: _bubblesAnimController,
                        ),
                      ],
                      if (arrivals.length > 2) ...[
                        const SizedBox(height: 10),
                        _ArrivalBubble(
                          minutes: arrivals[2].etaMinutes,
                          size: 56,
                          isPrimary: false,
                          color: routeColor,
                          isDark: isDark,
                          delay: 200,
                          animation: _bubblesAnimController,
                        ),
                      ],
                    ] else ...[
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.slate800 : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.slate900.withValues(alpha: 0.1),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '--',
                            style: AppTypography.quicksand.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.slate400,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _MapControlButton(
                      isDark: isDark,
                      icon: Icons.close_rounded,
                      tooltip: 'Fechar',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrivalBubble extends StatelessWidget {
  final int minutes;
  final double size;
  final bool isPrimary;
  final Color color;
  final bool isDark;
  final int delay;
  final AnimationController animation;

  const _ArrivalBubble({
    required this.minutes,
    required this.size,
    required this.isPrimary,
    required this.color,
    required this.isDark,
    required this.delay,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = size * 0.32;
    final labelSize = size * 0.15;

    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: Interval(delay / 600, 1.0, curve: Curves.easeOutBack),
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isPrimary
              ? color
              : (isDark ? AppColors.slate800 : Colors.white),
          shape: BoxShape.circle,
          border: isPrimary
              ? null
              : Border.all(color: color.withValues(alpha: 0.2), width: 2),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? color.withValues(alpha: 0.4)
                  : AppColors.slate900.withValues(alpha: 0.1),
              blurRadius: isPrimary ? 20 : 16,
              offset: Offset(0, isPrimary ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$minutes',
              style: AppTypography.quicksand.copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? Colors.white : AppColors.slate900),
                height: 1.0,
              ),
            ),
            Text(
              'MIN',
              style: AppTypography.nunito.copyWith(
                fontSize: labelSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppColors.slate400,
              ),
            ),
          ],
        ),
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
