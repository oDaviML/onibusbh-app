import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/stop_dto.dart';
import '../widgets/stop_details_drawer.dart';

class GlobalStopsMapScreen extends StatelessWidget {
  const GlobalStopsMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(-19.9167, -43.9345),
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
                MarkerLayer(
                  markers: mockStops.map((stop) {
                    return Marker(
                      point: LatLng(stop.lat, stop.lon),
                      width: 56,
                      height: 56,
                      child: GestureDetector(
                        onTap: () {
                          StopDetailsDrawer.show(context, stop);
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.rotate(
                              angle: stop.bearing * math.pi / 180,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: FractionalTranslation(
                                  translation: const Offset(0.0, -0.1),
                                  child: Icon(
                                    Icons.eject,
                                    color: stop.routeColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: stop.routeColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: stop.routeColor.withValues(
                                      alpha: 0.4,
                                    ),
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
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          Positioned(
            top: topPadding + 16,
            left: 24,
            right: 24,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate900 : Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.slate900.withValues(
                      alpha: isDark ? 0.3 : 0.08,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.slate400),
                  const SizedBox(width: 12),
                  Text(
                    'Search nearby stops',
                    style: AppTypography.display.copyWith(
                      color: AppColors.slate500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 24,
            bottom: 120,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
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
                    icon: const Icon(Icons.my_location),
                    color: AppColors.slate900,
                    iconSize: 20,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: 16),

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
                        color: AppColors.slate900,
                        iconSize: 20,
                        onPressed: () {},
                      ),
                      Container(
                        height: 1,
                        width: 24,
                        color: isDark ? AppColors.slate800 : AppColors.slate200,
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        color: AppColors.slate900,
                        iconSize: 20,
                        onPressed: () {},
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
