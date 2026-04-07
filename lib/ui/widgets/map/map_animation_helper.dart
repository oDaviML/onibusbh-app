import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapAnimationHelper {
  const MapAnimationHelper._();

  static void animateTo(
    MapController mapController,
    LatLng target, {
    double? zoom,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOutCubic,
    VoidCallback? onComplete,
  }) {
    final camera = mapController.camera;
    final targetZoom = zoom ?? camera.zoom;

    final latTween = Tween<double>(
      begin: camera.center.latitude,
      end: target.latitude,
    );
    final lngTween = Tween<double>(
      begin: camera.center.longitude,
      end: target.longitude,
    );
    final zoomTween = Tween<double>(begin: camera.zoom, end: targetZoom);

    late final AnimationController controller;
    controller = AnimationController(
      vsync: _DummyVSync(),
      duration: duration,
    );

    final animation = CurvedAnimation(parent: controller, curve: curve);

    controller.addListener(() {
      mapController.move(
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

  static void zoomIn(MapController mapController, {double delta = 1.0}) {
    final camera = mapController.camera;
    animateTo(mapController, camera.center, zoom: camera.zoom + delta);
  }

  static void zoomOut(MapController mapController, {double delta = 1.0}) {
    final camera = mapController.camera;
    animateTo(mapController, camera.center, zoom: camera.zoom - delta);
  }

  static void fitBounds(
    MapController mapController,
    LatLngBounds bounds, {
    EdgeInsets padding = const EdgeInsets.all(64),
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOutCubic,
    VoidCallback? onComplete,
  }) {
    final cameraFit = CameraFit.bounds(bounds: bounds, padding: padding);
    final fitted = cameraFit.fit(mapController.camera);
    animateTo(
      mapController,
      fitted.center,
      zoom: fitted.zoom,
      duration: duration,
      curve: curve,
      onComplete: onComplete,
    );
  }
}

class _DummyVSync implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
