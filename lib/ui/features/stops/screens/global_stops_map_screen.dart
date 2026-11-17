import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/map_styles.dart';
import '../../../../data/models/stop_dto.dart';
import '../../../../data/models/prediction_response_dto.dart';
import '../../../../data/providers/stop_providers.dart';
import '../../../widgets/scaffold_with_nav_bar.dart';
import '../../../widgets/system_badge.dart';
import '../../../widgets/markers/stop_marker.dart';
import '../../../widgets/markers/cluster_marker.dart';
import '../../../widgets/markers/user_location_marker.dart';
import '../../../widgets/map/map_controls.dart';
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
  AnimationController? _mapMoveController;
  LatLng? _userLocation;
  StreamSubscription<Position>? _positionStream;
  StopDto? _selectedStop;
  List<StopDto> _clusterPickerStops = const [];
  late final AnimationController _drawerAnimController;
  late final Animation<Offset> _drawerSlideAnimation;
  Offset? _backdropStartPos;
  bool _backdropMoved = false;
  bool _handledMapMarkerTap = false;
  bool _isMapReady = false;
  double _currentZoom = 14.0;

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

    final bounds = camera.visibleBounds;
    final bbox = (
      minLat: bounds.south,
      minLon: bounds.west,
      maxLat: bounds.north,
      maxLon: bounds.east,
    );
    ref.read(mapProvider.notifier).update(bbox, camera.zoom);
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
    _mapMoveController?.dispose();
    _mapMoveController = null;
    _mapController.dispose();
    _drawerAnimController.dispose();
    ScaffoldWithNavBar.forceHide.value = false;
    super.dispose();
  }

  void _animateMapTo(LatLng target, double zoom, {VoidCallback? onComplete}) {
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

  void _selectSingleStop(StopDto stop) {
    setState(() {
      _clusterPickerStops = const [];
      _selectedStop = stop;
    });
    ScaffoldWithNavBar.forceHide.value = true;
    _drawerAnimController.forward(from: 0);
  }

  void _openClusterPicker(List<StopDto> stops, {LatLng? center}) {
    _drawerAnimController.reset();
    setState(() {
      _selectedStop = null;
      _clusterPickerStops = stops;
    });
    ScaffoldWithNavBar.forceHide.value = true;
    if (_isMapReady && center != null) {
      _animateMapTo(
        center,
        math.max(_currentZoom, 16.8),
        onComplete: _pushCurrentBBox,
      );
    }
  }

  void _closeClusterPicker() {
    setState(() {
      _clusterPickerStops = const [];
    });
    if (_selectedStop == null) {
      ScaffoldWithNavBar.forceHide.value = false;
    }
  }

  void _onClusterTapped(
    MarkerClusterNode clusterNode,
    Map<String, StopDto> stopById,
  ) {
    _handledMapMarkerTap = true;
    final clusterStops = <StopDto>[];
    for (final marker in clusterNode.mapMarkers) {
      final key = marker.key;
      if (key is ValueKey<String>) {
        final stop = stopById[key.value];
        if (stop != null) clusterStops.add(stop);
      }
    }
    if (clusterStops.isEmpty) return;
    if (clusterStops.length == 1) {
      _selectSingleStop(clusterStops.first);
      return;
    }

    final bounds = LatLngBounds.fromPoints(
      clusterStops.map((s) => LatLng(s.latitude, s.longitude)).toList(),
    );
    final diagonalMeters = const Distance().as(
      LengthUnit.Meter,
      bounds.southWest,
      bounds.northEast,
    );

    if (_currentZoom < 15.8 && diagonalMeters > 22) {
      final fitted = CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(72),
        maxZoom: 17.2,
      ).fit(_mapController.camera);
      _animateMapTo(
        fitted.center,
        math.max(fitted.zoom, 16.2),
        onComplete: _pushCurrentBBox,
      );
      return;
    }

    _openClusterPicker(clusterStops, center: bounds.center);
  }

  void _handleStopMarkerTap(StopDto stop, List<StopDto> allStops) {
    _handledMapMarkerTap = true;
    if (_clusterPickerStops.isNotEmpty) {
      _selectSingleStop(stop);
      return;
    }
    if (_isMapReady) {
      final tappedPoint = _mapController.camera.latLngToScreenOffset(
        LatLng(stop.latitude, stop.longitude),
      );
      final nearby = <StopDto>[];
      for (final candidate in allStops) {
        if (candidate.id == stop.id) continue;
        final pt = _mapController.camera.latLngToScreenOffset(
          LatLng(candidate.latitude, candidate.longitude),
        );
        if ((pt - tappedPoint).distance <= 20.0) {
          nearby.add(candidate);
        }
      }
      if (nearby.isNotEmpty) {
        _openClusterPicker(
          [stop, ...nearby],
          center: LatLng(stop.latitude, stop.longitude),
        );
        return;
      }
    }
    _selectSingleStop(stop);
  }

  void _closeDrawer() {
    ScaffoldWithNavBar.forceHide.value = false;
    _drawerAnimController.reverse().then((_) {
      if (mounted && _drawerAnimController.isDismissed) {
        setState(() {
          _selectedStop = null;
        });
      }
    });
  }

  void _onOpenTracking(PredictionResponseDto prediction) {
    final stop = _selectedStop;
    if (stop == null) return;

    setState(() {
      _clusterPickerStops = const [];
    });

    Navigator.of(context, rootNavigator: true).push(
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

  bool get _hasActiveOverlay =>
      _selectedStop != null || _clusterPickerStops.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final stopsAsync = ref.watch(stopsProvider);
    final stops = stopsAsync.value ?? [];
    final stopById = {for (final s in stops) s.id: s};

    final popContent = PopScope(
      canPop: !_hasActiveOverlay,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (_isDrawerOpen) {
            _closeDrawer();
          } else if (_clusterPickerStops.isNotEmpty) {
            _closeClusterPicker();
          }
        }
      },
      child: Scaffold(
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
                  if ((position.zoom - _currentZoom).abs() > 0.05) {
                    setState(() => _currentZoom = position.zoom);
                  }
                  _onMapMoved();
                },
              ),
              children: [
                MapStyles.buildTileLayer(isDark: isDark),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 42,
                    disableClusteringAtZoom: 16,
                    spiderfyCluster: false,
                    showPolygon: false,
                    zoomToBoundsOnClick: false,
                    centerMarkerOnClick: false,
                    markerChildBehavior: true,
                    size: const Size(54, 32),
                    computeSize: (markers) =>
                        Size(markers.length > 99 ? 64 : 54, 32),
                    animationsOptions: const AnimationsOptions(),
                    onClusterTap: (clusterNode) =>
                        _onClusterTapped(clusterNode, stopById),
                    builder: (context, markers) {
                      final allMetro =
                          markers.isNotEmpty &&
                          markers.every((m) {
                            final key = m.key;
                            if (key is ValueKey<String>) {
                              return stopById[key.value]?.isMetropolitan ??
                                  key.value.startsWith('otimo_');
                            }
                            return false;
                          });
                      return ClusterMarker(
                        count: markers.length,
                        isDark: isDark,
                        size: markers.length > 99 ? 64 : 54,
                        allMetropolitan: allMetro,
                      );
                    },
                    markers: stops.map((stop) {
                      final isSelected = _selectedStop?.id == stop.id;
                      final pickerIdx = _clusterPickerStops.indexWhere(
                        (s) => s.id == stop.id,
                      );
                      final int? badgeNumber =
                          pickerIdx >= 0 ? pickerIdx + 1 : null;
                      final isCompact =
                          _currentZoom < 15.6 &&
                          !isSelected &&
                          badgeNumber == null;
                      final double markerExtent = isSelected
                          ? 40.0
                          : (badgeNumber != null
                                ? 34.0
                                : (isCompact ? 24.0 : 30.0));
                      return Marker(
                        key: ValueKey<String>(stop.id),
                        point: LatLng(stop.latitude, stop.longitude),
                        width: markerExtent,
                        height: markerExtent,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _handleStopMarkerTap(stop, stops),
                          child: Center(
                            child: StopMarker(
                              isDark: isDark,
                              isSelected: isSelected,
                              compact: isCompact,
                              badgeNumber: badgeNumber,
                              size: isCompact ? 22 : 26,
                              color: stop.isMetropolitan
                                  ? SystemBadge.metropolitanColor
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (_userLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _userLocation!,
                        width: 48,
                        height: 48,
                        child: RepaintBoundary(
                          child: UserLocationMarker(size: 16, isDark: isDark),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          if (_currentZoom < 14.0 && !_hasActiveOverlay)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 24,
              right: 24,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.slate900.withValues(alpha: 0.92)
                        : Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.zoom_in_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Aproxime o mapa para ver os pontos',
                        style: AppTypography.labelMedium.copyWith(
                          color: isDark ? Colors.white : AppColors.slate800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_hasActiveOverlay)
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (event) {
                  _backdropStartPos = event.position;
                  _backdropMoved = false;
                  _handledMapMarkerTap = false;
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
                  final moved = _backdropMoved;
                  _backdropStartPos = null;
                  if (moved) return;
                  scheduleMicrotask(() {
                    if (!mounted || _handledMapMarkerTap) return;
                    if (_isDrawerOpen) {
                      _closeDrawer();
                    } else if (_clusterPickerStops.isNotEmpty) {
                      _closeClusterPicker();
                    }
                  });
                },
                child: const SizedBox.expand(),
              ),
            ),

          Positioned(
            right: 16,
            bottom: _isDrawerOpen
                ? (MediaQuery.of(context).size.height * 0.55 + 16)
                : (_clusterPickerStops.isNotEmpty
                      ? (MediaQuery.of(context).size.height * 0.38 +
                            bottomInset +
                            16)
                      : (bottomInset + 20)),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, progress, child) {
                return Opacity(
                  opacity: progress,
                  child: Transform.translate(
                    offset: Offset(20 * (1 - progress), 0),
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MapControlButton(
                    isDark: isDark,
                    icon: Icons.my_location_rounded,
                    tooltip: 'Minha localização',
                    onPressed: _centerOnUser,
                  ),
                  const SizedBox(height: 12),
                  MapZoomControls(
                    isDark: isDark,
                    onZoomIn: _zoomIn,
                    onZoomOut: _zoomOut,
                  ),
                ],
              ),
            ),
          ),

          if (_clusterPickerStops.isNotEmpty && _selectedStop == null)
            Positioned(
              left: 16,
              right: 16,
              bottom: bottomInset + 16,
              child: _ClusterStopsPickerCard(
                stops: _clusterPickerStops,
                isDark: isDark,
                onSelectStop: _selectSingleStop,
                onClose: _closeClusterPicker,
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
                  onVerticalDragEnd: (details) {
                    if ((details.primaryVelocity ?? 0) > 250) {
                      _closeDrawer();
                    }
                  },
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
      ),
    );

    if (Router.maybeOf(context) == null) {
      return popContent;
    }

    return BackButtonListener(
      onBackButtonPressed: () async {
        final shell = StatefulNavigationShell.maybeOf(context);
        if (shell != null && shell.currentIndex != 1) {
          return false;
        }
        final rootNav = Navigator.maybeOf(context, rootNavigator: true);
        if (rootNav != null && rootNav.canPop()) {
          return false;
        }
        if (_isDrawerOpen) {
          _closeDrawer();
          return true;
        }
        if (_clusterPickerStops.isNotEmpty) {
          _closeClusterPicker();
          return true;
        }
        return false;
      },
      child: popContent,
    );
  }
}

class _ClusterStopsPickerCard extends StatelessWidget {
  final List<StopDto> stops;
  final bool isDark;
  final ValueChanged<StopDto> onSelectStop;
  final VoidCallback onClose;

  const _ClusterStopsPickerCard({
    required this.stops,
    required this.isDark,
    required this.onSelectStop,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.38;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate900 : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.slate800 : AppColors.slate200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.16),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 10, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${stops.length} paradas próximas · toque para escolher',
                      style: AppTypography.labelMedium.copyWith(
                        color: isDark ? AppColors.slate200 : AppColors.slate700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded, size: 20),
                    visualDensity: VisualDensity.compact,
                    color: AppColors.slate400,
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: isDark ? AppColors.slate800 : AppColors.slate100,
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: stops.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  indent: 58,
                  color: isDark ? AppColors.slate800 : AppColors.slate100,
                ),
                itemBuilder: (context, index) {
                  final stop = stops[index];
                  final badgeColor = stop.isMetropolitan
                      ? SystemBadge.metropolitanColor
                      : AppColors.primary;
                  final subtitle =
                      (stop.description != null &&
                          stop.description!.trim().isNotEmpty)
                      ? stop.description!.trim()
                      : stop.resolvedStreetName;

                  return InkWell(
                    onTap: () => onSelectStop(stop),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: badgeColor,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 1}',
                              style: AppTypography.quicksand.copyWith(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
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
                                  stop.name,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.slate900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.slate500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SystemBadge(
                            isMetropolitan: stop.isMetropolitan,
                            compact: true,
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.slate400,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
