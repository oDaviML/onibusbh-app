import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/map_styles.dart';
import '../../../../data/models/direction_variants_dto.dart';
import '../../../../data/models/line_summary_dto.dart';
import '../../../../data/models/line_variant_dto.dart';
import '../../../../data/models/prediction_response_dto.dart';
import '../../../../data/models/shape_dto.dart';
import '../../../../data/models/stop_dto.dart';
import '../../../../data/models/vehicle_position_dto.dart';
import '../../../../data/providers/line_providers.dart';
import '../../../widgets/markers/stop_marker.dart';
import '../../../widgets/markers/vehicle_marker.dart';
import '../../../widgets/markers/user_location_marker.dart';
import '../../../widgets/live_pulse_countdown_badge.dart';
import '../../../widgets/map/map_controls.dart';
import '../../../widgets/system_badge.dart';
import '../../stops/screens/stop_tracking_screen.dart';
import '../../stops/widgets/stop_details_drawer.dart';
import '../widgets/line_itinerary_view.dart';
import '../widgets/line_timetable_view.dart';

class LineMapDetailsScreen extends ConsumerStatefulWidget {
  final LineSummaryDto line;
  final String tripId;
  final int direction;
  final String variantLabel;
  final int initialTabIndex;

  const LineMapDetailsScreen({
    super.key,
    required this.line,
    required this.tripId,
    required this.direction,
    required this.variantLabel,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<LineMapDetailsScreen> createState() =>
      _LineMapDetailsScreenState();
}

class _LineMapDetailsScreenState extends ConsumerState<LineMapDetailsScreen>
    with TickerProviderStateMixin {
  static const int _refreshIntervalSeconds = 10;

  final MapController _mapController = MapController();
  LatLng? _userLocation;
  StreamSubscription<Position>? _positionStream;
  Timer? _pollingSecondTimer;
  int _secondsUntilRefresh = _refreshIntervalSeconds;
  bool _hasAutoFocused = false;
  bool _isMapReady = false;

  late int _selectedTabIndex;
  late String _activeTripId;
  late int _activeDirection;
  StopDto? _selectedStop;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex.clamp(0, 2);
    _activeTripId = widget.tripId;
    _activeDirection = widget.direction;
    _initLocationService();
    _startVehiclePolling();
  }

  void _autoFocusOnRoute(List<LatLng> routePoints) {
    if (_hasAutoFocused || routePoints.isEmpty || !_isMapReady) return;
    _hasAutoFocused = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _centerOnRoute(routePoints);
    });
  }

  void _startVehiclePolling() {
    _pollingSecondTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsUntilRefresh <= 1) {
        _refreshVehiclesNow();
      } else {
        setState(() => _secondsUntilRefresh--);
      }
    });
  }

  void _refreshVehiclesNow() {
    if (!mounted) return;
    setState(() => _secondsUntilRefresh = _refreshIntervalSeconds);
    if (_activeTripId.isEmpty) return;
    ref.invalidate(
      lineVehiclesProvider((
        lineId: widget.line.routeId,
        tripId: _activeTripId,
      )),
    );
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
    _mapController.dispose();
    super.dispose();
  }

  void _animateMapTo(LatLng target, double zoom) {
    if (!_isMapReady || !mounted) return;
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
      duration: const Duration(milliseconds: 450),
    );
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
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _zoomIn() {
    if (!_isMapReady) return;
    final camera = _mapController.camera;
    _animateMapTo(camera.center, camera.zoom + 1);
  }

  void _zoomOut() {
    if (!_isMapReady) return;
    final camera = _mapController.camera;
    _animateMapTo(camera.center, camera.zoom - 1);
  }

  void _centerOnRoute(List<LatLng> points) {
    if (points.isEmpty || !_isMapReady) return;

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
      _animateMapTo(_userLocation!, 15.5);
    }
  }

  void _switchVariant(int directionId, LineVariantDto variant) {
    final nextTripId = variant.tripId ?? '';
    if (nextTripId.isEmpty ||
        (nextTripId == _activeTripId && directionId == _activeDirection)) {
      return;
    }
    setState(() {
      _activeDirection = directionId;
      _activeTripId = nextTripId;
      _selectedStop = null;
      _hasAutoFocused = false;
      _secondsUntilRefresh = _refreshIntervalSeconds;
    });
  }

  void _focusStopOnMap(StopDto stop) {
    setState(() {
      _selectedTabIndex = 0;
      _selectedStop = stop;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateMapTo(LatLng(stop.latitude, stop.longitude), 16.5);
    });
  }

  void _openStopPredictionsSheet(StopDto stop) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StopDetailsDrawer(
        stop: stop,
        onOpenTracking: (PredictionResponseDto prediction) {
          Navigator.of(sheetContext).pop();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => StopTrackingScreen(
                stop: stop,
                prediction: prediction,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final routeColor = widget.line.routeColor;
    final variantsAsync = ref.watch(lineVariantsProvider(widget.line.routeId));
    final directions = variantsAsync.value ?? const <DirectionVariantsDto>[];

    // If opened without a preselected tripId, resolve first available variant automatically
    if (_activeTripId.isEmpty && directions.isNotEmpty) {
      final matchedDir = directions.firstWhere(
        (d) => d.directionId == _activeDirection,
        orElse: () => directions.first,
      );
      if (matchedDir.variants.isNotEmpty && matchedDir.variants.first.tripId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _activeTripId.isEmpty) {
            _switchVariant(matchedDir.directionId, matchedDir.variants.first);
          }
        });
      }
    }

    final shapeAsync = _activeTripId.isNotEmpty
        ? ref.watch(
            lineShapeProvider((
              lineId: widget.line.routeId,
              tripId: _activeTripId,
            )),
          )
        : const AsyncValue<ShapeDto>.loading();

    final stopsAsync = _activeTripId.isNotEmpty
        ? ref.watch(
            lineStopsProvider((
              lineId: widget.line.routeId,
              tripId: _activeTripId,
            )),
          )
        : const AsyncValue<List<StopDto>>.loading();

    final vehiclesAsync = _activeTripId.isNotEmpty
        ? ref.watch(
            lineVehiclesProvider((
              lineId: widget.line.routeId,
              tripId: _activeTripId,
            )),
          )
        : const AsyncValue<List<VehiclePositionDto>>.loading();

    final timetableAsync = ref.watch(lineTimetableProvider(widget.line.routeId));

    final routePoints = shapeAsync.value?.path ?? const <LatLng>[];
    final lineStops = stopsAsync.value ?? const <StopDto>[];
    final vehicles = vehiclesAsync.value ?? const <VehiclePositionDto>[];

    String timetableBadge = '';
    final timetable = timetableAsync.value;
    if (timetable != null && timetable.directions.isNotEmpty) {
      final matchedTimetableDir = timetable.directions.firstWhere(
        (d) => d.directionId == _activeDirection,
        orElse: () => timetable.directions.first,
      );
      final departureCount = matchedTimetableDir.services.fold<int>(
        0,
        (sum, service) => sum + service.departures.length,
      );
      if (departureCount > 0) {
        timetableBadge = '$departureCount';
      }
    }

    if (routePoints.isNotEmpty && !_hasAutoFocused && _isMapReady) {
      _autoFocusOnRoute(routePoints);
    }

    final variantOptions = _flattenVariantOptions(directions);

    final canPopDirectly = !(_selectedTabIndex == 0 && _selectedStop != null);

    final popContent = PopScope(
      canPop: canPopDirectly,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selectedTabIndex == 0 && _selectedStop != null) {
          setState(() => _selectedStop = null);
        }
      },
      child: Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          body: Column(
            children: [
              _buildTopHeader(
                context: context,
                isDark: isDark,
                routeColor: routeColor,
                variantOptions: variantOptions,
                vehicleCount: vehicles.length,
                isRefreshingVehicles: vehiclesAsync.isRefreshing,
                timetableBadge: timetableBadge,
                stopCount: lineStops.length,
              ),
              Expanded(
                child: IndexedStack(
                  index: _selectedTabIndex,
                  children: [
                    _buildMapTab(
                      isDark: isDark,
                      routeColor: routeColor,
                      shapeAsync: shapeAsync,
                      stopsAsync: stopsAsync,
                      routePoints: routePoints,
                      lineStops: lineStops,
                      vehicles: vehicles,
                    ),
                    LineTimetableView(
                      line: widget.line,
                      activeDirectionId: _activeDirection,
                      timetableAsync: timetableAsync,
                      onRetry: () => ref.invalidate(
                        lineTimetableProvider(widget.line.routeId),
                      ),
                    ),
                    LineItineraryView(
                      line: widget.line,
                      stops: lineStops,
                      vehicles: vehicles,
                      isLoading: stopsAsync.isLoading,
                      error: stopsAsync.hasError ? stopsAsync.error.toString() : null,
                      onRetry: () {
                        if (_activeTripId.isNotEmpty) {
                          ref.invalidate(
                            lineStopsProvider((
                              lineId: widget.line.routeId,
                              tripId: _activeTripId,
                            )),
                          );
                        }
                      },
                      onFocusStopOnMap: _focusStopOnMap,
                      onOpenStopPredictions: _openStopPredictionsSheet,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );

    if (Router.maybeOf(context) == null) {
      return popContent;
    }

    return BackButtonListener(
      onBackButtonPressed: () async {
        if (_selectedTabIndex == 0 && _selectedStop != null) {
          setState(() => _selectedStop = null);
          return true;
        }
        return false;
      },
      child: popContent,
    );
  }

  List<({int directionId, String dirLabel, LineVariantDto variant})>
      _flattenVariantOptions(List<DirectionVariantsDto> directions) {
    final options =
        <({int directionId, String dirLabel, LineVariantDto variant})>[];
    for (final dir in directions) {
      for (final variant in dir.variants) {
        if (variant.tripId == null || variant.tripId!.isEmpty) continue;
        final baseDir = dir.directionId == 0 ? 'Ida' : 'Volta';
        final label = variant.variantLabel == 'PRINCIPAL'
            ? (directions.length > 1 && dir.headsign.isNotEmpty
                  ? '$baseDir · ${dir.headsign}'
                  : (dir.headsign.isNotEmpty ? dir.headsign : baseDir))
            : '$baseDir · ${variant.displayName}';
        options.add((directionId: dir.directionId, dirLabel: label, variant: variant));
      }
    }
    return options;
  }

  Widget _buildTopHeader({
    required BuildContext context,
    required bool isDark,
    required Color routeColor,
    required List<({int directionId, String dirLabel, LineVariantDto variant})>
        variantOptions,
    required int vehicleCount,
    required bool isRefreshingVehicles,
    required String timetableBadge,
    required int stopCount,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.slate900.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate800 : AppColors.slate100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: isDark ? Colors.white : AppColors.slate900,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: routeColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
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
                  children: [
                    Text(
                      widget.line.longName,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? Colors.white : AppColors.slate900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        SystemBadge(
                          isMetropolitan: widget.line.isMetropolitan,
                          compact: true,
                        ),
                        if (widget.line.formattedPrice != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.slate800
                                  : AppColors.slate100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.line.formattedPrice!,
                              style: AppTypography.caption.copyWith(
                                fontSize: 10,
                                color: isDark
                                    ? AppColors.slate300
                                    : AppColors.slate600,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 6),
                        Text(
                          _activeDirection == 0 ? 'Ida' : 'Volta',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              LivePulseCountdownBadge(
                remainingSeconds: _secondsUntilRefresh,
                totalSeconds: _refreshIntervalSeconds,
                isRefreshing: isRefreshingVehicles,
                accentColor: routeColor,
                isDark: isDark,
                onTap: _refreshVehiclesNow,
              ),
            ],
          ),
          if (variantOptions.length > 1) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: variantOptions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final opt = variantOptions[index];
                  final selected = opt.variant.tripId == _activeTripId &&
                      opt.directionId == _activeDirection;
                  return ChoiceChip(
                    label: Text(
                      opt.dirLabel,
                      overflow: TextOverflow.ellipsis,
                    ),
                    selected: selected,
                    onSelected: (_) => _switchVariant(opt.directionId, opt.variant),
                    selectedColor: routeColor.withValues(alpha: 0.16),
                    labelStyle: AppTypography.caption.copyWith(
                      color: selected
                          ? routeColor
                          : (isDark ? AppColors.slate300 : AppColors.slate600),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: selected
                          ? routeColor
                          : (isDark ? AppColors.slate700 : AppColors.slate200),
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MainTabButton(
                    icon: Icons.map_outlined,
                    label: 'Mapa',
                    badge: '$vehicleCount',
                    selected: _selectedTabIndex == 0,
                    accentColor: routeColor,
                    onTap: () => setState(() => _selectedTabIndex = 0),
                  ),
                ),
                Expanded(
                  child: _MainTabButton(
                    icon: Icons.schedule_outlined,
                    label: 'Horários',
                    badge: timetableBadge,
                    selected: _selectedTabIndex == 1,
                    accentColor: routeColor,
                    onTap: () => setState(() => _selectedTabIndex = 1),
                  ),
                ),
                Expanded(
                  child: _MainTabButton(
                    icon: Icons.route_outlined,
                    label: 'Itinerário',
                    badge: '$stopCount',
                    selected: _selectedTabIndex == 2,
                    accentColor: routeColor,
                    onTap: () => setState(() => _selectedTabIndex = 2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab({
    required bool isDark,
    required Color routeColor,
    required AsyncValue<ShapeDto> shapeAsync,
    required AsyncValue<List<StopDto>> stopsAsync,
    required List<LatLng> routePoints,
    required List<StopDto> lineStops,
    required List<VehiclePositionDto> vehicles,
  }) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final hasSelectedStop = _selectedStop != null;

    return Stack(
      children: [
        Positioned.fill(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-19.920, -43.935),
              initialZoom: 13.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onMapReady: () {
                _isMapReady = true;
                if (routePoints.isNotEmpty) {
                  _autoFocusOnRoute(routePoints);
                }
              },
              onTap: (_, _) {
                if (_selectedStop != null) {
                  setState(() => _selectedStop = null);
                }
              },
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
                  ...lineStops.map((stop) {
                    final isSelected = _selectedStop?.id == stop.id &&
                        _selectedStop?.stopSequence == stop.stopSequence;
                    return Marker(
                      point: LatLng(stop.latitude, stop.longitude),
                      width: isSelected ? 38 : 26,
                      height: isSelected ? 38 : 26,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() => _selectedStop = stop);
                          _animateMapTo(
                            LatLng(stop.latitude, stop.longitude),
                            _mapController.camera.zoom < 15.5
                                ? 16.0
                                : _mapController.camera.zoom,
                          );
                        },
                        child: StopMarker(
                          isDark: isDark,
                          color: routeColor,
                          isSelected: isSelected,
                          size: isSelected ? 32 : 20,
                        ),
                      ),
                    );
                  }),
                  ...vehicles.map((v) {
                    return Marker(
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
                        label: 'Carro ${v.vehicleId}',
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
        if (shapeAsync.isLoading || stopsAsync.isLoading)
          Positioned(
            top: 12,
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
                      ? AppColors.slate800.withValues(alpha: 0.92)
                      : Colors.white.withValues(alpha: 0.95),
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
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: routeColor,
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
          bottom: hasSelectedStop ? (bottomPadding + 152) : (bottomPadding + 20),
          child: MapControlsColumn(
            isDark: isDark,
            onCenterRoute: () => _centerOnRoute(routePoints),
            onCenterUser: _centerOnUser,
            onZoomIn: _zoomIn,
            onZoomOut: _zoomOut,
          ),
        ),
        if (_selectedStop != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomPadding + 16,
            child: _SelectedStopCard(
              stop: _selectedStop!,
              routeColor: routeColor,
              isDark: isDark,
              onClose: () => setState(() => _selectedStop = null),
              onOpenPredictions: () => _openStopPredictionsSheet(_selectedStop!),
            ),
          ),
      ],
    );
  }
}

class _MainTabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String badge;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _MainTabButton({
    required this.icon,
    required this.label,
    required this.badge,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? AppColors.slate700 : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? accentColor : AppColors.slate400,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: selected
                      ? (isDark ? Colors.white : AppColors.slate900)
                      : AppColors.slate500,
                ),
              ),
              if (badge.isNotEmpty) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? accentColor.withValues(alpha: 0.15)
                        : (isDark ? AppColors.slate900 : AppColors.slate200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: AppTypography.caption.copyWith(
                      fontSize: 10,
                      color: selected ? accentColor : AppColors.slate500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedStopCard extends StatelessWidget {
  final StopDto stop;
  final Color routeColor;
  final bool isDark;
  final VoidCallback onClose;
  final VoidCallback onOpenPredictions;

  const _SelectedStopCard({
    required this.stop,
    required this.routeColor,
    required this.isDark,
    required this.onClose,
    required this.onOpenPredictions,
  });

  @override
  Widget build(BuildContext context) {
    final seqText = stop.stopSequence != null ? 'Parada #${stop.stopSequence}' : 'Parada';
    final travelText = stop.travelTimeSeconds != null
        ? ' · +${(stop.travelTimeSeconds! / 60).round()} min'
        : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: routeColor.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: routeColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$seqText$travelText',
                  style: AppTypography.caption.copyWith(color: routeColor),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, size: 18),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            stop.name,
            style: AppTypography.titleMedium.copyWith(
              fontSize: 15,
              color: isDark ? Colors.white : AppColors.slate900,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: onOpenPredictions,
            style: FilledButton.styleFrom(
              backgroundColor: routeColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.schedule_rounded, size: 18),
            label: const Text('Ver previsões neste ponto'),
          ),
        ],
      ),
    );
  }
}
