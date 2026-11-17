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
import '../../../../data/models/stop_dto.dart';
import '../../../../data/models/prediction_response_dto.dart';
import '../../../../data/models/shape_dto.dart';
import '../../../../data/models/vehicle_position_dto.dart';
import '../../../../data/providers/line_providers.dart';
import '../../../../data/providers/stop_providers.dart';
import '../../../widgets/markers/stop_marker.dart';
import '../../../widgets/markers/vehicle_marker.dart';
import '../../../widgets/markers/user_location_marker.dart';
import '../../../widgets/live_pulse_countdown_badge.dart';
import '../../../widgets/map/map_controls.dart';
import '../../lines/screens/line_map_details_screen.dart';
import '../widgets/arrival_bubbles.dart';

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
  static const int _refreshIntervalSeconds = 10;

  final MapController _mapController = MapController();
  AnimationController? _mapMoveController;
  LatLng? _userLocation;
  StreamSubscription<Position>? _positionStream;
  Timer? _pollingSecondTimer;
  int _secondsUntilRefresh = _refreshIntervalSeconds;
  bool _hasAutoFittedVehicles = false;
  bool _isMapReady = false;
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
    _pollingSecondTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsUntilRefresh <= 1) {
        _refreshNow();
      } else {
        setState(() => _secondsUntilRefresh--);
      }
    });
  }

  void _refreshNow() {
    if (!mounted) return;
    setState(() => _secondsUntilRefresh = _refreshIntervalSeconds);
    ref.invalidate(
      lineVehiclesProvider((lineId: widget.prediction.routeId, tripId: null)),
    );
    ref.invalidate(stopPredictionsProvider(widget.stop.id));
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
    _pollingSecondTimer?.cancel();
    _positionStream?.cancel();
    _mapMoveController?.dispose();
    _mapMoveController = null;
    _mapController.dispose();
    _bubblesAnimController.dispose();
    _controlsAnimController.dispose();
    super.dispose();
  }

  void _animateMapTo(LatLng target, double zoom) {
    if (!mounted) return;
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

    _mapMoveController?.dispose();
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _mapMoveController = controller;
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );

    controller.addListener(() {
      if (!mounted) return;
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_mapMoveController == controller) {
          _mapMoveController = null;
        }
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

  List<VehiclePositionDto> _resolveDisplayVehicles(
    List<VehiclePositionDto>? apiVehicles,
    PredictionResponseDto prediction,
  ) {
    final allApi = apiVehicles ?? const <VehiclePositionDto>[];
    final matchingApi = allApi
        .where((v) => v.directionId == prediction.direction)
        .toList();
    if (matchingApi.isNotEmpty) {
      return matchingApi;
    }
    if (allApi.isNotEmpty) {
      return allApi;
    }

    final seenIds = <String>{};
    final fallback = <VehiclePositionDto>[];
    for (final arrival in prediction.arrivals) {
      if (arrival.latitude == null || arrival.longitude == null) continue;
      final vid = arrival.vehicleId ?? 'pred_${arrival.etaMinutes}';
      if (!seenIds.add(vid)) continue;
      fallback.add(
        VehiclePositionDto(
          vehicleId: vid,
          latitude: arrival.latitude!,
          longitude: arrival.longitude!,
          bearing: arrival.bearing ?? 0,
          directionId: arrival.directionId ?? prediction.direction,
          variantLabel: arrival.variantLabel,
        ),
      );
    }
    return fallback;
  }

  String _vehicleLabel(VehiclePositionDto v) {
    final cleaned = v.vehicleId
        .replaceFirst(RegExp(r'^otimo_', caseSensitive: false), '')
        .trim();
    if (cleaned.isNotEmpty && !cleaned.startsWith('pred_')) {
      return 'Carro $cleaned';
    }
    return 'Linha ${widget.prediction.shortName}';
  }

  void _fitStopAndClosestVehicle(List<VehiclePositionDto> vehicles) {
    if (vehicles.isEmpty || !_isMapReady) return;
    final stopPoint = LatLng(widget.stop.latitude, widget.stop.longitude);
    const distance = Distance();
    LatLng closestPoint = LatLng(
      vehicles.first.latitude,
      vehicles.first.longitude,
    );
    double minMeters = distance.as(LengthUnit.Meter, stopPoint, closestPoint);
    for (final v in vehicles.skip(1)) {
      final candidate = LatLng(v.latitude, v.longitude);
      final meters = distance.as(LengthUnit.Meter, stopPoint, candidate);
      if (meters < minMeters) {
        minMeters = meters;
        closestPoint = candidate;
      }
    }
    if (minMeters < 50) {
      _animateMapTo(stopPoint, 16.0);
      return;
    }
    final bounds = LatLngBounds.fromPoints([stopPoint, closestPoint]);
    final fitted = CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.fromLTRB(64, 120, 64, 140),
      maxZoom: 16.0,
    ).fit(_mapController.camera);
    _animateMapTo(fitted.center, fitted.zoom);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final routeColor = widget.prediction.routeColor;

    final variantAsync = ref.watch(
      lineVariantForDirectionProvider((
        lineId: widget.prediction.routeId,
        directionId: widget.prediction.direction,
      )),
    );
    final tripId = variantAsync.value?.tripId;

    final shapeAsync = tripId != null
        ? ref.watch(
            lineShapeProvider((
              lineId: widget.prediction.routeId,
              tripId: tripId,
            )),
          )
        : const AsyncValue<ShapeDto>.loading();

    final vehiclesAsync = ref.watch(
      lineVehiclesProvider((lineId: widget.prediction.routeId, tripId: null)),
    );
    final predictionsAsync = ref.watch(stopPredictionsProvider(widget.stop.id));

    final routePoints = shapeAsync.value?.path ?? [];
    final predictions = predictionsAsync.value;
    final currentPrediction =
        predictions?.firstWhere(
          (p) =>
              p.routeId == widget.prediction.routeId &&
              p.direction == widget.prediction.direction,
          orElse: () => widget.prediction,
        ) ??
        widget.prediction;
    final vehicles = _resolveDisplayVehicles(
      vehiclesAsync.value,
      currentPrediction,
    );

    if (_isMapReady && !_hasAutoFittedVehicles && vehicles.isNotEmpty) {
      _hasAutoFittedVehicles = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fitStopAndClosestVehicle(vehicles);
        }
      });
    }

    final arrivals = currentPrediction.arrivals.take(3).toList();

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
                onMapReady: () {
                  if (mounted) {
                    setState(() => _isMapReady = true);
                  }
                },
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                MapStyles.buildTileLayer(isDark: isDark),
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        color: routeColor,
                        strokeWidth: isDark ? 6.0 : 5.0,
                        borderColor: routeColor.withValues(
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
                    Marker(
                      point: LatLng(
                        widget.stop.latitude,
                        widget.stop.longitude,
                      ),
                      width: 48,
                      height: 48,
                      child: StopMarker(
                        isDark: isDark,
                        color: routeColor,
                        isSelected: true,
                        size: 36,
                      ),
                    ),
                    ...vehicles.map(
                      (v) => Marker(
                        key: ValueKey(
                          '${v.vehicleId}_${v.latitude}_${v.longitude}_${v.bearing}',
                        ),
                        point: LatLng(v.latitude, v.longitude),
                        width: 48,
                        height: 48,
                        child: VehicleMarker(
                          color: routeColor,
                          bearing: v.bearing.toDouble(),
                          isDark: isDark,
                          label: _vehicleLabel(v),
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
            right: 16,
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
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.slate800
                              : AppColors.slate100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: isDark ? Colors.white : AppColors.slate900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                    const SizedBox(width: 6),
                    LivePulseCountdownBadge(
                      remainingSeconds: _secondsUntilRefresh,
                      totalSeconds: _refreshIntervalSeconds,
                      isRefreshing:
                          vehiclesAsync.isRefreshing ||
                          predictionsAsync.isRefreshing,
                      accentColor: routeColor,
                      isDark: isDark,
                      vehicleCount: vehicles.length,
                      onTap: _refreshNow,
                    ),
                    const SizedBox(width: 6),
                    Material(
                      color: isDark ? AppColors.slate800 : AppColors.slate100,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LineMapDetailsScreen(
                                line: LineSummaryDto(
                                  routeId: widget.prediction.routeId,
                                  shortName: widget.prediction.shortName,
                                  longName: widget.prediction.longName,
                                  color: widget.prediction.color,
                                  system: widget.prediction.system,
                                ),
                                tripId: tripId ?? '',
                                direction: widget.prediction.direction,
                                variantLabel:
                                    variantAsync.value?.variantLabel ??
                                    'PRINCIPAL',
                                initialTabIndex: 1,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 13,
                                color: routeColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Horários',
                                style: AppTypography.nunito.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.slate800,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
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
            child: MapControlsColumn(
              isDark: isDark,
              onCenterRoute: () => _centerOnRoute(routePoints),
              onCenterUser: _centerOnUser,
              onCenterStop: _centerOnStop,
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
              showStopButton: true,
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
                child: ArrivalBubblesColumn(
                  arrivals: arrivals.map((a) => a.etaMinutes).toList(),
                  color: routeColor,
                  isDark: isDark,
                  animation: _bubblesAnimController,
                  onClose: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
